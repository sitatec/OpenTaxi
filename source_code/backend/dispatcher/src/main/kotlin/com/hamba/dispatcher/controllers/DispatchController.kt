package com.hamba.dispatcher.controllers

import com.hamba.dispatcher.UserStatusManager
import com.hamba.dispatcher.Dispatcher
import com.hamba.dispatcher.data.DriverPointDataCache
import com.hamba.dispatcher.data.model.DispatchData
import com.hamba.dispatcher.data.model.DispatchRequestData
import com.hamba.dispatcher.websockets.FrameType
import io.ktor.http.cio.websocket.*
import io.ktor.websocket.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

class DispatchController(
    private val driverDataCache: DriverPointDataCache,
    private val dispatcher: Dispatcher,
    private val dispatchDataList: MutableMap<String, DispatchData>,
    private val userStatusManager: UserStatusManager,
) {

    @OptIn(ExperimentalSerializationApi::class)
    suspend fun dispatch(requestDataJson: String, riderSession: DefaultWebSocketServerSession): String {
        var riderId = ""
        if (driverDataCache.isEmpty()) {
            riderSession.send("${FrameType.NO_MORE_DRIVER_AVAILABLE}:")
            riderSession.close(CloseReason(CloseReason.Codes.NORMAL, ""))
        } else {
            val dispatchRequestData = Json.decodeFromString<DispatchRequestData>(requestDataJson)
            riderId = dispatchRequestData.riderId
            if (userStatusManager.userCanConnect(riderId)) {
                dispatcher.dispatch(dispatchRequestData, riderSession)
            }else{
                riderSession.close(
                    CloseReason(
                        CloseReason.Codes.VIOLATED_POLICY,
                        "You are not allowed to connect to the server, Please contact the support."
                    )
                )
                return ""
            }
        }
        return riderId
    }

    suspend fun cancelDispatch(dispatchId: String, riderSession: DefaultWebSocketServerSession) {
        val dispatchData = dispatchDataList[dispatchId]
        if (dispatchData == null) { // The dispatching have not been initialized first (distance calculation is probably in progress).
            riderSession.close(CloseReason(CloseReason.Codes.NORMAL, ""))
        } else {
            dispatcher.onDispatchCanceled(dispatchId)
        }
    }

}