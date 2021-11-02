package com.hamba.dispatcher.model

import io.ktor.websocket.*
import java.util.concurrent.atomic.AtomicInteger


class DispatchData(
    candidates: List<Pair<DriverData, Element>>,
    private val dispatchRequestData: DispatchRequestData,
    val riderConnection: DefaultWebSocketServerSession
) {
    var nextCandidateIndex = 0
    private val candidates = candidates.sortedBy { it.second.duration.value }

    companion object {
        var nextId = AtomicInteger(0) // Using AtomicInteger for thread safety.
    }

    fun getNextClosestCandidateOrNull():Pair<DriverData, Element>? {
        if(nextCandidateIndex >= candidates.size) {
            return null
        }
        return candidates[nextCandidateIndex++]
    }

    fun getDestination() = dispatchRequestData.destination


    fun getStops() = dispatchRequestData.stops

    fun getCurrentCandidate(): Pair<DriverData, Element> {
        if(nextCandidateIndex == 0) return candidates.first()
        return candidates[nextCandidateIndex - 1]
    }
}