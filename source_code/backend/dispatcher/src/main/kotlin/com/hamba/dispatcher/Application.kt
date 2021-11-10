package com.hamba.dispatcher

import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.DispatchData
import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.services.api.FirebaseFirestoreWrapper
import com.hamba.dispatcher.services.api.RouteApiClient
import com.hamba.dispatcher.services.api.initializeFirebase
import com.hamba.dispatcher.websockets.webSocketsServer
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.websocket.*
import java.util.*

fun main() {
    val httpClient = HttpClient(CIO)
    initializeFirebase()
    val firebaseDatabaseClient = FirebaseFirestoreWrapper()
    val driverDataRepository = DriverDataRepository(firebaseDatabaseClient)
    val routeApiClient = RouteApiClient(httpClient)
    val driverDataCache = DriverPointDataCache()
    val distanceCalculator = DistanceCalculator(routeApiClient, driverDataCache)
    val driverConnections = Collections.synchronizedMap(mutableMapOf<String, DefaultWebSocketServerSession>())
    val dispatchDataList = Collections.synchronizedMap(mutableMapOf<String, DispatchData>())
    val dispatcher =
        Dispatcher(distanceCalculator, driverConnections, routeApiClient, driverDataRepository, dispatchDataList)

    embeddedServer(Netty, port = 8080, host = "localhost") {
        webSocketsServer(
            driverConnections,
            driverDataRepository,
            dispatchDataList,
            dispatcher,
            driverDataCache,
            firebaseDatabaseClient
        )
    }.start(wait = true)

    httpClient.close()
}
