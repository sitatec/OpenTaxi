package com.hamba.dispatcher.e2e

import com.hamba.dispatcher.*
import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.model.*
import com.hamba.dispatcher.services.api.FirebaseFirestoreWrapper
import com.hamba.dispatcher.services.api.RouteApiClient
import com.hamba.dispatcher.services.api.initializeFirebase
import com.hamba.dispatcher.websockets.webSocketsServer
import io.ktor.http.cio.websocket.*
import kotlin.test.*
import io.ktor.server.testing.*
import io.ktor.websocket.*
import kotlinx.coroutines.*
import kotlinx.coroutines.channels.ClosedReceiveChannelException
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json
import org.junit.AfterClass
import org.junit.BeforeClass
import java.util.*

class ApplicationTest {
    // TODO Test Thread safety.
    // TODO handle JobCancellation exception thrown on `testDispatching`
    // TODO test for more than 1000 drivers simultaneously connected and memory consumption
    private val driverDataCache = DriverPointDataCache()
    private val firebaseDatabaseClient = FirebaseFirestoreWrapper()
    private lateinit var driverDataRepository: DriverDataRepository
    private lateinit var distanceCalculator: DistanceCalculator
    private val driverConnections = Collections.synchronizedMap(mutableMapOf<String, DefaultWebSocketServerSession>())
    private val dispatchDataList = Collections.synchronizedMap(mutableMapOf<String, DispatchData>())
    private lateinit var dispatcher: Dispatcher

    @BeforeTest
    fun initData() {
        driverDataCache.clear()
        driverConnections.clear()
        dispatchDataList.clear()
        driverDataRepository = DriverDataRepository(firebaseDatabaseClient)
        distanceCalculator = DistanceCalculator(routeApiClient, driverDataCache)
        dispatcher =
            Dispatcher(distanceCalculator, driverConnections, routeApiClient, driverDataRepository, dispatchDataList)
    }

    companion object {
        private val routeApiClient = RouteApiClient()

        @BeforeClass
        @JvmStatic
        fun setup() {
            // TODO create testing project on firebase.
            initializeFirebase("C:/Development/Projects/Professional/Hamba/source_code/backend/firebase-adminsdk.json")
        }

        @AfterClass
        @JvmStatic
        fun release() {
            routeApiClient.release()
        }
    }

//    @Test
//    fun testIndex() {
//        val index = PointIndex<DriverData>(TreeMap())
//        fakeDriverDataList.forEach {
//            index.add(S2LatLng.fromDegrees(it.location.latitude, it.location.longitude).toPoint(), it)
//        }
//        val options = ClosestPointQuery.Options(maxResult = 4)
//        val closestPointQuery = ClosestPointQuery(index, options)
//        val target = ClosestPointQuery.S2ClosestPointQueryPointTarget(
//            S2LatLng.fromDegrees(
//                fakeDispatchRequestData.location.latitude,
//                fakeDispatchRequestData.location.longitude
//            ).toPoint()
//        )
//        closestPointQuery.findClosestPoints(target).forEach {
//            println(it.data().driverId)
//        }
//    }

