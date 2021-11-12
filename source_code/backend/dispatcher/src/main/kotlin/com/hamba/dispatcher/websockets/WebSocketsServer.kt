package com.hamba.dispatcher.websockets

import com.google.cloud.firestore.DocumentChange.Type.*
import com.hamba.dispatcher.Dispatcher
import com.hamba.dispatcher.data.DriverPointDataCache
import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.DispatchData
import com.hamba.dispatcher.data.model.DispatchRequestData
import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.data.model.Location
import com.hamba.dispatcher.services.sdk.FirebaseDatabaseWrapper
import com.hamba.dispatcher.services.sdk.FirebaseFirestoreWrapper
import com.hamba.dispatcher.utils.toDriverData
import com.hamba.dispatcher.websockets.FrameType.*
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
    driverDataCache: DriverPointDataCache,
    firebaseFirestoreWrapper: FirebaseFirestoreWrapper,
    firebaseDatabaseWrapper: FirebaseDatabaseWrapper
) {
    // TODO Refactor
    install(WebSockets)

    initDriversDataChangeListeners(firebaseFirestoreWrapper, driverDataCache)

    routing {
        webSocket("driver") {
            var receivedText: String
            var driverId: String? = null
            try {
                for (frame in incoming) {
                    if (frame !is Frame.Text) continue
                    receivedText = frame.readText()
                    when (FrameType.fromRawFrame(receivedText)) {
                        ADD_DRIVER_DATA -> {
                            val driverData = Json.decodeFromString<DriverData>(receivedText.substringAfter(":"))
                            driverConnections[driverData.driverId] = this
                            driverDataRepository.addDriverData(driverData)
                            driverId = driverData.driverId
                        }
                        UPDATE_DRIVER_DATA -> {
                            if (driverId == null) {// Should add data before updating it.
                                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
                            } else {
                                val (latitude, longitude) = receivedText.substringAfter(":").split(",")
                                val location = Location(latitude.toDouble(), longitude.toDouble())
                                driverDataRepository.updateDriverLocation(driverId, location)
                            }
                        }
                        DELETE_DRIVER_DATA -> {
                            if (driverId == null) {// Should add data before deleting it
                                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
                            }else {
                                driverDataRepository.deleteDriverData(driverId)
                                close(CloseReason(CloseReason.Codes.NORMAL, ""))
                            }
                        }
                        ACCEPT_BOOKING -> {
                            val dispatchDataId = receivedText.substringAfter(":")
                            val dispatchData = dispatchDataList[dispatchDataId]
                            if (dispatchData == null) {// Invalid id or that data have been already removed
                                send("$INVALID_DISPATCH_ID:$dispatchDataId")
                            } else {
                                dispatcher.onBookingAccepted(dispatchData, firebaseDatabaseWrapper)
                            }
                        }
                        REFUSE_BOOKING -> {
                            val dispatchDataId = receivedText.substringAfter(":")
                            val dispatchData = dispatchDataList[dispatchDataId]
                            if (dispatchData != null) {
                                dispatcher.onBookingRefused(dispatchData)
                            }
                        }
                        else -> close(CloseReason(CloseReason.Codes.PROTOCOL_ERROR, "INVALID_FRAME_TYPE"))
                    }
                }
            } catch (e: ClosedReceiveChannelException) {
                println("driverId = $driverId | message = Connection closed for ${closeReason.await()}")
            } catch (e: Exception) {
                println("driverId = $driverId | message = ${e.localizedMessage}")
                e.printStackTrace()
            } finally {
                driverId?.let { dispatcher.onDriverDisconnect(it) }
            }
        }

        webSocket("dispatch") {
            var riderId = ""
            var receivedText: String
            try {
                for (frame in incoming) {
                    if (frame !is Frame.Text) continue
                    receivedText = frame.readText()
                    when (FrameType.fromRawFrame(receivedText)) {
                        DISPATCH_REQUEST -> {
                            if (driverDataCache.isEmpty()) {
                                send("$NO_MORE_DRIVER_AVAILABLE:")
                            } else {
                                val dispatchRequestData =
                                    Json.decodeFromString<DispatchRequestData>(receivedText.substringAfter(":"))
                                riderId = dispatchRequestData.riderId
                                dispatcher.dispatch(dispatchRequestData, this)
                            }
                        }
                        CANCEL_BOOKING -> {
                            val dispatchData = dispatchDataList[riderId]
                            if (dispatchData == null) { // The dispatching have not been initialized first (distance calculation is probably in progress).
                                close(CloseReason(CloseReason.Codes.NORMAL, ""))
                            } else {
                                dispatcher.onDispatchCanceled(riderId)
                            }
                        }
                        else -> close(CloseReason(CloseReason.Codes.PROTOCOL_ERROR, "INVALID_FRAME_TYPE"))
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

@OptIn(ExperimentalSerializationApi::class)
fun initDriversDataChangeListeners(
    firebaseFirestoreWrapper: FirebaseFirestoreWrapper,
    driverDataCache: DriverPointDataCache
) {
    firebaseFirestoreWrapper.firestoreClient.collection("drivers").addSnapshotListener { querySnapshot, error ->
        if (error != null) {
            println(error.message)
        }
        if (querySnapshot == null) {
            println("Error firestore event returned a null querySnapshot")
        } else {
            querySnapshot.documentChanges.forEach { driverDocumentChange ->
                val driverDocument = driverDocumentChange.document
                val driverData = driverDocument.data.toDriverData(driverDocument.id)
                when (driverDocumentChange.type) {
                    ADDED -> driverDataCache.add(driverData)
                    MODIFIED -> driverDataCache.update(driverData)
                    REMOVED -> driverDataCache.remove(driverData)
                }
            }
        }
    }
}