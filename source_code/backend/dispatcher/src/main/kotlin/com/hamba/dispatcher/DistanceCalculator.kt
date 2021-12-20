package com.hamba.dispatcher

import com.hamba.dispatcher.data.DriverPointDataCache
import com.hamba.dispatcher.data.model.*
import com.hamba.dispatcher.geometry.ClosestPointQuery
import com.hamba.dispatcher.geometry.PointIndex
import com.hamba.dispatcher.services.api.RouteApiClient
import dilivia.s2.S1Angle
import dilivia.s2.S2Earth
import dilivia.s2.index.S2MinDistance
import kotlinx.coroutines.runBlocking

class DistanceCalculator(
    private val routeApiClient: RouteApiClient,
    private val driverDataCache: DriverPointDataCache,
    private val distanceQueryOptions: ClosestPointQuery.Options = ClosestPointQuery.Options(
        maxDistance = S2MinDistance(S1Angle.radians(S2Earth.kmToRadians(3.0))),
        maxResult = 4
    )
) {

    fun getClosestDriverDistance(requestData: DispatchRequestData): List<Pair<DriverData, DistanceMatrixElement>> {
        var predicate: (DriverData?) -> Boolean = { it != null }
        if (requestData.carType != null && requestData.gender != null) {
            predicate = { it != null && requestData.carType == it.carType && requestData.gender == it.gender }
        } else if (requestData.carType != null) {
            predicate = { it != null && requestData.carType == it.carType }
        } else if (requestData.gender != null) {
            predicate = { it != null && requestData.gender == it.gender }
        }
        val closestDriverAsTheCrowFlies =
            findClosestDistanceAsTheCrowFlies(requestData, PointIndex(driverDataCache.map, predicate))
        return findClosestDistanceOnRoad(closestDriverAsTheCrowFlies, requestData.pickUpLocation)
//        return if(closestDriverAsTheCrowFlies.size > 1){
//            findClosestDistanceOnRoad(closestDriverAsTheCrowFlies, requestData.pickUpLocation)
//        } else {// If there is only one driver available near the rider it's useless to make a distance matrix request.
//            // TODO check if we need the distance matrix elements, if so make a direction request if there is only on driver near the rider.
//            //  If we don't need theme we filter the driver's data base on the duration in the elements and then return the driver's data.
//            closestDriverAsTheCrowFlies.map { Pair(it, EmptyElement) }
//        }
    }

    private fun findClosestDistanceAsTheCrowFlies(
        data: DispatchRequestData,
        index: PointIndex<DriverData>
    ): List<DriverData> {
        val closestPointQuery = ClosestPointQuery(index, distanceQueryOptions)
        driverDataCache.addOnDataChangedListener(closestPointQuery::reInit)
        try {
            val target = ClosestPointQuery.S2ClosestPointQueryPointTarget(data.pickUpLocation.toCellID().toPoint())
            val closestPoints = closestPointQuery.findClosestPoints(target)
            return closestPoints.map { it.data() }
        } finally {
            driverDataCache.removeOnDataChangedListener(closestPointQuery::reInit)
        }
    }

    private fun findClosestDistanceOnRoad(
        driversData: List<DriverData>,
        riderLocation: Location
    ): List<Pair<DriverData, DistanceMatrixElement>> {
        val driverLocations = driversData.map { it.location }
        val closestDriver = mutableListOf<Pair<DriverData, DistanceMatrixElement>>()
        runBlocking {
            val orderedDistanceMatrixElement = routeApiClient.distanceMatrix(driverLocations, riderLocation)
            repeat(driversData.size) {
                closestDriver.add(Pair(driversData[it], orderedDistanceMatrixElement[it]))
            }
        }
        return closestDriver
    }

}
