package com.hamba.dispatcher

import com.hamba.dispatcher.data.model.*
import com.hamba.dispatcher.services.api.RouteApiClient
import dilivia.s2.S1Angle
import dilivia.s2.S2Earth
import dilivia.s2.index.S2MinDistance
import kotlinx.coroutines.runBlocking

class DistanceCalculator(
    private val routeApiClient: RouteApiClient,
    private val driverDataCache: DriverPointDataCache,
    private val distanceQueryOptions: ClosestPointQuery.Options = ClosestPointQuery.Options(
//        maxDistance = S2MinDistance(S1Angle.radians(S2Earth.kmToRadians(3.0))),
        maxResult = 4
    )
) {

    fun getClosestDriverDistance(requestData: DispatchRequestData): List<Pair<DriverData, Element>> {
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
        // TODO if their is only one driver near the rider avoid distance matrix request.
        return findClosestDistanceOnRoad(closestDriverAsTheCrowFlies, requestData.location)
    }

    private fun findClosestDistanceAsTheCrowFlies(
        data: DispatchRequestData,
        index: PointIndex<DriverData>
    ): List<DriverData> {
        val closestPointQuery = ClosestPointQuery(index, distanceQueryOptions)
        driverDataCache.addOnDataChangedListener(closestPointQuery::reInit)
        try {
            val target = ClosestPointQuery.S2ClosestPointQueryPointTarget(data.location.toCellID().toPoint())
            val r = closestPointQuery.findClosestPoints(target)
            return r.map { it.data() }
        } finally {
            driverDataCache.removeOnDataChangedListener(closestPointQuery::reInit)
        }
    }

    private fun findClosestDistanceOnRoad(
        driversData: List<DriverData>,
        riderLocation: Location
    ): List<Pair<DriverData, Element>> {
        val driverLocations = driversData.map { it.location }
        val closestDriver = mutableListOf<Pair<DriverData, Element>>()
        runBlocking {
            val orderedDistanceMatrixElement = routeApiClient.distanceMatrix(driverLocations, riderLocation)
            repeat(driversData.size) {
                closestDriver.add(Pair(driversData[it], orderedDistanceMatrixElement[it]))
            }
        }
        return closestDriver
    }

}
