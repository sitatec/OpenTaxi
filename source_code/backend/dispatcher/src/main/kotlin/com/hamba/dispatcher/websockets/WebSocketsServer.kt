package com.hamba.dispatcher.websockets

import com.hamba.dispatcher.DriverDataManager
import com.hamba.dispatcher.RouteApiClient
import com.hamba.dispatcher.model.DispatchData
import com.hamba.dispatcher.model.DriverData
import com.hamba.dispatcher.model.Location
import dilivia.s2.index.point.S2PointIndex
import io.ktor.application.*
import io.ktor.http.cio.websocket.*
import io.ktor.routing.*
import io.ktor.websocket.*
import kotlinx.coroutines.channels.ClosedReceiveChannelException
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import java.util.*

fun Application.webSocketsServer() {
    // TODO Take into account cancellation
    install(WebSockets)
    val locationIndex = S2PointIndex<String>()
    val driverDataManager = DriverDataManager(locationIndex)
    val routeApiClient = RouteApiClient()
    routing {
        val driverConnections = Collections.synchronizedMap(mutableMapOf<String, DefaultWebSocketServerSession>())
        val dispatchDataList = Collections.synchronizedMap(mutableMapOf<String, DispatchData>())
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
                            driverDataManager.addDriverData(driverData)
                            driverId = driverData.driverId
                        }
                        "u" /*UPDATE*/ -> {
                            if (driverId == null) {// Should add data before updating it.
                                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
                            }
                            val (latitude, longitude) = receivedText.substringAfter(":").split(",")
                            val location = Location(latitude.toDouble(), longitude.toDouble())
                            driverDataManager.updateDriverData(driverId!!, location)
                        }
                        "d" /*DELETE*/ -> {
                            if (driverId == null) {// Should add data before deleting it
                                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
                            }
                            driverDataManager.deleteDriverData(driverId!!)
                            close(CloseReason(CloseReason.Codes.NORMAL, "Data deleted!"))
                        }
                        "yes" /*ACCEPT BOOKING*/ -> {
                            val dispatchDataId = receivedText.substringAfter(":")
                            val dispatchData = dispatchDataList[dispatchDataId]
                            if (dispatchData == null) {// Invalid id or that data have been already removed
                                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
                            } else {
                                dispatchData.riderConnection.send("yes")
                                val directionData = routeApiClient.findDirection(
                                    dispatchData.getClosestCandidateLocation(),
                                    dispatchData.getDestination(),
                                    dispatchData.getStops()
                                )
                                dispatchData.riderConnection.send(directionData)
                                send(directionData)
                            }
                        }
                        "no" /*REFUSE BOOKING*/ -> {
                            val dispatchDataId = receivedText.substringAfter(":")
                            val dispatchData = dispatchDataList[dispatchDataId]
                            if (dispatchData == null) {// Invalid id or that data have been already removed
                                close(CloseReason(CloseReason.Codes.CANNOT_ACCEPT, ""))
                            } else {
                                dispatchData.riderConnection.send("no:1")
                                // Retry.
                            }

                        }
                    }
                }
            } catch (e: ClosedReceiveChannelException) {
                println("driverId = $driverId | message = Connection closed for ${closeReason.await()}")
            } catch (e: Exception) {
                println("driverId = $driverId | message = ${e.localizedMessage}")
            } finally {
                driverId?.let {
                    driverConnections.remove(it)
                }
            }
        }

        webSocket("dispatch") {
            // TODO include the rider location to the stop's list.
        }
    }
    routeApiClient.release()
}