package com.hamba.dispatcher.e2e

import com.hamba.dispatcher.*
import com.hamba.dispatcher.model.DispatchData
import com.hamba.dispatcher.model.Location
import com.hamba.dispatcher.websockets.webSocketsServer
import dilivia.s2.index.point.S2PointIndex
import io.ktor.http.cio.websocket.*
import kotlin.test.*
import io.ktor.server.testing.*
import io.ktor.websocket.*
import kotlinx.coroutines.delay
import java.util.*

class ApplicationTest {
    // TODO Test Thread safety.

    private var routeApiClient = RouteApiClient()
    private lateinit var locationIndex: S2PointIndex<String>
    private lateinit var driverDataManager: DriverDataManager
    private lateinit var distanceCalculator: DistanceCalculator
    private lateinit var driverConnections: MutableMap<String, DefaultWebSocketServerSession>
    private lateinit var dispatchDataList: MutableMap<String, DispatchData>
    private lateinit var dispatcher: Dispatcher

    @BeforeTest
    fun initData() {
        locationIndex = S2PointIndex()
        driverDataManager = DriverDataManager(locationIndex)
        distanceCalculator = DistanceCalculator(driverDataManager, routeApiClient)
        driverConnections = Collections.synchronizedMap(mutableMapOf<String, DefaultWebSocketServerSession>())
        dispatchDataList = Collections.synchronizedMap(mutableMapOf<String, DispatchData>())
        dispatcher = Dispatcher(distanceCalculator, driverConnections, routeApiClient)
    }

    @Test
    fun testDriverDataManagement() {
        withTestApplication({ webSocketsServer(driverConnections, driverDataManager, dispatchDataList, dispatcher) }) {
            handleWebSocketConversation("/driver") { incoming, outgoing ->

                assertEquals(0, locationIndex.numPoints(), "The location index must be empty when the server is just started.")

                // Test driver sending his location data the first time
                outgoing.send(Frame.Text("a:${fakeDriverData.toJson()}"))
                delay(25)
                assertEquals(1, locationIndex.numPoints(), "The number of location/Point in the index must be equal to the number of driver that have sent their location to the server.")

                // TEST driver send location update frame
                val newLocation = Location(23.453543, -24.454643)
                var driverLocation = driverDataManager.getDriverData(fakeDriverData.driverId)!!.location
                assertNotEquals(newLocation, driverLocation)
                outgoing.send(Frame.Text("u:$newLocation"))
                delay(25)
                driverLocation = driverDataManager.getDriverData(fakeDriverData.driverId)!!.location
                assertEquals(newLocation, driverLocation)

                // Test driver deleting his location data
                outgoing.send(Frame.Text("d:"))
                delay(25)
                assertEquals(0, locationIndex.numPoints())
            }
        }
    }

    @Test
    fun `Trying to update data without first add it should close connection`(){
        withTestApplication({ webSocketsServer(driverConnections, driverDataManager, dispatchDataList, dispatcher) }) {
            handleWebSocketConversation("/driver") { incoming, outgoing ->
                val location = Location(23.453543, -24.454643)
                outgoing.send(Frame.Text("u:$location"))
                val closeReasonCode = (incoming.receive() as Frame.Close).readReason()?.code
                assertEquals(closeReasonCode, CloseReason.Codes.CANNOT_ACCEPT.code)
            }
        }
    }

    @Test
    fun `Trying to delete data without first add it should close connection`(){
        withTestApplication({ webSocketsServer(driverConnections, driverDataManager, dispatchDataList, dispatcher) }) {
            handleWebSocketConversation("/driver") { incoming, outgoing ->
                outgoing.send(Frame.Text("d:"))
                val closeReasonCode = (incoming.receive() as Frame.Close).readReason()?.code
                assertEquals(closeReasonCode, CloseReason.Codes.CANNOT_ACCEPT.code)

            }
        }
    }
}