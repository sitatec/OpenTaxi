package com.hamba.dispatcher

import com.hamba.dispatcher.data.DataChangeListener
import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.*
import dilivia.s2.S1Angle
import dilivia.s2.S2Earth
import dilivia.s2.index.S2MinDistance
import dilivia.s2.index.point.S2ClosestPointQuery
import kotlinx.coroutines.runBlocking

class DistanceCalculator(private val driverDataRepository: DriverDataRepository, private val routeApiClient: RouteApiClient) {

    private val closestPointQuery = S2ClosestPointQuery(
        driverDataRepository.locationIndex,
        S2ClosestPointQuery.Options(maxDistance = S2MinDistance(S1Angle.radians(S2Earth.kmToRadians(3.0))))
    )

    private var numberOfDistanceCalculationRunning = 0
    private val availableUpdates = mutableListOf<() -> Unit>()

    init {
        val dataChangeListener = DataChangeListener(
            onDataAdded = closestPointQuery::reInit,
            onDataDeleted = closestPointQuery::reInit,
            onDataUpdateNeeded = { update ->
                if(numberOfDistanceCalculationRunning > 0) {
                    availableUpdates.add(update)
                }else {
                    update()
                }
            },
        )
        driverDataRepository.addDataChangeListener(dataChangeListener)
    }

    fun getClosestDriverDistance(requestData: DispatchRequestData): List<Pair<DriverData, Element>> {
        var closestDriverAsTheCrowFlies: List<DriverData>
        synchronized(this) {
            numberOfDistanceCalculationRunning++
            closestDriverAsTheCrowFlies = if (requestData.gender == null && requestData.carType == null) {
                findClosestDistanceAsTheCrowFlies(requestData.location)
            } else {
                findClosestDistanceAsTheCrowFlies(requestData)
            }
            numberOfDistanceCalculationRunning--
            availableUpdates.forEach { updateData -> updateData() }
        }
        return findClosestDistanceOnRoad(closestDriverAsTheCrowFlies, requestData.location)
    }

    private fun findClosestDistanceAsTheCrowFlies(data: DispatchRequestData): List<DriverData> {
        val target = S2ClosestPointQuery.S2ClosestPointQueryPointTarget(data.location.toS2Point())
        val closestPoint = closestPointQuery.findClosestPoints(target).filter {
            val driverData = driverDataRepository.getDriverData(it.data())
            if (data.gender != driverData?.gender) {
                return@filter false
            }
            if (data.carType != driverData?.carType) {
                return@filter false
            }
            true
        }
        if (closestPoint.isEmpty()) {
            return emptyList()
        }
        val closestDriver = closestPoint.sorted()
        val result = mutableListOf<DriverData>()
        var driverData: DriverData
        repeat(4) {
            driverData = driverDataRepository.getDriverData(closestDriver[it].data())!!
            // TODO Handle the case the driverDataManager return null ^.
            result.add(driverData)
        }
        return result
    }

    private fun findClosestDistanceAsTheCrowFlies(location: Location): List<DriverData> {
        val target = S2ClosestPointQuery.S2ClosestPointQueryPointTarget(location.toS2Point())
        closestPointQuery.options().setMaxResult(4)
        val closestPoint = closestPointQuery.findClosestPoints(target)
        return closestPoint.map { driverDataRepository.getDriverData(it.data())!! }// TODO Handle the case the driverDataManager return null.
    }

    private fun findClosestDistanceOnRoad(
        driversData: List<DriverData>,
        riderLocation: Location
    ): List<Pair<DriverData, Element>> {
        val driverLocations = driversData.map { it.location }
        val closestDriver = mutableListOf<Pair<DriverData, Element>>()
        runBlocking {
            val orderedDistanceMatrixElement = routeApiClient.distanceMatrix(driverLocations, riderLocation)
            repeat(driversData.size){
                closestDriver.add(Pair(driversData[it], orderedDistanceMatrixElement[it]))
            }
        }
        return closestDriver
    }

}