    @Test
    fun testDriverDataManagement() {
        withTestApplication({
            webSocketsServer(
                driverConnections,
                driverDataRepository,
                dispatchDataList,
                dispatcher,
                driverDataCache,
                firebaseDatabaseClient
            )
        }) {
            handleWebSocketConversation("/driver") { _, outgoing ->

                assertEquals(
                    0,
                    driverDataCache.size,
                    "The location index must be empty when the server is just started."
                )
                assertEquals(
                    0,
                    driverDataRepository.getDriversAllData().size,
                    "The location index must be empty when the server is just started."
                )

                // Test driver sending his location data the first time
                outgoing.send(Frame.Text("a:${fakeDriverData.toJson()}"))
                delay(5000)
                assertEquals(
                    1,
                    driverDataCache.size,
                    "The number of location/Point in the index must be equal to the number of driver that have sent their location to the server."
                )
                assertEquals(
                    1,
                    driverDataRepository.getDriversAllData().size,
                    "The number of location/Point in the index must be equal to the number of driver that have sent their location to the server."
                )

                // TEST driver send location update frame
                val newLocation = Location(23.453543, -24.454643)
                var driverLocation = driverDataRepository.getDriverData(fakeDriverData.driverId)!!.location
                assertNotEquals(newLocation, driverLocation)
                outgoing.send(Frame.Text("u:$newLocation"))
                delay(25)
                driverLocation = driverDataRepository.getDriverData(fakeDriverData.driverId)!!.location
                assertEquals(newLocation, driverLocation)

                // Test driver deleting his location data
                outgoing.send(Frame.Text("d:"))
                delay(5000)
                assertEquals(0, driverDataCache.size)
                assertEquals(0, driverDataRepository.getDriversAllData().size)
            }
        }
    }

