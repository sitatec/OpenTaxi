package com.hamba.dispatcher

import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.DriverPointDataCache
import com.hamba.dispatcher.data.model.DispatchData
import com.hamba.dispatcher.data.model.DispatchRequestData
import com.hamba.dispatcher.services.api.RouteApiClient
import com.hamba.dispatcher.services.sdk.FirebaseDatabaseWrapper
import io.ktor.http.cio.websocket.*
import io.ktor.websocket.*
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.util.*
import kotlin.concurrent.schedule

class Dispatcher(
    private val distanceCalculator: DistanceCalculator,
    private val driverConnections: MutableMap<String, DefaultWebSocketServerSession>,
    private val routeApiClient: RouteApiClient,
    private val driverDataRepository: DriverDataRepository,
    private val dispatchDataList: MutableMap<String, DispatchData>,
    private val bookingRequestTimeoutMs: Long = 60_000
) {

    private val bookingTimeoutScheduler = Timer()

    suspend fun dispatch(
        dispatchRequestData: DispatchRequestData,
        riderConnection: DefaultWebSocketServerSession
    ) {
        val closestDrivers = distanceCalculator.getClosestDriverDistance(dispatchRequestData)
        if (closestDrivers.isEmpty()) {
            riderConnection.send("no:")
        }
        val dispatchData = DispatchData(dispatchRequestData.riderId, closestDrivers, dispatchRequestData, riderConnection)
        dispatchDataList[dispatchRequestData.riderId] = dispatchData
        bookNextClosestDriver(dispatchData)
    }

    @OptIn(ExperimentalSerializationApi::class)
    private suspend fun bookNextClosestDriver(dispatchData: DispatchData) {
        // TODO refactor
        val closestDriver = dispatchData.getNextClosestCandidateOrNull()
        if (closestDriver == null) {// All the closest driver have refused or not responded to the booking request.
            // TODO handle in case the rider remake a dispatch request to skip the ones that have already refused in the previous request
            //  (only if there is less than some amount of time elapsed between the two request)
            dispatchData.riderConnection.send("no:")
            dispatchDataList.remove(dispatchData.id)
        } else {
            val closestDriverConnection = driverConnections[closestDriver.first.driverId]
            if(closestDriverConnection == null) {
                dispatchData.riderConnection.send("dis:${closestDriver.first.driverId}")
                bookNextClosestDriver(dispatchData)
            } else {
                val dispatchRequestDataJson = Json.encodeToString(dispatchData.dispatchRequestData)
                closestDriverConnection.send("b:$dispatchRequestDataJson")
                dispatchData.currentBookingRequestTimeout = bookingTimeoutScheduler.schedule(bookingRequestTimeoutMs) {
                    runBlocking {
                        closestDriverConnection.send("to:"/*TIMEOUT*/)
                        dispatchData.riderConnection.send("to:${dispatchData.numberOfCandidateProvided}")
                        driverDataRepository.addDriverData(closestDriver.first) // Available again for new booking
                        bookNextClosestDriver(dispatchData)
                    }
                }
                val driverDataAsJson = Json.encodeToString(closestDriver)
                dispatchData.riderConnection.send(/* bs = BOOKING SENT */"bs:${driverDataAsJson}")
                driverDataRepository.deleteDriverData(closestDriver.first.driverId) // Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.
            }
        }

    }

    suspend fun onBookingAccepted(dispatchData: DispatchData, firebaseDatabaseWrapper: FirebaseDatabaseWrapper) {
        if (dispatchData.currentBookingRequestTimeout?.cancel() != false) {
            val driverId = dispatchData.getCurrentCandidate().first.driverId
            val driverConnection = driverConnections[driverId]
            if (driverConnection == null) {
                dispatchData.riderConnection.send("dis:$driverId")
                bookNextClosestDriver(dispatchData)
            } else {
                val directionData = routeApiClient.findDirection(
                    dispatchData.getCurrentCandidate().first.location,
                    dispatchData.getDestination().toString(),
                )
                val tripRoomData = mutableMapOf("driver" to driverId, "dir" to directionData)
                firebaseDatabaseWrapper.putData("trip_rooms/${dispatchData.id}", tripRoomData)
                dispatchData.riderConnection.send("yes")
                dispatchData.riderConnection.close(CloseReason(CloseReason.Codes.NORMAL, ""))
                driverConnection.send(/*ROOM*/"ro:${dispatchData.id}") // Send the trip room id to the driver
                dispatchDataList.remove(dispatchData.id)
            }
        }
    }

    suspend fun onBookingRefused(dispatchData: DispatchData) {
        if (dispatchData.currentBookingRequestTimeout?.cancel() != false) {
            driverDataRepository.addDriverData(dispatchData.getCurrentCandidate().first) // Available for new bookings.
            dispatchData.riderConnection.send("no:${dispatchData.numberOfCandidateProvided}")
            bookNextClosestDriver(dispatchData)
        }
    }

    suspend fun onDispatchCanceled(dispatchId: String) {
        val dispatchData = dispatchDataList[dispatchId]
            ?: throw IllegalStateException("A Dispatching process that have not been initialized cannot be cancelled.\nYou may see this exception if you are trying to cancel a dispatch who's not in the dis")

        val currentCandidate = dispatchData.getCurrentCandidate().first
        val driverConnection = driverConnections[currentCandidate.driverId]
        if(driverConnection != null) {
            driverConnection.send("c:$dispatchId" /*CANCEL*/)
            driverDataRepository.addDriverData(currentCandidate) // Available for new bookings.
        }
        dispatchData.riderConnection.close(CloseReason(CloseReason.Codes.NORMAL, ""))
        dispatchDataList.remove(dispatchId)
    }

    suspend fun onRiderDisconnect(riderId: String) {
        dispatchDataList.remove(riderId)?.let {
            val currentCandidate = it.getCurrentCandidate().first
            val currentCandidateConnection = driverConnections[currentCandidate.driverId]
            currentCandidateConnection?.send(/*DISCONNECTED*/"dis:$riderId")// Notify the driver that we sent a
            // booking request that the rider is disconnected
            driverDataRepository.addDriverData(currentCandidate) // Available for new bookings.
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
                            if (dispatchData.currentBookingRequestTimeout?.cancel() != false) {
                                bookNextClosestDriver(dispatchData)
                            }
                        }
                        false // The candidate(driver) will be removed in the `bookNextClosestDriver` when the `dispatchData.getNextClosestCandidateOrNull()` is called
                    } else true
                } else false
            }
        }
        notifyRiderAndBookNext()
    }
}