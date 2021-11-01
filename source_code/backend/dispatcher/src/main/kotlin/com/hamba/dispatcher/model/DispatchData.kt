package com.hamba.dispatcher.model

import io.ktor.websocket.*
import java.util.concurrent.atomic.AtomicInteger


class DispatchData(
    private val candidates: Map<String, Location>,
    private val dispatchRequestData: DispatchRequestData,
    val riderConnection: DefaultWebSocketServerSession
){
    companion object {
        var nextId = AtomicInteger(0) // Using AtomicInteger for thread safety.
    }

    fun getClosestCandidateLocation(): Location {

    }

    fun getDestination(): Location {

    }

    fun getStops(): List<String> {

    }

}