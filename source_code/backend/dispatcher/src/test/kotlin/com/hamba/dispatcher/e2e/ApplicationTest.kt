package com.hamba.dispatcher.e2e

import com.hamba.dispatcher.*
import com.hamba.dispatcher.controllers.DispatchController
import com.hamba.dispatcher.controllers.DriverController
import com.hamba.dispatcher.data.DriverDataRepository
import com.hamba.dispatcher.data.DriverPointDataCache
import com.hamba.dispatcher.data.model.*
import com.hamba.dispatcher.services.api.RouteApiClient
import com.hamba.dispatcher.services.sdk.FirebaseDatabaseWrapper
import com.hamba.dispatcher.services.sdk.FirebaseFirestoreWrapper
import com.hamba.dispatcher.services.sdk.initializeFirebase
import com.hamba.dispatcher.websockets.FrameType
import com.hamba.dispatcher.websockets.webSocketsServer
import io.ktor.http.cio.websocket.*
import kotlin.test.*
import com.hamba.dispatcher.websockets.FrameType.*
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
    private val firebaseFirestoreWrapper = FirebaseFirestoreWrapper()
    private val firebaseDatabaseWrapper = FirebaseDatabaseWrapper()
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
        firebaseDatabaseWrapper.deleteData("trip_rooms")
        driverDataRepository = DriverDataRepository(firebaseFirestoreWrapper)
        distanceCalculator = DistanceCalculator(routeApiClient, driverDataCache)
        dispatcher =
            Dispatcher(
                distanceCalculator,
                driverConnections,
                routeApiClient,
                driverDataRepository,
                dispatchDataList,
            )
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
                DriverController(driverDataRepository, driverConnections, dispatchDataList, dispatcher),
                DispatchController(driverDataCache, dispatcher, dispatchDataList),
                dispatcher,
                driverDataCache,
                firebaseFirestoreWrapper,
                FirebaseDatabaseWrapper()
            )
        }) {
            handleWebSocketConversation("/driver") { incoming, outgoing ->

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
                outgoing.send(Frame.Text("${ADD_DRIVER_DATA}:${fakeDriverData.toJson()}"))
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
                outgoing.send(Frame.Text("${UPDATE_DRIVER_DATA}:$newLocation"))
                delay(25)
                driverLocation = driverDataRepository.getDriverData(fakeDriverData.driverId)!!.location
                assertEquals(newLocation, driverLocation)

                // Test driver deleting his location data
                outgoing.send(Frame.Text("${DELETE_DRIVER_DATA}:"))

                val closeReason = (incoming.receive() as Frame.Close).readReason()
                assertEquals(CloseReason.Codes.NORMAL.code, closeReason?.code)
                outgoing.send(Frame.Close())
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
                DriverController(driverDataRepository, driverConnections, dispatchDataList, dispatcher),
                DispatchController(driverDataCache, dispatcher, dispatchDataList),
                dispatcher,
                driverDataCache,
                firebaseFirestoreWrapper,
                FirebaseDatabaseWrapper()
            )
        }) {
            handleWebSocketConversation("/driver") { incoming, outgoing ->
                val location = Location(23.453543, -24.454643)
                outgoing.send(Frame.Text("${UPDATE_DRIVER_DATA}:$location"))
                val closeReasonCode = (incoming.receive() as Frame.Close).readReason()?.code
                assertEquals(closeReasonCode, CloseReason.Codes.CANNOT_ACCEPT.code)
            }
        }
    }

    @Test
    fun `Trying to delete data without first add it should close connection`() {
        withTestApplication({
            webSocketsServer(
                DriverController(driverDataRepository, driverConnections, dispatchDataList, dispatcher),
                DispatchController(driverDataCache, dispatcher, dispatchDataList),
                dispatcher,
                driverDataCache,
                firebaseFirestoreWrapper,
                FirebaseDatabaseWrapper()
            )
        }) {
            handleWebSocketConversation("/driver") { incoming, outgoing ->
                outgoing.send(Frame.Text("${DELETE_DRIVER_DATA}:"))
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
                DriverController(driverDataRepository, driverConnections, dispatchDataList, dispatcher),
                DispatchController(driverDataCache, dispatcher, dispatchDataList),
                dispatcher,
                driverDataCache,
                firebaseFirestoreWrapper,
                FirebaseDatabaseWrapper()
            )
        }) {
            // Simulate connected drivers
            for (fakeDriverData in fakeDriverDataList) {
                println("driver = ${fakeDriverData.driverId}")
                launch {
                    try {
                        handleWebSocketConversation("/driver") { incoming, outgoing ->
                            outgoing.send(Frame.Text("${ADD_DRIVER_DATA}:${fakeDriverData.toJson()}"))
                            val rawMessage = incoming.receive()
                            if (rawMessage is Frame.Text) {
                                val message = rawMessage.readText()
                                if (FrameType.fromRawFrame(message) == BOOKING_REQUEST) {
                                    delay(20) // Wait until the rider receive the booking confirmation.
                                    val bookingData =
                                        Json.decodeFromString<DispatchRequestData>(message.substringAfter(":"))
                                    outgoing.send(Frame.Text("${ACCEPT_BOOKING}:${bookingData.riderId}"))
                                    val directionDataMessage = (incoming.receive() as Frame.Text).readText()
                                    assertEquals("$TRIP_ROOM", directionDataMessage.substringBefore(":"))
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
                outgoing.send(Frame.Text("${DISPATCH_REQUEST}:${fakeDispatchRequestData.toJson()}"))
                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT", receivedMessage.substringBefore(":"))

                val closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("nearHome", closestDriverData.first.driverId)
                delay(1_000)
                assertFalse(driverDataCache.contains(closestDriverData.first))
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${ACCEPT_BOOKING}:", receivedMessage)

                val closeReason = (incoming.receive() as Frame.Close).readReason()
                assertEquals(CloseReason.Codes.NORMAL.code, closeReason?.code)
            }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun `Test dispatching with car type specified`() {
        withTestApplication({
            webSocketsServer(
                DriverController(driverDataRepository, driverConnections, dispatchDataList, dispatcher),
                DispatchController(driverDataCache, dispatcher, dispatchDataList),
                dispatcher,
                driverDataCache,
                firebaseFirestoreWrapper,
                FirebaseDatabaseWrapper()
            )
        }) {
            // Simulate connected drivers
            for (driverData in fakeDriverDataList) {
                println("driver = ${driverData.driverId}")
                launch {
                    try {
                        handleWebSocketConversation("/driver") { incoming, outgoing ->
                            outgoing.send(Frame.Text("${ADD_DRIVER_DATA}:${driverData.toJson()}"))
                            val rawMessage = incoming.receive()
                            if (rawMessage is Frame.Text) {
                                val message = rawMessage.readText()
                                if (FrameType.fromRawFrame(message) == BOOKING_REQUEST) {
                                    delay(20) // Wait until the rider receive the booking confirmation.
                                    val bookingData =
                                        Json.decodeFromString<DispatchRequestData>(message.substringAfter(":"))
                                    outgoing.send(Frame.Text("${ACCEPT_BOOKING}:${bookingData.riderId}"))
                                    val directionDataMessage = (incoming.receive() as Frame.Text).readText()
                                    assertEquals("$TRIP_ROOM", directionDataMessage.substringBefore(":"))
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
                outgoing.send(Frame.Text("${DISPATCH_REQUEST}:${fakeDispatchRequestDataWithCarFilter.toJson()}"))
                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT", receivedMessage.substringBefore(":"))

                val closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("pharmacieNdiolou", closestDriverData.first.driverId)
                delay(1_000)
                assertFalse(driverDataCache.contains(closestDriverData.first))
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${ACCEPT_BOOKING}:", receivedMessage)

                val closeReason = (incoming.receive() as Frame.Close).readReason()
                assertEquals(CloseReason.Codes.NORMAL.code, closeReason?.code)
            }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun `Test dispatching with driver gender specified`() {
        withTestApplication({
            webSocketsServer(
                DriverController(driverDataRepository, driverConnections, dispatchDataList, dispatcher),
                DispatchController(driverDataCache, dispatcher, dispatchDataList),
                dispatcher,
                driverDataCache,
                firebaseFirestoreWrapper,
                FirebaseDatabaseWrapper()
            )
        }) {
            // Simulate connected drivers
            for (fakeDriverData in fakeDriverDataList) {
                println("driver = ${fakeDriverData.driverId}")
                launch {
                    try {
                        handleWebSocketConversation("/driver") { incoming, outgoing ->
                            outgoing.send(Frame.Text("${ADD_DRIVER_DATA}:${fakeDriverData.toJson()}"))
                            val rawMessage = incoming.receive()
                            if (rawMessage is Frame.Text) {
                                val message = rawMessage.readText()
                                if (FrameType.fromRawFrame(message) == BOOKING_REQUEST) {
                                    delay(20) // Wait until the rider receive the booking confirmation.
                                    val bookingData =
                                        Json.decodeFromString<DispatchRequestData>(message.substringAfter(":"))
                                    outgoing.send(Frame.Text("${ACCEPT_BOOKING}:${bookingData.riderId}"))
                                    val directionDataMessage = (incoming.receive() as Frame.Text).readText()
                                    assertEquals("$TRIP_ROOM", directionDataMessage.substringBefore(":"))
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
                outgoing.send(Frame.Text("${DISPATCH_REQUEST}:${fakeDispatchRequestDataWithGenderFilter.toJson()}"))
                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                val closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("garageMalal", closestDriverData.first.driverId)
                delay(1_000)
                assertFalse(driverDataCache.contains(closestDriverData.first))
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${ACCEPT_BOOKING}:", receivedMessage)

                val closeReason = (incoming.receive() as Frame.Close).readReason()
                assertEquals(CloseReason.Codes.NORMAL.code, closeReason?.code)
            }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun `Test When a driver cancel a booking, a booking request should be sent to the next closest driver if any`() {
        withTestApplication({
            webSocketsServer(
                DriverController(driverDataRepository, driverConnections, dispatchDataList, dispatcher),
                DispatchController(driverDataCache, dispatcher, dispatchDataList),
                dispatcher,
                driverDataCache,
                firebaseFirestoreWrapper,
                FirebaseDatabaseWrapper()
            )
        }) {
            var currentDriverIndex = 0
            // Simulate connected drivers
            for (fakeDriverData in fakeDriverDataList) {
                println("driver = ${fakeDriverData.driverId}")
                launch {
                    try {
                        handleWebSocketConversation("/driver") { incoming, outgoing ->
                            outgoing.send(Frame.Text("${ADD_DRIVER_DATA}:${fakeDriverData.toJson()}"))
                            val rawMessage = incoming.receive()
                            if (rawMessage is Frame.Text) {
                                val message = rawMessage.readText()
                                if (FrameType.fromRawFrame(message) == BOOKING_REQUEST) {
                                    delay(20) // Wait until the rider receive the booking confirmation.
                                    val bookingData =
                                        Json.decodeFromString<DispatchRequestData>(message.substringAfter(":"))
                                    if (currentDriverIndex == 0) {
                                        currentDriverIndex++
                                        // The closest driver refuse the booking.
                                        delay(1_000) // Wait until the rider receive the bs (booking sent message)
                                        outgoing.send(Frame.Text("${REFUSE_BOOKING}:${bookingData.riderId}"))
                                        (incoming.receive() as Frame.Text).readText()
                                    } else {
                                        outgoing.send(Frame.Text("${ACCEPT_BOOKING}:${bookingData.riderId}"))
                                        val directionDataMessage = (incoming.receive() as Frame.Text).readText()
                                        assertEquals("$TRIP_ROOM", directionDataMessage.substringBefore(":"))
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
                outgoing.send(Frame.Text("${DISPATCH_REQUEST}:${fakeDispatchRequestData.toJson()}"))
                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT", receivedMessage.substringBefore(":"))

                var closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("nearHome", closestDriverData.first.driverId)
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.
                assertFalse(driverDataCache.contains(closestDriverData.first))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${REFUSE_BOOKING}:1", receivedMessage) // The first driver rejected the booking request
                delay(1_000)
                assertNotNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// When a driver
                // refuse a booking he/she should be available again for new bookings
                assertTrue(driverDataCache.contains(closestDriverData.first))

                // ------------------------- SECOND CLOSEST DRIVER -----------------------------//

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT", receivedMessage.substringBefore(":"))

                closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("garageMalal", closestDriverData.first.driverId)
                delay(1_000)
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.
                assertFalse(driverDataCache.contains(closestDriverData.first))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${ACCEPT_BOOKING}:", receivedMessage) // The second-closest driver accept the booking

                delay(1_000)

                val closeReason = (incoming.receive() as Frame.Close).readReason()
                assertEquals(CloseReason.Codes.NORMAL.code, closeReason?.code)
            }
        }
    }


    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun `Test if a driver doesn't accept a booking after the set timeout, a new booking request should be sent to the next closest driver if any`() {
        val dispatcher1 = Dispatcher(
            distanceCalculator,
            driverConnections,
            routeApiClient,
            driverDataRepository,
            dispatchDataList,
            10_000/*10 seconds timeout*/
        )
        withTestApplication({
            webSocketsServer(
                DriverController(driverDataRepository, driverConnections, dispatchDataList, dispatcher1),
                DispatchController(driverDataCache, dispatcher1, dispatchDataList),
                dispatcher1,
                driverDataCache,
                firebaseFirestoreWrapper,
                FirebaseDatabaseWrapper()
            )
        }) {
            var currentDriverIndex = 0
            // Simulate connected drivers
            for (fakeDriverData in fakeDriverDataList) {
                println("driver = ${fakeDriverData.driverId}")
                launch {
                    try {
                        handleWebSocketConversation("/driver") { incoming, outgoing ->
                            outgoing.send(Frame.Text("${ADD_DRIVER_DATA}:${fakeDriverData.toJson()}"))
                            val rawMessage = incoming.receive()
                            if (rawMessage is Frame.Text) {
                                val message = rawMessage.readText()
                                if (FrameType.fromRawFrame(message) == BOOKING_REQUEST) {
                                    delay(1_000) // Wait until the rider receive the booking confirmation.
                                    val bookingData =
                                        Json.decodeFromString<DispatchRequestData>(message.substringAfter(":"))
                                    if (currentDriverIndex == 0) {
                                        currentDriverIndex++
                                        // The closest driver doesn't accept the booking after 10 second.
                                        delay(10_000)
                                        val msg = (incoming.receive() as Frame.Text).readText()
                                        assertEquals("${BOOKING_REQUEST_TIMEOUT}:" /*Timeout*/, msg)
                                        incoming.receive() // prevent disconnection
                                    } else {
                                        outgoing.send(Frame.Text("${ACCEPT_BOOKING}:${bookingData.riderId}"))
                                        val directionDataMessage = (incoming.receive() as Frame.Text).readText()
                                        assertEquals("$TRIP_ROOM", directionDataMessage.substringBefore(":"))
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
                outgoing.send(Frame.Text("${DISPATCH_REQUEST}:${fakeDispatchRequestData.toJson()}"))
                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT", receivedMessage.substringBefore(":"))

                var closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("nearHome", closestDriverData.first.driverId)
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.
                assertFalse(driverDataCache.contains(closestDriverData.first))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals(
                    "${BOOKING_REQUEST_TIMEOUT}:1",
                    receivedMessage
                ) // The first driver doesn't respond the booking request
                delay(1_000)
                assertNotNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// When a driver
                // refuse a booking he/she should be available again for new bookings
                assertTrue(driverDataCache.contains(closestDriverData.first))

                // ------------------------- SECOND CLOSEST DRIVER -----------------------------//

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT"/* bs = BOOKING SENT*/, receivedMessage.substringBefore(":"))

                closestDriverData = receivedMessage.substringAfter(":").decodeFromJson()
                assertEquals("garageMalal", closestDriverData.first.driverId)
                delay(1_000)
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.
                assertFalse(driverDataCache.contains(closestDriverData.first))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${ACCEPT_BOOKING}:", receivedMessage) // The second-closest driver accept the booking

                delay(1_000)

                val closeReason = (incoming.receive() as Frame.Close).readReason()
                assertEquals(CloseReason.Codes.NORMAL.code, closeReason?.code)
            }
        }
    }

    @OptIn(ExperimentalSerializationApi::class)
    @Test
    fun `Test when the rider cancel the dispatching process`() {
        withTestApplication({
            webSocketsServer(
                DriverController(driverDataRepository, driverConnections, dispatchDataList, dispatcher),
                DispatchController(driverDataCache, dispatcher, dispatchDataList),
                dispatcher,
                driverDataCache,
                firebaseFirestoreWrapper,
                FirebaseDatabaseWrapper()
            )
        }) {
            // Simulate connected drivers
            for (fakeDriverData in fakeDriverDataList) {
                println("driver = ${fakeDriverData.driverId}")
                launch {
                    try {
                        handleWebSocketConversation("/driver") { incoming, outgoing ->
                            outgoing.send(Frame.Text("${ADD_DRIVER_DATA}:${fakeDriverData.toJson()}"))
                            val rawMessage = incoming.receive()
                            if (rawMessage is Frame.Text) {
                                val message = rawMessage.readText()
                                if (FrameType.fromRawFrame(message) == BOOKING_REQUEST) {
                                    delay(20) // Wait until the rider receive the booking confirmation.
                                    val cancellationMessage = (incoming.receive() as Frame.Text).readText()
                                    assertEquals("$CANCEL_BOOKING", cancellationMessage.substringBefore(":"))
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
                outgoing.send(Frame.Text("${DISPATCH_REQUEST}:${fakeDispatchRequestDataWithGenderFilter.toJson()}"))
                val receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT", receivedMessage.substringBefore(":"))

                val closestDriverData = receivedMessage.substringAfter(":").decodeFromJson<Pair<DriverData, Element>>()
                assertEquals("garageMalal", closestDriverData.first.driverId)
                delay(1_000)
                assertFalse(driverDataCache.contains(closestDriverData.first))
                assertNull(driverDataRepository.getDriverData(closestDriverData.first.driverId))// Once we send a booking request to the
                // driver he/she shouldn't be available for until he refuse the booking or he/she complete it.

                outgoing.send(Frame.Text("${CANCEL_BOOKING}:"))

                val closeReason = (incoming.receive() as Frame.Close).readReason()
                assertEquals(CloseReason.Codes.NORMAL.code, closeReason?.code)

                delay(1_000)

                assertTrue(driverDataCache.contains(closestDriverData.first))// When a rider
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
                DriverController(driverDataRepository, driverConnections, dispatchDataList, dispatcher),
                DispatchController(driverDataCache, dispatcher, dispatchDataList),
                dispatcher,
                driverDataCache,
                firebaseFirestoreWrapper,
                FirebaseDatabaseWrapper()
            )
        }) {
            // Simulate connected drivers
            for (fakeDriverData in fakeDriverDataList) {
                println("driver = ${fakeDriverData.driverId}")
                launch {
                    try {

                        handleWebSocketConversation("/driver") { incoming, outgoing ->
                            outgoing.send(Frame.Text("${ADD_DRIVER_DATA}:${fakeDriverData.toJson()}"))
                            val rawMessage = incoming.receive()
                            if (rawMessage is Frame.Text) {
                                val message = rawMessage.readText()
                                if (FrameType.fromRawFrame(message) == BOOKING_REQUEST) {
                                    delay(20) // Wait until the rider receive the booking confirmation.
                                    val bookingData =
                                        Json.decodeFromString<DispatchRequestData>(message.substringAfter(":"))
                                    // The closest driver refuse the booking.
                                    delay(1_000) // Wait until the rider receive the bs (booking sent message)
                                    outgoing.send(Frame.Text("${REFUSE_BOOKING}:${bookingData.riderId}"))
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
                outgoing.send(Frame.Text("${DISPATCH_REQUEST}:${fakeDispatchRequestData.toJson()}"))

                // ------------------ DRIVER 1 ---------------- //

                var receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT", receivedMessage.substringBefore(":"))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${REFUSE_BOOKING}:1", receivedMessage)
                delay(1_000)

                // ------------------ DRIVER 2 ---------------- //

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT", receivedMessage.substringBefore(":"))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${REFUSE_BOOKING}:2", receivedMessage)
                delay(1_000)

                // ------------------ DRIVER 3 ---------------- //

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT", receivedMessage.substringBefore(":"))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${REFUSE_BOOKING}:3", receivedMessage)
                delay(1_000)

                // ------------------ DRIVER 4 ---------------- //

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("$BOOKING_SENT", receivedMessage.substringBefore(":"))

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${REFUSE_BOOKING}:4", receivedMessage)
                delay(1_000)

                receivedMessage = (incoming.receive() as Frame.Text).readText()
                assertEquals("${NO_MORE_DRIVER_AVAILABLE}:", receivedMessage) // all drivers have refuse the booking
            }
        }
    }

}

