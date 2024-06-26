package com.hamba.dispatcher

import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.DirectionAPIResponse
import com.hamba.dispatcher.websockets.FrameType.*
import com.hamba.dispatcher.data.model.DispatchData
import com.hamba.dispatcher.data.model.DispatchRequestData
import com.hamba.dispatcher.services.api.DataAccessClient
import com.hamba.dispatcher.services.api.RouteApiClient
import com.hamba.dispatcher.services.sdk.RealTimeDatabase
import com.hamba.dispatcher.utils.formatDistanceAndDuration
import com.hamba.dispatcher.utils.getTotalDistanceAndDurationFromDirections
import com.hamba.dispatcher.utils.toJsonForDataAccessServer
import io.ktor.http.cio.websocket.*
import io.ktor.websocket.*
import kotlinx.coroutines.isActive
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.*
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

    suspend fun initialize(
        dispatchRequestData: DispatchRequestData,
        riderConnection: DefaultWebSocketServerSession
    ) {
        // [consecutiveLocations] contains all the location from the rider's location (pickup location), passing through
        // all the stops, to the rider's destination (drop off location). The following order must be respected: pickup, stops, drop off.
        val consecutiveLocations = listOf(
            dispatchRequestData.pickUpLocation,
            *dispatchRequestData.stops.toTypedArray(),
            dispatchRequestData.dropOffLocation,
        )
        val departureTime = dispatchRequestData.timestamp?.toString() ?: "now"
        val dispatchData =
            DispatchData(
                dispatchRequestData.riderId,
                dispatchRequestData,
                riderConnection,
                routeApiClient.getConsecutiveDirections(consecutiveLocations, departureTime),
            )
        dispatchDataList[dispatchRequestData.riderId] = dispatchData
        val tripInfo = Json.encodeToString(dispatchData.getTripInfoAsJsonObject())
        riderConnection.send("$TRIP_INFO:$tripInfo")
    }

    suspend fun dispatch(dispatchData: DispatchData) {
        val closestDrivers = distanceCalculator.getClosestDriverDistance(
            dispatchData.dispatchRequestData,
            isFutureBooking = dispatchData.dispatchRequestData.isFutureBookingRequest(),
        )
        if (closestDrivers.isEmpty()) {
            dispatchData.riderConnection.send("$NO_MORE_DRIVER_AVAILABLE:")
        }
        dispatchData.candidates = closestDrivers.toMutableList()
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
                val driverDataAsMap = mutableMapOf(
                    "nam" to closestDriver.first.name,
                    "idx" to dispatchData.numberOfCandidateProvided,
                )
                if (!dispatchData.dispatchRequestData.isFutureBookingRequest()) {
                    driverDataAsMap["dis"] = closestDriver.second.distance.text
                    driverDataAsMap["dur"] = closestDriver.second.durationInTraffic.text
                }
                val driverDataAsJson = Json.encodeToString(driverDataAsMap)
                dispatchData.riderConnection.send(/* bs = BOOKING SENT */"$BOOKING_SENT:${driverDataAsJson}")
                if (!dispatchData.dispatchRequestData.isFutureBookingRequest()) {
                    driverDataRepository.deleteDriverData(closestDriver.first.driverId) // Once we send a booking request to the
                    // driver he/she shouldn't be available for until he refuse the booking or he/she complete it. (Only for normal booking, not future booking).
                }
            }
        }

    }

    private fun buildBookingRequestData(dispatchRequestData: DispatchRequestData): String {
        val distanceAndDuration =
            dispatchDataList[dispatchRequestData.riderId]!!.tripDistanceAndDuration
        val formattedDistanceAndDuration =
            formatDistanceAndDuration(distance = distanceAndDuration.first, duration = distanceAndDuration.second)
        val data = buildJsonObject {
            put("id", dispatchRequestData.riderId)
            put("nam", dispatchRequestData.riderName)
            put("pic", dispatchRequestData.pickUpLocation.formattedAddress)
            put("drp", dispatchRequestData.dropOffLocation.formattedAddress)
            put("pym", dispatchRequestData.paymentMethod)
            put("dis", formattedDistanceAndDuration.first)
            put("dur", formattedDistanceAndDuration.second)
            if (dispatchRequestData.isFutureBookingRequest()) {
                put("tim", dispatchRequestData.timestamp)
            }
            putJsonArray("stp") {
                dispatchRequestData.stops.forEach { add(it.formattedAddress) }
            }
        }
        return Json.encodeToString(data)
    }

    suspend fun onBookingAccepted(
        dispatchData: DispatchData,
        realTimeDatabase: RealTimeDatabase,
        dataAccessClient: DataAccessClient
    ) {
        // TODO refactor reduce the size of this method.
        if (dispatchData.currentBookingRequestTimeout?.cancel() != false) {
            val driverId = dispatchData.getCurrentCandidate().first.driverId
            val driverConnection = driverConnections[driverId]
            if (driverConnection == null) {
                dispatchData.riderConnection.send("$PAIR_DISCONNECTED:$driverId")
                bookNextClosestDriver(dispatchData)
            } else if (dispatchData.dispatchRequestData.isFutureBookingRequest()) {
                createBooking(dispatchData, dataAccessClient)
                dispatchData.riderConnection.send("$ACCEPT_BOOKING:$driverId")
                dispatchDataList.remove(dispatchData.id)
                Timer().schedule(60_000) {
                    if (dispatchData.riderConnection.isActive) {
                        runBlocking {
                            dispatchData.riderConnection.close(
                                CloseReason(
                                    CloseReason.Codes.NORMAL,
                                    "Close connection after booking accepted by the driver."
                                )
                            )
                        }
                    }
                }
            } else {
                val tripAndBookingIds = createTripWithBooking(dispatchData, dataAccessClient)
                val pickupDirectionData = Json.decodeFromString<DirectionAPIResponse>(
                    routeApiClient.findDirection(
                        dispatchData.getCurrentCandidate().first.location,
                        dispatchData.getDestination(),
                    )
                )
                val pickupDirectionPolylines = mutableListOf<String>()
                pickupDirectionData.routes.forEach { route ->
                    route.legs.forEach { leg ->
                        pickupDirectionPolylines.addAll(leg.steps.map { step -> step.polyline!!.points!! })
                    }
                }

                val tripDistanceAndDuration = dispatchData.tripDistanceAndDuration
                val pickupDistanceAndDuration = getTotalDistanceAndDurationFromDirections(listOf(pickupDirectionData))

                val tripRoomData = mutableMapOf(
                    "driver" to driverId,
                    "rider" to dispatchData.id,
                    "est" to mapOf(
                        "trip" to mapOf(
                            "dis" to tripDistanceAndDuration.first,
                            "dur" to tripDistanceAndDuration.second
                        ),
                        "pickup" to mapOf(
                            "dis" to pickupDistanceAndDuration.first,
                            "dur" to pickupDistanceAndDuration.second
                        )
                    ),
                    "dir" to mapOf(
                        "pickup" to Json.encodeToString(pickupDirectionPolylines),
                        "trip" to Json.encodeToString(dispatchData.tripDirectionPolylines)
                    )// TODO add estimated distance and duration.
                )
                val tripId = tripAndBookingIds["trip_id"]
                val bookingId = tripAndBookingIds["booking_id"]
                realTimeDatabase.putData("trip_rooms/$tripId", tripRoomData)
                dispatchData.riderConnection.send("$ACCEPT_BOOKING:$driverId")
                dispatchData.riderConnection.send("$BOOKING_ID:$bookingId")
                driverConnection.send("$BOOKING_ID:$bookingId")
                dispatchData.riderConnection.send("$TRIP_ROOM:$tripId")
                driverConnection.send("$TRIP_ROOM:$tripId")
                dispatchDataList.remove(dispatchData.id)
                Timer().schedule(60_000) {
                    if (dispatchData.riderConnection.isActive) {
                        runBlocking {
                            dispatchData.riderConnection.close(
                                CloseReason(
                                    CloseReason.Codes.NORMAL,
                                    "Close connection after booking accepted by the driver."
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    private suspend fun createTripWithBooking(
        dispatchData: DispatchData,
        dataAccessClient: DataAccessClient
    ): Map<String, String> {
        val tripData = JsonObject(
            mapOf(
                "pickup_address" to dispatchData.dispatchRequestData.pickUpLocation.toJsonForDataAccessServer(),
                "dropoff_address" to dispatchData.dispatchRequestData.dropOffLocation.toJsonForDataAccessServer(),
                "booking" to buildJsonObject {
                    put("rider_id", dispatchData.dispatchRequestData.riderId)
                    put("driver_id", dispatchData.getCurrentCandidate().first.driverId)
                },
                "trip" to buildJsonObject { }
            ),
        )
        return dataAccessClient.createTripWithBooking(tripData)
    }

    private suspend fun createBooking(
        dispatchData: DispatchData,
        dataAccessClient: DataAccessClient
    ): String {
        val bookingData = JsonObject(
            mapOf(
                "pickup_address" to dispatchData.dispatchRequestData.pickUpLocation.toJsonForDataAccessServer(),
                "dropoff_address" to dispatchData.dispatchRequestData.dropOffLocation.toJsonForDataAccessServer(),
                "booking" to buildJsonObject {
                    put("rider_id", dispatchData.dispatchRequestData.riderId)
                    put("driver_id", dispatchData.getCurrentCandidate().first.driverId)
                },
            ),
        )
        return dataAccessClient.createBooking(bookingData)
    }

    suspend fun onBookingRefused(dispatchData: DispatchData) {
        if (dispatchData.currentBookingRequestTimeout?.cancel() != false) {
            if (!dispatchData.dispatchRequestData.isFutureBookingRequest()) {
                driverDataRepository.addDriverData(dispatchData.getCurrentCandidate().first) // Available for new bookings. (but we don't remove the driver data for future booking, so we don't need to add it)
            }
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
            if (!dispatchData.dispatchRequestData.isFutureBookingRequest()) {
                driverDataRepository.addDriverData(dispatchData.getCurrentCandidate().first) // Available for new bookings. (but we don't remove the driver data for future booking, so we don't need to add it)
            }
        }
        dispatchData.riderConnection.close(CloseReason(CloseReason.Codes.NORMAL, ""))
        dispatchDataList.remove(dispatchId)
    }

    suspend fun onRiderDisconnect(riderId: String) {
        dispatchDataList.remove(riderId)?.let { dispatchData ->
            val currentCandidate = dispatchData.getCurrentCandidate().first
            val currentCandidateConnection = driverConnections[currentCandidate.driverId]
            currentCandidateConnection?.send("${PAIR_DISCONNECTED}:$riderId")// Notify the driver that we sent a
            // booking request that the rider is disconnected
            if (!dispatchData.dispatchRequestData.isFutureBookingRequest()) {
                driverDataRepository.addDriverData(dispatchData.getCurrentCandidate().first) // Available for new bookings. (but we don't remove the driver data for future booking, so we don't need to add it)
            }
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