package com.hamba.dispatcher.websockets

import com.google.cloud.firestore.DocumentChange.Type.*
import com.hamba.dispatcher.Dispatcher
import com.hamba.dispatcher.controllers.DispatchController
import com.hamba.dispatcher.controllers.DriverController
import com.hamba.dispatcher.data.DriverPointDataCache
import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.DispatchData
import com.hamba.dispatcher.data.model.DispatchRequestData
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
    driverController: DriverController,
    dispatchController: DispatchController,
    dispatcher: Dispatcher,
    driverDataCache: DriverPointDataCache,
    firebaseFirestoreWrapper: FirebaseFirestoreWrapper,
    firebaseDatabaseWrapper: FirebaseDatabaseWrapper
) {
    // TODO Use proper logging
    install(WebSockets)

    initDriversDataChangeListeners(firebaseFirestoreWrapper, driverDataCache)

    routing {
        webSocket("driver") {
            var receivedText: String
            var receivedData: String
            var driverId: String? = null
            try {
                for (frame in incoming) {
                    if (frame !is Frame.Text) continue
                    receivedText = frame.readText()
                    receivedData = receivedText.substringAfter(":")
                    when (FrameType.fromRawFrame(receivedText)) {
                        ADD_DRIVER_DATA -> driverId = driverController.addDriverData(receivedData, this)
                        UPDATE_DRIVER_DATA -> driverController.updateDriverData(driverId, receivedData, this)
                        DELETE_DRIVER_DATA -> driverController.deleteDriverData(driverId, this)
                        ACCEPT_BOOKING -> {
                            driverController.acceptBooking(driverId, receivedData, firebaseDatabaseWrapper, this)
                        }
                        REFUSE_BOOKING -> driverController.refuseBooking(driverId, receivedData, this)
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
            var receivedData: String
            try {
                for (frame in incoming) {
                    if (frame !is Frame.Text) continue
                    receivedText = frame.readText()
                    receivedData = receivedText.substringAfter(":")
                    when (FrameType.fromRawFrame(receivedText)) {
                        DISPATCH_REQUEST -> riderId = dispatchController.dispatch(receivedData, this)
                        CANCEL_BOOKING -> dispatchController.cancelDispatch(riderId, this)
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