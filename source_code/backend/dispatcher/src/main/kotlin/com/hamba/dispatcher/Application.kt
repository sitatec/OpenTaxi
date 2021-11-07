package com.hamba.dispatcher

import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.DispatchData
import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.services.api.FirebaseDatabaseWrapper
import com.hamba.dispatcher.services.api.RouteApiClient
import com.hamba.dispatcher.websockets.webSocketsServer
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.websocket.*
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withContext
import java.util.*

fun main() {
    val httpClient = HttpClient(CIO)
    val firebaseDatabaseClient = FirebaseDatabaseWrapper()
    val driverDataRepository = DriverDataRepository(firebaseDatabaseClient)
    val routeApiClient = RouteApiClient(httpClient)
    val driverDataCache = Collections.synchronizedSortedSet(sortedSetOf<DriverData>())
    val distanceCalculator = DistanceCalculator(driverDataRepository, routeApiClient, driverDataCache)
    val driverConnections = Collections.synchronizedMap(mutableMapOf<String, DefaultWebSocketServerSession>())
    val dispatchDataList = Collections.synchronizedMap(mutableMapOf<String, DispatchData>())
    val dispatcher =
        Dispatcher(distanceCalculator, driverConnections, routeApiClient, driverDataRepository, dispatchDataList)

    embeddedServer(Netty, port = 8080, host = "localhost") {
        webSocketsServer(driverConnections, driverDataRepository, dispatchDataList, dispatcher, driverDataCache)
    }.start(wait = true)

    httpClient.close()
}
