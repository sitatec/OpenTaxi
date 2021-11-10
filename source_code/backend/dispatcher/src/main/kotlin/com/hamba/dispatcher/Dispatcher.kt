package com.hamba.dispatcher

import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.DispatchData
import com.hamba.dispatcher.data.model.DispatchRequestData
import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.data.model.Element
import com.hamba.dispatcher.services.api.RouteApiClient
import io.ktor.http.cio.websocket.*
import io.ktor.websocket.*
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class Dispatcher(
    private val distanceCalculator: DistanceCalculator,
    private val driverConnections: MutableMap<String, DefaultWebSocketServerSession>,
    private val routeApiClient: RouteApiClient,
    private val driverDataRepository: DriverDataRepository,
    private val dispatchDataList: MutableMap<String, DispatchData>
) {

    suspend fun dispatch(
        dispatchRequestData: DispatchRequestData,
        riderConnection: DefaultWebSocketServerSession
    ) {
        val closestDrivers = distanceCalculator.getClosestDriverDistance(dispatchRequestData)
        val dispatchData = DispatchData(closestDrivers, dispatchRequestData, riderConnection)
        dispatchDataList[dispatchRequestData.riderId] = dispatchData
        bookNextClosestDriver(dispatchData)
    }

    @OptIn(ExperimentalSerializationApi::class)
    private suspend fun bookNextClosestDriver(dispatchData: DispatchData) {
        // TODO make a timeout for the current closest drivers to be invalidated a new ones found.
        val closestDriver = dispatchData.getNextClosestCandidateOrNull()
        if (closestDriver == null) {// All the closest driver have refused or not responded to the booking request.
            dispatchData.riderConnection.send("no:")
        } else {
            val closestDriverConnection = driverConnections[closestDriver.first.driverId]!! // TODO handle when null
            val dispatchRequestDataJson = Json.encodeToString(dispatchData.dispatchRequestData)
            closestDriverConnection.send("b:$dispatchRequestDataJson")
            driverDataRepository.deleteDriverData(closestDriver.first.driverId) // Once we send a booking request to the
            // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.
            val driverDataAsJson = Json.encodeToString(closestDriver)
            dispatchData.riderConnection.send(/* bs = BOOKING SENT */"bs:${driverDataAsJson}")
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
        // TODO when accepted create trip tracking "room" and delete all data related to this booking.
    }

    suspend fun onBookingRefused(dispatchData: DispatchData) {
        driverDataRepository.addDriverData(dispatchData.getCurrentCandidate().first) // Available for new bookings.
        dispatchData.riderConnection.send("no:${dispatchData.nextClosestCandidateIndex}")
        bookNextClosestDriver(dispatchData)
    }

    suspend fun onBookingCanceled(riderId: String) {
        val dispatchData = dispatchDataList[riderId]
        if (dispatchData == null) {
            // TODO handle
        } else {
            val driverConnection = driverConnections[dispatchData.getCurrentCandidate().first.driverId]
            driverConnection?.send("c:$riderId" /*CANCEL*/)
            driverDataRepository.addDriverData(dispatchData.getCurrentCandidate().first) // Available for new bookings.
            dispatchData.riderConnection.close(CloseReason(CloseReason.Codes.NORMAL, ""))
        }
        dispatchDataList.remove(riderId)
    }

    suspend fun onRiderDisconnect(riderId: String) {
        dispatchDataList.remove(riderId)?.let {
            val currentCandidateConnection = driverConnections[it.getCurrentCandidate().first.driverId]
            currentCandidateConnection?.send(/*DISCONNECTED*/"dis:$riderId")// Notify the driver that we sent a
            // booking request that the rider is disconnected
            driverDataRepository.addDriverData(it.getCurrentCandidate().first) // Available for new bookings.
        }
    }

    suspend fun onDriverDisconnect(driverId: String) {
        // TODO Refactor, test, and document
        driverConnections.remove(driverId)
        driverDataRepository.deleteDriverData(driverId)
        var notifyRiderAndBookNext: suspend () -> Unit = {}
        dispatchDataList.forEach { (_, dispatchData) ->
            dispatchData.candidates.removeIf { candidate ->
                if (candidate.first.driverId == driverId) {
                    if (dispatchData.getCurrentCandidate().first.driverId == driverId) {
                        notifyRiderAndBookNext = {
                            dispatchData.riderConnection.send("dis:$driverId")
                            bookNextClosestDriver(dispatchData)
                        }
                    }
                    true
                } else false
            }
        }
        notifyRiderAndBookNext()
    }
}