    @Test
    fun `Trying to update data without first add it should close connection`() {
        withTestApplication({
            webSocketsServer(
                driverConnections,
                driverDataRepository,
                dispatchDataList,
                dispatcher,
                driverDataCache,
                firebaseDatabaseClient
            )
        }) {
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
        withTestApplication({
            webSocketsServer(
                driverConnections,
                driverDataRepository,
                dispatchDataList,
                dispatcher,
                driverDataCache,
                firebaseDatabaseClient
            )
        }) {
            handleWebSocketConversation("/driver") { incoming, outgoing ->
                outgoing.send(Frame.Text("d:"))
                val closeReasonCode = (incoming.receive() as Frame.Close).readReason()?.code
                assertEquals(closeReasonCode, CloseReason.Codes.CANNOT_ACCEPT.code)

            }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun testDispatching() {
        withTestApplication({
            webSocketsServer(
                driverConnections,
                driverDataRepository,
                dispatchDataList,
                dispatcher,
                driverDataCache,
                firebaseDatabaseClient
            )
        }) {
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
                                    // TODO check that it contains the direction api response.
                                }
                            }
                        }
                    } catch (e: ClosedReceiveChannelException) {
                        // Not all the drivers will receive a booking request because we dispatch to the closest ones. So
                        // trying to receive a booking message will throw an ClosedReceiveChannelException for the driver that are not close to the rider.
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }

            // Simulate a rider making a booking
            handleWebSocketConversation("/dispatch") { incoming, outgoing ->
                delay(6_000)// Wait until all fake drivers have been connected.
                outgoing.send(Frame.Text("d:${fakeDispatchRequestData.toJson()}"))
                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                val closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("nearHome", closestDriverData.first.driverId)
                delay(1_000)
                assertFalse(driverDataCache.contains(closestDriverData.first.toPointData()))
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("yes", receivedMessage)

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("dir"/*DIRECTION*/, receivedMessage.substringBefore(":"))
                println("\ndirection response = ${receivedMessage.substringAfter(":")}")
                // TODO check that it contains the direction api response.
            }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun `Test dispatching with car type specified`() {
        withTestApplication({
            webSocketsServer(
                driverConnections,
                driverDataRepository,
                dispatchDataList,
                dispatcher,
                driverDataCache,
                firebaseDatabaseClient
            )
        }) {
            // Simulate connected drivers
            for (driverData in fakeDriverDataList) {
                println("driver = ${driverData.driverId}")
                launch {
                    try {
                        handleWebSocketConversation("/driver") { incoming, outgoing ->
                            outgoing.send(Frame.Text("a:${driverData.toJson()}"))
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
                                    // TODO check that it contains the direction api response.
                                }
                            }
                        }
                    } catch (e: ClosedReceiveChannelException) {
                        // Not all the drivers will receive a booking request because we dispatch to the closest ones. So
                        // trying to receive a booking message will throw an ClosedReceiveChannelException for the driver that are not close to the rider.
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }

            // Simulate a rider making booking with car type specified
            handleWebSocketConversation("/dispatch") { incoming, outgoing ->
                delay(6_000)// Wait until all fake drivers have been connected.
                outgoing.send(Frame.Text("d:${fakeDispatchRequestDataWithCarFilter.toJson()}"))
                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                val closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("pharmacieNdiolou", closestDriverData.first.driverId)
                delay(1_000)
                assertFalse(driverDataCache.contains(closestDriverData.first.toPointData()))
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("yes", receivedMessage)

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("dir"/*DIRECTION*/, receivedMessage.substringBefore(":"))
                println("\ndirection response = ${receivedMessage.substringAfter(":")}")
                // TODO check that it contains the direction api response.
            }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun `Test dispatching with driver gender specified`() {
        withTestApplication({
            webSocketsServer(
                driverConnections,
                driverDataRepository,
                dispatchDataList,
                dispatcher,
                driverDataCache,
                firebaseDatabaseClient
            )
        }) {
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
                                    // TODO check that it contains the direction api response.
                                }
                            }
                        }
                    } catch (e: ClosedReceiveChannelException) {
                        // Not all the drivers will receive a booking request because we dispatch to the closest ones. So
                        // trying to receive a booking message will throw an ClosedReceiveChannelException for the driver that are not close to the rider.
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
            // Simulate a rider making booking with driver's gender specified
            handleWebSocketConversation("/dispatch") { incoming, outgoing ->
                delay(6_000)// Wait until all fake drivers have been connected.
                outgoing.send(Frame.Text("d:${fakeDispatchRequestDataWithGenderFilter.toJson()}"))
                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                val closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("garageMalal", closestDriverData.first.driverId)
                delay(1_000)
                assertFalse(driverDataCache.contains(closestDriverData.first.toPointData()))
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("yes", receivedMessage)

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("dir"/*DIRECTION*/, receivedMessage.substringBefore(":"))
                println("\ndirection response = ${receivedMessage.substringAfter(":")}")
                // TODO check that it contains the direction api response.
            }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun `Test When a driver cancel a booking, a booking request should be sent to the next closest driver if any`() {
        withTestApplication({
            webSocketsServer(
                driverConnections,
                driverDataRepository,
                dispatchDataList,
                dispatcher,
                driverDataCache,
                firebaseDatabaseClient
            )
        }) {
            var currentDriverIndex = 0
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
                                    if(currentDriverIndex == 0) {
                                        currentDriverIndex++
                                        // The closest driver refuse the booking.
                                        outgoing.send(Frame.Text("no:${bookingData.riderId}"))
                                        (incoming.receive() as Frame.Text).readText()
                                    } else {
                                        outgoing.send(Frame.Text("yes:${bookingData.riderId}"))
                                        val directionDataMessage = (incoming.receive() as Frame.Text).readText()
                                        assertEquals("dir"/*DIRECTION*/, directionDataMessage.substringBefore(":"))
                                    }
                                }
                            }
                        }
                    } catch (e: ClosedReceiveChannelException) {
                        // Not all the drivers will receive a booking request because we dispatch to the closest ones. So
                        // trying to receive a booking message will throw an ClosedReceiveChannelException for the driver that are not close to the rider.
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
            // Simulate a rider making booking with driver's gender specified
            handleWebSocketConversation("/dispatch") { incoming, outgoing ->
                delay(6_000)// Wait until all fake drivers have been connected.
                outgoing.send(Frame.Text("d:${fakeDispatchRequestData.toJson()}"))
                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                var closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("nearHome", closestDriverData.first.driverId)
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.
                assertFalse(driverDataCache.contains(closestDriverData.first.toPointData()))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("no:1", receivedMessage) // The first driver rejected the booking request
                delay(1_000)
                assertNotNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// When a driver
                // refuse a booking he/she should be available again for new bookings
                assertTrue(driverDataCache.contains(closestDriverData.first.toPointData()))

                // ------------------------- SECOND CLOSEST DRIVER -----------------------------//

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("garageMalal", closestDriverData.first.driverId)
                delay(1_000)
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.
                assertFalse(driverDataCache.contains(closestDriverData.first.toPointData()))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("yes", receivedMessage) // The second-closest driver accept the booking

                delay(1_000)

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("dir"/*DIRECTION*/, receivedMessage.substringBefore(":"))
                println("\ndirection response = ${receivedMessage.substringAfter(":")}")
                // TODO check that it contains the direction api response.
            }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun `Test when the rider cancel the dispatching process`() {
        withTestApplication({
            webSocketsServer(
                driverConnections,
                driverDataRepository,
                dispatchDataList,
                dispatcher,
                driverDataCache,
                firebaseDatabaseClient
            )
        }) {
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
                                    val cancellationMessage = (incoming.receive() as Frame.Text).readText()
                                    assertEquals("c"/*CANCELLATION*/, cancellationMessage.substringBefore(":"))
                                    incoming.receive()
                                }
                            }
                        }
                    } catch (e: ClosedReceiveChannelException) {
                        // Not all the drivers will receive a booking request because we dispatch to the closest ones. So
                        // trying to receive a booking message will throw an ClosedReceiveChannelException for the driver that are not close to the rider.
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }
            // Simulate a rider making booking with driver's gender specified
            handleWebSocketConversation("/dispatch") { incoming, outgoing ->
                delay(6_000)// Wait until all fake drivers have been connected.
                outgoing.send(Frame.Text("d:${fakeDispatchRequestDataWithGenderFilter.toJson()}"))
                val receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                val closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("garageMalal", closestDriverData.first.driverId)
                delay(1_000)
                assertFalse(driverDataCache.contains(closestDriverData.first.toPointData()))
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.

                outgoing.send(Frame.Text("c:"))

                val closeReason = (incoming.receive() as Frame.Close).readReason()
                assertEquals(CloseReason.Codes.NORMAL.code, closeReason?.code)

                delay(1_000)

                assertTrue(driverDataCache.contains(closestDriverData.first.toPointData()))// When a rider
                // cancel the dispatching process the driver a booking have been sent to should be available again for new bookings
                assertNotNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))
            }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun `Test when all closest drivers reject the booking request`() {
        withTestApplication({
            webSocketsServer(
                driverConnections,
                driverDataRepository,
                dispatchDataList,
                dispatcher,
                driverDataCache,
                firebaseDatabaseClient
            )
        }) {
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
                                    // The closest driver refuse the booking.
                                    outgoing.send(Frame.Text("no:${bookingData.riderId}"))
                                    (incoming.receive() as Frame.Text).readText()
                                }
                            }
                        }
                    } catch (e: ClosedReceiveChannelException) {
                        // Not all the drivers will receive a booking request because we dispatch to the closest ones. So
                        // trying to receive a booking message will throw an ClosedReceiveChannelException for the driver that are not close to the rider.
                    } catch (e: Exception) {
                        e.printStackTrace()
                    }
                }
            }

            // Simulate a rider making a booking
            handleWebSocketConversation("/dispatch") { incoming, outgoing ->
                delay(6_000)// Wait until all fake drivers have been connected.
                outgoing.send(Frame.Text("d:${fakeDispatchRequestData.toJson()}"))

                // ------------------ DRIVER 1 ---------------- //

                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("no:1", receivedMessage)
                delay(1_000)

                // ------------------ DRIVER 2 ---------------- //

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("no:2", receivedMessage)
                delay(1_000)

                // ------------------ DRIVER 3 ---------------- //

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("no:3", receivedMessage)
                delay(1_000)

                // ------------------ DRIVER 4 ---------------- //

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("bs"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("no:4", receivedMessage)
                delay(1_000)

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("no:", receivedMessage) // all drivers have refuse the booking
            }
        }
    }

}

