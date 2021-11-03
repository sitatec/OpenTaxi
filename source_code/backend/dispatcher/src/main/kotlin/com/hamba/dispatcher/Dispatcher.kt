package com.hamba.dispatcher

import com.hamba.dispatcher.model.DispatchData
import com.hamba.dispatcher.model.DispatchRequestData
import io.ktor.http.cio.websocket.*
import io.ktor.websocket.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class Dispatcher(
    private val distanceCalculator: DistanceCalculator,
    private val driverConnections: MutableMap<String, DefaultWebSocketServerSession>,
    private val routeApiClient: RouteApiClient
) {
    suspend fun dispatch(
        dispatchRequestData: DispatchRequestData,
        dispatchDataList: MutableMap<String, DispatchData>,
        riderConnection: DefaultWebSocketServerSession
    ) {
        val closestDrivers = distanceCalculator.getClosestDriverDistance(dispatchRequestData)
        val dispatchData = DispatchData(closestDrivers, dispatchRequestData, riderConnection)
        dispatchDataList[dispatchRequestData.riderId] = dispatchData
        makeBookingRequest(dispatchData)
    }

    private suspend fun makeBookingRequest(dispatchData: DispatchData) {
        val closestDriver = dispatchData.getNextClosestCandidateOrNull()
        if (closestDriver == null) {
            //TODO Handle
        } else {
            val closestDriverConnection = driverConnections[closestDriver.first.driverId]!! // TODO handle when null
            val dispatchRequestDataJson = Json.encodeToString(dispatchData.dispatchRequestData)
            closestDriverConnection.send("b:$dispatchRequestDataJson")
            val driverDataAsJson = Json.encodeToString(closestDriver)
            dispatchData.riderConnection.send(/* bs = BOOKING SENT*/"bs:${driverDataAsJson}")
        }

    }

    suspend fun onBookingAccepted(dispatchData: DispatchData) {
        dispatchData.riderConnection.send("yes")
        val directionData = routeApiClient.findDirection(
            dispatchData.getCurrentCandidate().first.location,
            dispatchData.getDestination(),
            dispatchData.getStops()
        )
        dispatchData.riderConnection.send("dir:$directionData")
        val driverConnection = driverConnections[dispatchData.getCurrentCandidate().first.driverId]
        if (driverConnection == null) {
            // TODO handle
        } else {
            driverConnection.send("dir:$directionData")
        }
    }

    suspend fun onBookingRefused(dispatchData: DispatchData) {
        dispatchData.riderConnection.send("no:${dispatchData.nextCandidateIndex}")
        makeBookingRequest(dispatchData)
    }

    suspend fun onBookingCanceled(riderId: String, dispatchDataList: MutableMap<String, DispatchData>) {
        val dispatchData = dispatchDataList[riderId]
        if(dispatchData == null) {
            // TODO handle
        }else {
            val driverConnection = driverConnections[dispatchData.getCurrentCandidate().first.driverId]
            driverConnection?.send("c:$riderId" /*CANCEL*/)
            dispatchData.riderConnection.close(CloseReason(CloseReason.Codes.NORMAL, ""))
        }
        dispatchDataList.remove(riderId)
    }
}