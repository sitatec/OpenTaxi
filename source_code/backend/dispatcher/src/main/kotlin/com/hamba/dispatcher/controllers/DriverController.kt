package com.hamba.dispatcher.controllers

import com.hamba.dispatcher.Dispatcher
import com.hamba.dispatcher.UserStatusManager
import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.DispatchData
import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.data.model.Location
import com.hamba.dispatcher.services.api.DataAccessClient
import com.hamba.dispatcher.services.sdk.RealTimeDatabase
import com.hamba.dispatcher.websockets.FrameType
import io.ktor.http.cio.websocket.*
import io.ktor.websocket.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

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
        if(!userStatusManager.userCanConnect(driverData.driverId)){
            driverSession.close(CloseReason(CloseReason.Codes.VIOLATED_POLICY, "You are not allowed to connect to the server, Please contact the support."))
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
        }else {
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
}