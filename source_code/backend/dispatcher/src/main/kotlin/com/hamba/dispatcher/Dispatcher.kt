package com.hamba.dispatcher

import com.hamba.dispatcher.model.DispatchRequestData
import com.hamba.dispatcher.model.Location
import com.hamba.dispatcher.model.DriverData
import com.hamba.dispatcher.model.toLocation
import dilivia.s2.S1Angle
import dilivia.s2.S2Earth
import dilivia.s2.index.S2MinDistance
import dilivia.s2.index.S2MinDistancePointTarget
import dilivia.s2.index.point.S2ClosestPointQuery
import kotlinx.coroutines.runBlocking

class Dispatcher(private val driverDataManager: DriverDataManager, private val routeApiClient: RouteApiClient) {

    private val distanceCalculator = S2ClosestPointQuery(
        driverDataManager.locationIndex,
        S2ClosestPointQuery.Options(maxDistance = S2MinDistance(S1Angle.degrees(S2Earth.kmToRadians(3.0))))
    )

    private val availableUpdates = mutableListOf<() -> Unit>()

    init {
        val dataChangeListener = DataChangeListener(
            onDataAdded = distanceCalculator::reInit,
            onDataDeleted = distanceCalculator::reInit,
            onDataUpdateNeeded = availableUpdates::add,
        )
        driverDataManager.addDataChangeListener(dataChangeListener)
    }

    fun dispatch(requestData: DispatchRequestData) {
        var closestDriverAsTheCrowFlies: List<Pair<String, Location>>
        synchronized(this) {
            closestDriverAsTheCrowFlies = if (requestData.gender.isBlank() && requestData.carType.isNotBlank()) {
                findClosestDistanceAsTheCrowFlies(requestData.location)
            } else {
                findClosestDistanceAsTheCrowFlies(requestData)
            }
            availableUpdates.forEach { updateData -> updateData() }
        }
        val closestDriverOnTheRoad = findClosestDistanceOnRoad(closestDriverAsTheCrowFlies, requestData.location)
    }

    private fun findClosestDistanceAsTheCrowFlies(data: DispatchRequestData): List<Pair<String, Location>> {
        val target = S2MinDistancePointTarget(data.location.toS2Point())
        val closestPoint = distanceCalculator.findClosestPoints(target).filter {
            val driverData = driverDataManager.getDriverData(it.data())
            if (data.gender.isNotBlank() && data.gender != driverData?.gender) {
                return@filter false
            }
            if (data.carType.isNotBlank() && data.carType != driverData?.carType) {
                return@filter false
            }
            true
        }
        if (closestPoint.isEmpty()) {
            return emptyList()
        }
        val closestDriver = closestPoint.sorted()
        val result = mutableListOf<Pair<String, Location>>()
        repeat(4) {
            result.add(Pair(closestDriver[it].data(), closestDriver[it].point().toLocation()))
        }
        return result
    }

    private fun findClosestDistanceAsTheCrowFlies(location: Location): List<Pair<String, Location>> {
        val target = S2MinDistancePointTarget(location.toS2Point())
        distanceCalculator.options().setMaxResult(4)
        val closestPoint = distanceCalculator.findClosestPoints(target)
        return closestPoint.map { Pair(it.data(), it.point().toLocation()) }
    }

    private fun findClosestDistanceOnRoad(
        driversData: List<Pair<String, Location>>,
        riderLocation: Location
    ): DriverData {
        val driverLocations = driversData.map { it.second }
        val idOfTheClosestDriver: String
        runBlocking {
            val indexOfTheClosestDriver = routeApiClient.distanceMatrix(driverLocations, riderLocation)
            idOfTheClosestDriver = driversData[indexOfTheClosestDriver].first
        }
        return driverDataManager.getDriverData(idOfTheClosestDriver)!!
    }

}