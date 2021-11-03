package com.hamba.dispatcher.e2e

import com.hamba.dispatcher.*
import com.hamba.dispatcher.model.*
import com.hamba.dispatcher.websockets.webSocketsServer
import dilivia.s2.index.point.S2PointIndex
import io.ktor.http.cio.websocket.*
import kotlin.test.*
import io.ktor.server.testing.*
import io.ktor.websocket.*
import kotlinx.coroutines.*
import kotlinx.coroutines.channels.ClosedReceiveChannelException
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import java.util.*
import java.util.concurrent.Executors
import kotlin.coroutines.CoroutineContext

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

    //TODO test cancellation for both the rider and driver side.

    @Test
    fun testDriverDataManagement() {
        withTestApplication({ webSocketsServer(driverConnections, driverDataManager, dispatchDataList, dispatcher) }) {
            handleWebSocketConversation("/driver") { _, outgoing ->

                assertEquals(
                    0,
                    locationIndex.numPoints(),
                    "The location index must be empty when the server is just started."
                )

                // Test driver sending his location data the first time
                outgoing.send(Frame.Text("a:${fakeDriverData.toJson()}"))
                delay(25)
                assertEquals(
                    1,
                    locationIndex.numPoints(),
                    "The number of location/Point in the index must be equal to the number of driver that have sent their location to the server."
                )

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
    fun `Trying to update data without first add it should close connection`() {
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
    fun `Trying to delete data without first add it should close connection`() {
        withTestApplication({ webSocketsServer(driverConnections, driverDataManager, dispatchDataList, dispatcher) }) {
            handleWebSocketConversation("/driver") { incoming, outgoing ->
                outgoing.send(Frame.Text("d:"))
                val closeReasonCode = (incoming.receive() as Frame.Close).readReason()?.code
                assertEquals(closeReasonCode, CloseReason.Codes.CANNOT_ACCEPT.code)

            }
        }
    }

    @Test
    fun testDispatching() {
        withTestApplication({ webSocketsServer(driverConnections, driverDataManager, dispatchDataList, dispatcher) }) {
            // Simulate connected drivers
            for (fakeDriverData in fakeDriverDataList) {
                println("driver = ${fakeDriverData.driverId}")
                    launch {
                        try {
                        handleWebSocketConversation("/driver") { incoming, outgoing ->
                            outgoing.send(Frame.Text("a:${fakeDriverData.toJson()}"))
                            val rawMessage = incoming.receive()
                            if (rawMessage is Frame.Text) {
                                val message = rawMessage.readText()
                                if (message.substringBefore(":") == "b"/*BOOKING*/) {
                                    delay(20) // Wait until the rider receive the booking confirmation.
                                    val bookingData =
                                        Json.decodeFromString<DispatchRequestData>(message.substringAfter(":"))
                                    outgoing.send(Frame.Text("yes:${bookingData.riderId}"))
                                    val directionDataMessage = (incoming.receive() as Frame.Text).readText()
                                    assertEquals("dir"/*DIRECTION*/, directionDataMessage.substringBefore(":"))
                                    //TODO check that it contains the direction api response.
                                }
                            }
                        }
                    }catch (e: ClosedReceiveChannelException){
                        // Not all the drivers will receive a booking request because we dispatch to the closest ones. So
                        // trying to receive a booking message will throw an ClosedReceiveChannelException for the driver that are not close to the rider.
                    }
                    }
            }

            // Simulate a rider connection
            handleWebSocketConversation("/dispatch") { incoming, outgoing ->
                delay(500)// Wait until all fake drivers have been connected.
                outgoing.send(Frame.Text("d:${fakeDispatchRequestData.toJson()}"))
                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))
                val closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("nearHome", closestDriverData.first.driverId)
                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("yes", receivedMessage)
                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("dir"/*DIRECTION*/, receivedMessage.substringBefore(":"))
                println("\ndirection response = ${receivedMessage.substringAfter(":")}")
                //TODO check that it contains the direction api response.
            }
        }
    }
}