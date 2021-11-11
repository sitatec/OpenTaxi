package com.hamba.dispatcher.data.model

import io.ktor.websocket.*

class DispatchData(
    candidates: List<Pair<DriverData, Element>>,
    val dispatchRequestData: DispatchRequestData,
    val riderConnection: DefaultWebSocketServerSession
) {
    init {
        require(candidates.isNotEmpty())
    }

    var numberOfCandidateProvided = 0
    val candidates = candidates.sortedBy { it.second.duration.value }.toMutableList()

    fun getNextClosestCandidateOrNull(): Pair<DriverData, Element>? {
        if (candidates.isEmpty()) return null

        if (numberOfCandidateProvided > 0) {
            candidates.removeFirst()
            if (candidates.isEmpty()) return null
        }
        numberOfCandidateProvided++
        return candidates.first()
    }

    fun getDestination() = dispatchRequestData.destination

    fun getStops() = dispatchRequestData.stops

    fun getCurrentCandidate() = candidates.first()
}