package com.hamba.dispatcher.websockets

import com.hamba.dispatcher.Dispatcher
import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.DispatchData
import com.hamba.dispatcher.data.model.DispatchRequestData
import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.data.model.Location
import io.ktor.application.*
import io.ktor.http.cio.websocket.*
import io.ktor.routing.*
import io.ktor.utils.io.*
import io.ktor.websocket.*
import kotlinx.coroutines.channels.ClosedReceiveChannelException
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json


@OptIn(ExperimentalSerializationApi::class)
fun Application.webSocketsServer(
    driverConnections: MutableMap<String, DefaultWebSocketServerSession>,
    driverDataRepository: DriverDataRepository,
    dispatchDataList: MutableMap<String, DispatchData>,
    dispatcher: Dispatcher,
) {
    // TODO Take into account cancellation
    install(WebSockets)

    routing {
        webSocket("driver") {
            var receivedText: String
            var driverId: String? = null
            try {
                for (frame in incoming) {
                    if (frame !is Frame.Text) continue
                    receivedText = frame.readText()
                    when (receivedText.substringBefore(":")) {
                        "a" /*ADD*/ -> {
                            val driverData = Json.decodeFromString<DriverData>(receivedText.substringAfter(":"))
                            driverConnections[driverData.driverId] = this
                            driverDataRepository.addDriverData(driverData)
                            driverId = driverData.driverId
                        }
                        "u" /*UPDATE*/ -> {
                            if (driverId == null) {// Should add data before updating it.
                                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
                            }
                            val (latitude, longitude) = receivedText.substringAfter(":").split(",")
                            val location = Location(latitude.toDouble(), longitude.toDouble())
                            driverDataRepository.updateDriverData(driverId!!, location)
                        }
                        "d" /*DELETE/DISCONNECT*/ -> {
                            if (driverId == null) {// Should add data before deleting it
                                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
                            }
                            driverDataRepository.deleteDriverData(driverId!!)
                            close(CloseReason(CloseReason.Codes.NORMAL, ""))
                        }
                        "yes" /*ACCEPT BOOKING*/ -> {
                            val dispatchDataId = receivedText.substringAfter(":")
                            val dispatchData = dispatchDataList[dispatchDataId]
                            if (dispatchData == null) {// Invalid id or that data have been already removed
                                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
                            } else {
                                dispatcher.onBookingAccepted(dispatchData)
                            }
                        }
                        "no" /*REFUSE BOOKING*/ -> {
                            val dispatchDataId = receivedText.substringAfter(":")
                            val dispatchData = dispatchDataList[dispatchDataId]
                            if (dispatchData == null) {// Invalid id or that data have been already removed
                                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
                            } else {
                                dispatcher.onBookingRefused(dispatchData)
                            }
                        }
                    }
                }
            } catch (e: ClosedReceiveChannelException) {
                println("driverId = $driverId | message = Connection closed for ${closeReason.await()}")
            } catch (e: Exception) {
                println("driverId = $driverId | message = ${e.localizedMessage}")
                e.printStack()
            } finally {
                driverId?.let {dispatcher.onDriverDisconnect(it)}
            }
        }

        webSocket("dispatch") {
            // TODO include the rider location to the stop's list.
            var riderId = ""
            var receivedText: String
            try {
                for (frame in incoming) {
                    if (frame !is Frame.Text) continue
                    receivedText = frame.readText()
                    when (receivedText.substringBefore(":")) {
                        "d" /*DISPATCH REQUEST*/ -> {
                            val dispatchRequestData =
                                Json.decodeFromString<DispatchRequestData>(receivedText.substringAfter(":"))
                            riderId = dispatchRequestData.riderId
                            dispatcher.dispatch(dispatchRequestData, this)
                        }
                        "c" /*CANCEL*/ -> {
                            val dispatchData = dispatchDataList[riderId]
                            if (dispatchData == null) {
                                // TODO handle
                            } else {
                                dispatcher.onBookingCanceled(riderId)
                            }
                        }
                    }
                }
            } catch (e: ClosedReceiveChannelException) {
                println("riderId = $riderId | message = Connection closed for ${closeReason.await()}")
            } catch (e: Exception) {
                println("riderId = $riderId | message = ${e.localizedMessage} \n trace = ")
                e.printStack()
            } finally {
                dispatcher.onRiderDisconnect(riderId)
            }
        }
    }
}