package com.hamba.dispatcher.e2e

import com.hamba.dispatcher.Dispatcher
import com.hamba.dispatcher.DistanceCalculator
import com.hamba.dispatcher.DriverDataManager
import com.hamba.dispatcher.RouteApiClient
import com.hamba.dispatcher.model.DispatchData
import com.hamba.dispatcher.websockets.webSocketsServer
import dilivia.s2.index.point.S2PointIndex
import kotlin.test.*
import io.ktor.server.testing.*
import io.ktor.websocket.*
import java.util.*

class ApplicationTest {
    private val locationIndex = S2PointIndex<String>()
    private val driverDataManager = DriverDataManager(locationIndex)
    private val routeApiClient = RouteApiClient()
    private val distanceCalculator = DistanceCalculator(driverDataManager, routeApiClient)
    private val driverConnections = Collections.synchronizedMap(mutableMapOf<String, DefaultWebSocketServerSession>())
    private val dispatchDataList = Collections.synchronizedMap(mutableMapOf<String, DispatchData>())
    private val dispatcher = Dispatcher(distanceCalculator, driverConnections, routeApiClient)

    @Test
    fun testDriverDataManagement() {
        withTestApplication({ webSocketsServer(driverConnections, driverDataManager, dispatchDataList, dispatcher) }) {
            handleWebSocketConversation("/driver") { incoming, outgoing ->

            }
        }
    }
}