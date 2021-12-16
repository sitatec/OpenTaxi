package com.hamba.dispatcher.data.model

import io.ktor.websocket.*
import java.util.*

class DispatchData(
    val id: String,
    candidates: List<Pair<DriverData, Element>>,
    val dispatchRequestData: DispatchRequestData,
    val riderConnection: DefaultWebSocketServerSession
) {
    init {
        require(candidates.isNotEmpty())
    }

    var currentBookingRequestTimeout: TimerTask? = null
    var numberOfCandidateProvided = 0
    val candidates: MutableList<Pair<DriverData, Element>> =
        Collections.synchronizedList(candidates.sortedBy { it.second.durationInTraffic.value }.toMutableList())

    fun getNextClosestCandidateOrNull(): Pair<DriverData, Element>? {
        if (candidates.isEmpty()) return null

        if (numberOfCandidateProvided > 0) {
            candidates.removeFirst()
            if (candidates.isEmpty()) return null
        }
        numberOfCandidateProvided++
        return candidates.first()
    }

    fun getDestination() = dispatchRequestData.pickUpLocation


    fun getCurrentCandidate() = candidates.first()
}