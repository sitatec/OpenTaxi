package com.hamba.dispatcher.controllers

import com.hamba.dispatcher.Dispatcher
import com.hamba.dispatcher.UserStatusManager
import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.*
import com.hamba.dispatcher.services.api.DataAccessClient
import com.hamba.dispatcher.services.api.RouteApiClient
import com.hamba.dispatcher.services.sdk.RealTimeDatabase
import com.hamba.dispatcher.utils.dataAccessServerAddressToLocation
import com.hamba.dispatcher.websockets.FrameType
import io.ktor.http.cio.websocket.*
import io.ktor.websocket.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.*
import java.time.Duration

class DriverController(
    private val driverDataRepository: DriverDataRepository,
    private val driverConnections: MutableMap<String, DefaultWebSocketServerSession>,
    private val dispatchDataList: MutableMap<String, DispatchData>,
    private val dispatcher: Dispatcher,
    private val userStatusManager: UserStatusManager,
) {
    @OptIn(ExperimentalSerializationApi::class)
    suspend fun addDriverData(jsonData: String, driverSession: DefaultWebSocketServerSession): String {
        val driverData = Json.decodeFromString<DriverData>(jsonData)
        if (!userStatusManager.userCanConnect(driverData.driverId)) {
            driverSession.close(
                CloseReason(
                    CloseReason.Codes.VIOLATED_POLICY,
                    "You are not allowed to connect to the server, Please contact the support."
                )
            )
            return ""
        }
        driverConnections[driverData.driverId] = driverSession
        driverDataRepository.addDriverData(driverData)
        userStatusManager.driverGoOnline(driverData.driverId)
        return driverData.driverId
    }

    suspend fun updateDriverData(driverId: String?, jsonData: String, driverSession: DefaultWebSocketServerSession) {
        if (driverId == null) {// Should add data before updating it.
            driverSession.close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
        } else {
            val (latitude, longitude) = jsonData.split(",")
            val location = Location(latitude.toDouble(), longitude.toDouble())
            driverDataRepository.updateDriverLocation(driverId, location)
        }
    }

    suspend fun deleteDriverData(driverId: String?, driverSession: DefaultWebSocketServerSession) {
        if (driverId != null) {
            // When the driver is disconnected all he's data will be removed in the websockets server's "driver" endpoint in the finally of the try/catch.
            driverSession.close(CloseReason(CloseReason.Codes.NORMAL, ""))// Normal disconnection
            userStatusManager.driverGoOffline(driverId)
        } else {
            // Should add data before deleting it.
            driverSession.close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
        }
    }

    suspend fun acceptBooking(
        driverId: String?,
        dispatchDataId: String,
        realTimeDatabase: RealTimeDatabase,
        driverSession: DefaultWebSocketServerSession,
        dataAccessClient: DataAccessClient,
    ) {
        if (driverId == null) {// Should add data before receiving booking request thus before accepting booking.
            driverSession.close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
        } else {
            val dispatchData = dispatchDataList[dispatchDataId]
            if (dispatchData == null) {// Invalid id or that data have been already removed
                driverSession.send("${FrameType.INVALID_DISPATCH_ID}:$dispatchDataId")
            } else {
                dispatcher.onBookingAccepted(dispatchData, realTimeDatabase, dataAccessClient)
            }
        }
    }

    suspend fun refuseBooking(driverId: String?, dispatchDataId: String, driverSession: DefaultWebSocketServerSession) {
        if (driverId == null) {// Should add data before receiving booking request thus before refusing booking.
            driverSession.close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
        } else {
            val dispatchData = dispatchDataList[dispatchDataId]
            if (dispatchData != null) {
                dispatcher.onBookingRefused(dispatchData)
            }
        }
    }

    suspend fun startFutureBookingTrip(
        jsonData: String,
        dataAccessClient: DataAccessClient,
        routeApiClient: RouteApiClient,
        realTimeDatabase: RealTimeDatabase,
        driverConnection: DefaultWebSocketServerSession
    ) {
        // TODO refactor

        val data = Json.decodeFromString<Map<String, String>>(jsonData)
        val bookingId = data["booking_id"]!!
        val driverCoordinates = data["coordinates"]!!.split(",")
        val driverLocation =
            Location(latitude = driverCoordinates[0].toDouble(), longitude = driverCoordinates[1].toDouble())
        val bookingAddresses = dataAccessClient.getBookingAddresses(bookingId)
        val pickupLocation = dataAccessServerAddressToLocation(bookingAddresses["pickup_address"]!!.jsonObject)
        val dropoffLocation = dataAccessServerAddressToLocation(bookingAddresses["dropoff_address"]!!.jsonObject)
        val stopLocations =
            bookingAddresses["stop_addresses"]!!.jsonArray.map { dataAccessServerAddressToLocation(it.jsonObject) }
        val consecutiveLocations = listOf(
            pickupLocation,
            *stopLocations.toTypedArray(),
            dropoffLocation,
        )
        val tripDirection = routeApiClient.getConsecutiveDirections(consecutiveLocations)
        val tripDirectionPolylines = getTripDirectionPolylines(tripDirection)

        val pickupDirection = Json.decodeFromString<DirectionAPIResponse>(
            routeApiClient.findDirection(
                origin = driverLocation,
                destination = pickupLocation
            )
        )
        val pickupDirectionPolylines = getPickupDirectionPolylines(pickupDirection)

        val tripDistanceAndDuration = getDistanceAndDurationFromPickupToDropOff(tripDirection)
        val pickupDistanceAndDuration = getDistanceAndDurationFromDriverLocationToPickup(pickupDirection)
        val tripRoomData = mutableMapOf(
            "driver" to data["driver_id"]!!,
            "rider" to data["rider_id"]!!,
            "estimates" to mapOf(
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
                "trip" to Json.encodeToString(tripDirectionPolylines)
            )// TODO add estimated distance and duration.
        )
        val tripId = dataAccessClient.createTrip(buildJsonObject {
            put("booking_id", bookingId)
        })
        realTimeDatabase.putData("trip_rooms/$tripId", tripRoomData)
        driverConnection.send("${FrameType.TRIP_ROOM}:$tripId")
        // TODO notify the rider that the driver is on his way
    }

    private fun getTripDirectionPolylines(directions: List<DirectionAPIResponse>): List<String> {
        val tripDirectionPolylines = mutableListOf<String>()
        directions.forEach {
            it.routes.forEach { route ->
                route.legs.forEach { leg ->
                    tripDirectionPolylines.addAll(leg.steps.map { step -> step.polyline!!.points!! })
                }
            }
        }
        return tripDirectionPolylines
    }

    private fun getPickupDirectionPolylines(direction: DirectionAPIResponse): List<String> {
        val pickupDirectionPolylines = mutableListOf<String>()
        direction.routes.forEach { route ->
            route.legs.forEach { leg ->
                pickupDirectionPolylines.addAll(leg.steps.map { step -> step.polyline!!.points!! })
            }
        }
        return pickupDirectionPolylines
    }

    private fun getDistanceAndDurationFromPickupToDropOff(directions: List<DirectionAPIResponse>): Pair<Long, Long> {
        var distance = 0L
        var duration = 0L
        directions.forEach {
            it.routes.forEach { route ->
                route.legs.forEach { leg ->
                    distance += leg.distance!!.value
                    duration += leg.durationInTraffic!!.value

                }
            }
        }
        return Pair(distance, duration)
    }

    private fun getDistanceAndDurationFromDriverLocationToPickup(direction: DirectionAPIResponse): Pair<Long, Long> {
        var distance = 0L
        var duration = 0L
        direction.routes.forEach { route ->
            route.legs.forEach { leg ->
                distance += leg.distance!!.value
                duration += leg.durationInTraffic!!.value

            }
        }
        return Pair(distance, duration)
    }
}