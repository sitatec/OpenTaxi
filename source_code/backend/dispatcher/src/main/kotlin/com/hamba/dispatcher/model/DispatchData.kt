package com.hamba.dispatcher.model

import com.hamba.dispatcher.Dispatcher
import io.ktor.websocket.*

class DispatchData(
    candidates: List<Pair<DriverData, Element>>,
    val dispatchRequestData: DispatchRequestData,
    val riderConnection: DefaultWebSocketServerSession
) {
    var nextCandidateIndex = 0
    val candidates = candidates.sortedBy { it.second.duration.value }.toMutableList()

    fun getNextClosestCandidateOrNull(): Pair<DriverData, Element>? {
        if (nextCandidateIndex >= candidates.size) {
            return null
        }
        candidates.removeAt(nextCandidateIndex - 1 /*Current Candidate Index*/)
        return candidates[nextCandidateIndex++]
    }

    fun getDestination() = dispatchRequestData.destination


    fun getStops() = dispatchRequestData.stops

    fun getCurrentCandidate(): Pair<DriverData, Element> {
        if (nextCandidateIndex == 0) return candidates.first()
        return candidates[nextCandidateIndex - 1]
    }
}