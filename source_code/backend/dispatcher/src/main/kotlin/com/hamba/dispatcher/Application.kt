package com.hamba.dispatcher

import com.hamba.dispatcher.model.DispatchData
import com.hamba.dispatcher.websockets.webSocketsServer
import dilivia.s2.index.point.S2PointIndex
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.websocket.*
import java.util.*

fun main() {
    val locationIndex = S2PointIndex<String>()
    val driverDataManager = DriverDataManager(locationIndex)
    val routeApiClient = RouteApiClient()
    val distanceCalculator = DistanceCalculator(driverDataManager, routeApiClient)
    val driverConnections = Collections.synchronizedMap(mutableMapOf<String, DefaultWebSocketServerSession>())
    val dispatchDataList = Collections.synchronizedMap(mutableMapOf<String, DispatchData>())
    val dispatcher = Dispatcher(distanceCalculator, driverConnections, routeApiClient, driverDataManager, dispatchDataList)

    embeddedServer(Netty, port = 8080, host = "localhost") {
        webSocketsServer(driverConnections, driverDataManager, dispatchDataList, dispatcher)
    }.start(wait = true)
    routeApiClient.release()
}
