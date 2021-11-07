package com.hamba.dispatcher

import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.*
import com.hamba.dispatcher.services.api.RouteApiClient
import com.hamba.dispatcher.utils.closestOrExactIndexOf
import dilivia.s2.S2CellId
import kotlinx.coroutines.runBlocking
import java.util.*
import kotlin.math.max

class DistanceCalculator(
    private val driverDataRepository: DriverDataRepository,
    private val routeApiClient: RouteApiClient,
    private val driverDataList: SortedSet<DriverData>
) {

    fun getClosestDriverDistance(requestData: DispatchRequestData): List<Pair<DriverData, Element>> {
        val closestDriverAsTheCrowFlies = if (requestData.carType == null && requestData.gender == null) {
            findClosestDistanceAsTheCrowFlies(requestData.location)
        } else {
            findClosestDistanceAsTheCrowFlies(requestData)
        }
        return findClosestDistanceOnRoad(closestDriverAsTheCrowFlies, requestData.location)
    }

    private fun findClosestDistanceAsTheCrowFlies(data: DispatchRequestData): List<DriverData> {
        val cellId = data.location.toCellID()
        val minBoundary = indexOfDriverClosestToCellId(cellId.parent(12/*From 3 to 5 Km radius*/).rangeMin().id)
        val maxBoundary = indexOfDriverClosestToCellId(cellId.parent(12/*From 3 to 5 Km radius*/).rangeMax().id)
        val minIndex = indexOfDriverClosestToCellId(cellId.id)
        val maxIndex = minIndex + 1
        val closestDrivers = mutableListOf<DriverData>()
        var driverAtMaxIndex = getNextFilteredClosestDriver(arrayOf(maxIndex), data, 1)
        var driverAtMinIndex = getNextFilteredClosestDriver(arrayOf(minIndex), data, -1)
        var difference: Long
        while (closestDrivers.size < 4 && driverAtMaxIndex != null && driverAtMinIndex != null) {
            difference = ((cellId.id - driverAtMinIndex.cellId).toLong()
                    - (driverAtMaxIndex.cellId - cellId.id).toLong())
            if (difference < 0) {
                closestDrivers.add(driverAtMinIndex)
                driverAtMinIndex = getNextFilteredClosestDriver(arrayOf(minIndex), data, -1, maxBoundary, minBoundary)
                    ?: break // Return null when no driver match filter in that direction and start of the list reached.
            } else if (difference > 0) {
                closestDrivers.add(driverAtMaxIndex)
                driverAtMaxIndex = getNextFilteredClosestDriver(arrayOf(maxIndex), data, 1, maxBoundary, minBoundary)
                    ?: break // Return null when no driver match filter in that direction and end of the list reached.
            } else {
                closestDrivers.add(driverAtMinIndex)
                closestDrivers.add(driverAtMaxIndex)
                driverAtMinIndex = getNextFilteredClosestDriver(arrayOf(minIndex), data, -1, maxBoundary, minBoundary)
                    ?: break // Return null when no driver match filter in that direction and start of the list reached.
                driverAtMaxIndex = getNextFilteredClosestDriver(arrayOf(maxIndex), data, 1, maxBoundary, minBoundary)
                    ?: break // Return null when no driver match filter in that direction and end of the list reached.
            }
        }

        if (driverAtMaxIndex == null) {
            while (closestDrivers.size < 4 && driverAtMinIndex != null) {
                closestDrivers.add(driverAtMinIndex)
                driverAtMinIndex = getNextFilteredClosestDriver(arrayOf(minIndex), data, -1, maxBoundary, minBoundary)
                    ?: break // Return null when no driver match filter in that direction and start of the list reached.
            }
        } else if (driverAtMinIndex == null) {
            while (closestDrivers.size < 4 && driverAtMaxIndex != null) {
                closestDrivers.add(driverAtMaxIndex)
                driverAtMaxIndex = getNextFilteredClosestDriver(arrayOf(maxIndex), data, 1, maxBoundary, minBoundary)
                    ?: break // Return null when no driver match filter in that direction and end of the list reached.
            }
        }

        return closestDrivers
    }

    private fun getNextFilteredClosestDriver(
        indexWrapper: Array<Int>,
        data: DispatchRequestData,
        step: Int,
        maxIndex: Int = driverDataList.size - 1,
        minIndex: Int = 0
    ): DriverData? {
        var index = indexWrapper[0]
        var driverData: DriverData
        while (index in minIndex..maxIndex) {
            driverData = driverDataList.elementAt(index)
            if ((data.gender == null || data.gender == driverData.gender)
                && (data.carType == null || data.carType == driverData.carType)
            ) {
                return driverData
            }
            indexWrapper[0] += step
            index = indexWrapper[0]
        }
        return null
    }

    private fun findClosestDistanceAsTheCrowFlies(location: Location): List<DriverData> {
        val closestDrivers = mutableListOf<DriverData>()
        val cellId = location.toCellID().id
        var minIndex = indexOfDriverClosestToCellId(cellId)
        var maxIndex = minIndex + 1
        var difference: Long

        while (closestDrivers.size < 4 && minIndex >= 0 && maxIndex < driverDataList.size) {
            difference = ((cellId - driverDataList.elementAt(minIndex).cellId).toLong()
                    - (driverDataList.elementAt(maxIndex).cellId - cellId).toLong())
            if (difference < 0) {
                closestDrivers.add(driverDataList.elementAt(minIndex--))
            } else if (difference > 0) {
                closestDrivers.add(driverDataList.elementAt(maxIndex++))
            } else {
                closestDrivers.add(driverDataList.elementAt(minIndex--))
                closestDrivers.add(driverDataList.elementAt(maxIndex++))
            }
        }

        if (minIndex <= 0) {
            while (closestDrivers.size < 4 && maxIndex < driverDataList.size) {
                closestDrivers.add(driverDataList.elementAt(maxIndex++))
            }
        } else if (maxIndex >= driverDataList.size - 1) {
            while (closestDrivers.size < 4 && minIndex >= 0) {
                closestDrivers.add(driverDataList.elementAt(minIndex--))
            }
        }

        return closestDrivers
    }

    private fun indexOfDriverClosestToCellId(
        cellId: ULong,
        startIndex: Int = 0,
        endIndex: Int = driverDataList.size
    ): Int {
        // Binary Search
        if (startIndex > endIndex) return startIndex
        val middleIndex = (endIndex + startIndex) / 2
        val middleElement = driverDataList.elementAt(middleIndex)
        return if (middleElement.cellId < cellId) {
            indexOfDriverClosestToCellId(cellId, middleIndex + 1, endIndex)
        } else if (middleElement.cellId > cellId) {
            indexOfDriverClosestToCellId(cellId, startIndex, middleIndex - 1)
        } else {
            middleIndex
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
