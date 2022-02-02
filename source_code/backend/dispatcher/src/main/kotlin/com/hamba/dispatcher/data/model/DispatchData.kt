package com.hamba.dispatcher.data.model

import com.hamba.dispatcher.utils.formatDuration
import io.ktor.websocket.*
import java.time.Duration
import java.time.Period
import java.util.*

class DispatchData(
    val id: String,
    candidates: List<Pair<DriverData, DistanceMatrixElement>>,
    val dispatchRequestData: DispatchRequestData,
    val riderConnection: DefaultWebSocketServerSession,
    val directions: List<DirectionAPIResponse>,
) {
    init {
        require(candidates.isNotEmpty())
    }

    var currentBookingRequestTimeout: TimerTask? = null
    var numberOfCandidateProvided = 0
    val candidates: MutableList<Pair<DriverData, DistanceMatrixElement>> =
        Collections.synchronizedList(candidates.sortedBy { it.second.durationInTraffic.value }.toMutableList())

    fun getNextClosestCandidateOrNull(): Pair<DriverData, DistanceMatrixElement>? {
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

    fun getDistanceAndDurationFromPickupToDropOff(format: Boolean = true): Pair<String, String> {
        var distance = 0L
        var duration = 0L
        directions.forEach {
            it.routes.forEach { route ->
                route.legs.forEach { leg ->
                    distance += leg.distance!!.value
                    duration += leg.durationInTraffic!!.value// TODO fix: get the value and then format it at the end.

                }
            }
        }
        if(format){
            if (distance > 1000) {
                return Pair(String.format("%.2f km", distance / 1000.0), Duration.ofSeconds(duration).formatDuration())
            }
            return Pair("$distance m", Duration.ofSeconds(duration).formatDuration())
        }
        return Pair(distance.toString(), duration.toString())
    }
}