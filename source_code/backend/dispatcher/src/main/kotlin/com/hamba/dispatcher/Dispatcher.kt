package com.hamba.dispatcher

import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.websockets.FrameType.*
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
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
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
            riderConnection.send("$NO_MORE_DRIVER_AVAILABLE:")
        }
        // [consecutiveLocations] contains all the location from the rider's location (pickup location), passing through
        // all the stops, to the rider's destination (drop off location). The following order must be respected: pickup, stops, drop off.
        val consecutiveLocations = listOf(
            dispatchRequestData.pickUpLocation,
            *dispatchRequestData.stops.toTypedArray(),
            dispatchRequestData.dropOffLocation,
        )
        val dispatchData =
            DispatchData(
                dispatchRequestData.riderId,
                closestDrivers,
                dispatchRequestData,
                riderConnection,
                routeApiClient.getConsecutiveDirections(consecutiveLocations),
            )
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
            dispatchData.riderConnection.send("$NO_MORE_DRIVER_AVAILABLE:")
            dispatchDataList.remove(dispatchData.id)
        } else {
            val closestDriverConnection = driverConnections[closestDriver.first.driverId]
            if (closestDriverConnection == null) {
                dispatchData.riderConnection.send("$PAIR_DISCONNECTED:${closestDriver.first.driverId}")
                bookNextClosestDriver(dispatchData)
            } else {
                val dispatchRequestDataJson = buildBookingRequestData(dispatchData.dispatchRequestData)
                closestDriverConnection.send("$BOOKING_REQUEST:$dispatchRequestDataJson")
                dispatchData.currentBookingRequestTimeout = bookingTimeoutScheduler.schedule(bookingRequestTimeoutMs) {
                    runBlocking {
                        closestDriverConnection.send("$BOOKING_REQUEST_TIMEOUT:"/*TIMEOUT*/)
                        dispatchData.riderConnection.send("$BOOKING_REQUEST_TIMEOUT:${dispatchData.numberOfCandidateProvided}")
                        driverDataRepository.addDriverData(closestDriver.first) // Available again for new booking
                        bookNextClosestDriver(dispatchData)
                    }
                }
                val driverDataAsJson = Json.encodeToString(closestDriver)
                dispatchData.riderConnection.send(/* bs = BOOKING SENT */"$BOOKING_SENT:${driverDataAsJson}")
                driverDataRepository.deleteDriverData(closestDriver.first.driverId) // Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.
            }
        }

    }

    private fun buildBookingRequestData(dispatchRequestData: DispatchRequestData): String {
        val distanceAndDuration =
            dispatchDataList[dispatchRequestData.riderId]!!.getDistanceAndDurationFromPickupToDropOff()
        val data = mapOf(
            "id" to dispatchRequestData.riderId,
            "nam" to dispatchRequestData.riderName,
            "pic" to dispatchRequestData.pickUpLocation.formattedAddress,
            "drp" to dispatchRequestData.dropOffLocation.formattedAddress,
            "pym" to dispatchRequestData.paymentMethod,
            "dis" to distanceAndDuration.first,
            "dur" to distanceAndDuration.second,
            "stp" to Json.encodeToString(dispatchRequestData.stops.map { it.formattedAddress })
        )
        return Json.encodeToString(data)
    }

    suspend fun onBookingAccepted(dispatchData: DispatchData, firebaseDatabaseWrapper: FirebaseDatabaseWrapper) {
        if (dispatchData.currentBookingRequestTimeout?.cancel() != false) {
            val driverId = dispatchData.getCurrentCandidate().first.driverId
            val driverConnection = driverConnections[driverId]
            if (driverConnection == null) {
                dispatchData.riderConnection.send("$PAIR_DISCONNECTED:$driverId")
                bookNextClosestDriver(dispatchData)
            } else {
                val pickupDirectionData = routeApiClient.findDirection(
                    dispatchData.getCurrentCandidate().first.location,
                    dispatchData.getDestination(),
                )
                val tripDirectionData = Json.encodeToString(dispatchData.directions)
                val tripRoomData = mutableMapOf(
                    "rider" to dispatchData.id,
                    "dir" to mapOf("pickup" to pickupDirectionData, "trip" to tripDirectionData)
                )
                firebaseDatabaseWrapper.putData("trip_rooms/$driverId", tripRoomData)
                dispatchData.riderConnection.send("$ACCEPT_BOOKING:$driverId")
                dispatchData.riderConnection.close(CloseReason(CloseReason.Codes.NORMAL, ""))
                driverConnection.send("$TRIP_ROOM:$driverId")
                dispatchDataList.remove(dispatchData.id)
            }
        }
    }

    suspend fun onBookingRefused(dispatchData: DispatchData) {
        if (dispatchData.currentBookingRequestTimeout?.cancel() != false) {
            driverDataRepository.addDriverData(dispatchData.getCurrentCandidate().first) // Available for new bookings.
            dispatchData.riderConnection.send("${REFUSE_BOOKING}:${dispatchData.numberOfCandidateProvided}")
            bookNextClosestDriver(dispatchData)
        }
    }

    suspend fun onDispatchCanceled(dispatchId: String) {
        val dispatchData = dispatchDataList[dispatchId]
            ?: throw IllegalStateException("A Dispatching process that have not been initialized cannot be cancelled.\nYou may see this exception if you are trying to cancel a dispatch that is not in the dispatch list")

        val currentCandidate = dispatchData.getCurrentCandidate().first
        val driverConnection = driverConnections[currentCandidate.driverId]
        if (driverConnection != null) {
            driverConnection.send("${CANCEL_BOOKING}:$dispatchId")
            driverDataRepository.addDriverData(currentCandidate) // Available for new bookings.
        }
        dispatchData.riderConnection.close(CloseReason(CloseReason.Codes.NORMAL, ""))
        dispatchDataList.remove(dispatchId)
    }

    suspend fun onRiderDisconnect(riderId: String) {
        dispatchDataList.remove(riderId)?.let {
            val currentCandidate = it.getCurrentCandidate().first
            val currentCandidateConnection = driverConnections[currentCandidate.driverId]
            currentCandidateConnection?.send("${PAIR_DISCONNECTED}:$riderId")// Notify the driver that we sent a
            // booking request that the rider is disconnected
            driverDataRepository.addDriverData(currentCandidate) // Available for new bookings.
        }
    }

    suspend fun onDriverDisconnect(driverId: String) {
        // TODO Refactor, test, and document
        driverDataRepository.deleteDriverData(driverId)
        driverConnections.remove(driverId)
        var notifyRiderAndBookNext: suspend () -> Unit = {}
        dispatchDataList.forEach { (_, dispatchData) ->
            dispatchData.candidates.removeIf { candidate ->
                if (candidate.first.driverId == driverId) {
                    if (dispatchData.getCurrentCandidate().first.driverId == driverId) {
                        notifyRiderAndBookNext = {
                            dispatchData.riderConnection.send("${PAIR_DISCONNECTED}:$driverId")
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