package com.hamba.dispatcher.websockets

import com.google.cloud.firestore.DocumentChange.Type.*
import com.hamba.dispatcher.Dispatcher
import com.hamba.dispatcher.controllers.DispatchController
import com.hamba.dispatcher.controllers.DriverController
import com.hamba.dispatcher.data.DriverPointDataCache
import com.hamba.dispatcher.services.api.DataAccessClient
import com.hamba.dispatcher.services.api.RouteApiClient
import com.hamba.dispatcher.services.sdk.RealTimeDatabase
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
import java.time.Duration


@OptIn(ExperimentalSerializationApi::class)
fun Application.webSocketsServer(
    driverController: DriverController,
    dispatchController: DispatchController,
    dispatcher: Dispatcher,
    driverDataCache: DriverPointDataCache,
    firebaseFirestoreWrapper: FirebaseFirestoreWrapper,
    realTimeDatabase: RealTimeDatabase,
    dataAccessClient: DataAccessClient = DataAccessClient(),
    routeApiClient: RouteApiClient
) {
    // TODO Use proper logging
    install(WebSockets) {
        pingPeriod = Duration.ofSeconds(30)
        timeout = Duration.ofMinutes(1)
    }

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
                    when (FrameType.fromFrameText(receivedText)) {
                        // TODO add authentication step (firebase auth token verification) before deployment
                        ADD_DRIVER_DATA -> driverId = driverController.addDriverData(receivedData, this)
                        UPDATE_DRIVER_DATA -> driverController.updateDriverData(driverId, receivedData, this)
                        DELETE_DRIVER_DATA -> driverController.deleteDriverData(driverId, this)
                        ACCEPT_BOOKING -> {
                            driverController.acceptBooking(
                                driverId,
                                receivedData,
                                realTimeDatabase,
                                this,
                                dataAccessClient,
                            )
                        }
                        REFUSE_BOOKING -> driverController.refuseBooking(driverId, receivedData, this)
                        START_FUTURE_BOOKING_TRIP -> driverController.startFutureBookingTrip(
                            receivedData,
                            dataAccessClient,
                            routeApiClient,
                            realTimeDatabase,
                            driverConnection = this
                        )
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
                    when (FrameType.fromFrameText(receivedText)) {
                        // TODO add authentication step (firebase auth token verification) before deployment
                        INIT_DISPATCH_SESSION -> riderId = dispatchController.initDispatchSession(receivedData, this)
                        DISPATCH_REQUEST -> dispatchController.dispatch(riderId, receivedData)
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
    println("ADDING FIRESTORE LISTENERS")
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