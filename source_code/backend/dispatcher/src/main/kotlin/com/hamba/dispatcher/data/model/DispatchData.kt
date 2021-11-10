package com.hamba.dispatcher.data.model

import io.ktor.websocket.*
import java.util.*

class DispatchData(
    candidates: List<Pair<DriverData, Element>>,
    val dispatchRequestData: DispatchRequestData,
    val riderConnection: DefaultWebSocketServerSession
) {
    init {
        require(candidates.isNotEmpty())
    }

    var nextClosestCandidateIndex = 0
    val candidates = candidates.sortedBy { it.second.duration.value }.toMutableList()

    fun getNextClosestCandidateOrNull(): Pair<DriverData, Element>? {
        if (nextClosestCandidateIndex >= candidates.size) {
            return null
        }
        if (nextClosestCandidateIndex > 0) {
            candidates.removeAt(nextClosestCandidateIndex - 1 /*Current Candidate Index*/)
            return candidates[nextClosestCandidateIndex]
        }
        return candidates[nextClosestCandidateIndex++]
    }

    fun getDestination() = dispatchRequestData.destination

    fun getStops() = dispatchRequestData.stops

    fun getCurrentCandidate(): Pair<DriverData, Element> {
        if (nextClosestCandidateIndex == 0) return candidates.first()
        return candidates[nextClosestCandidateIndex - 1]
    }
}