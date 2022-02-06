package com.hamba.dispatcher.data.model

import com.hamba.dispatcher.utils.getTotalDistanceAndDurationFromDirections
import io.ktor.websocket.*
import kotlinx.serialization.json.*
import java.util.*

class DispatchData(
    val id: String,
    val dispatchRequestData: DispatchRequestData,
    val riderConnection: DefaultWebSocketServerSession,
    private val directions: List<DirectionAPIResponse>,
) {

    /**
     * Return the total distance and duration of all the [directions] of the trip and return them in __meter__ and __second__.
     */
    val tripDistanceAndDuration by lazy { getTotalDistanceAndDurationFromDirections(directions) }
    val tripDirectionPolylines = mutableListOf<String>()

    init {
        directions.forEach {
            it.routes.forEach { route ->
                route.legs.forEach { leg ->
                    tripDirectionPolylines.addAll(leg.steps.map { step -> step.polyline!!.points!! })
                }
            }
        }
    }

    var currentBookingRequestTimeout: TimerTask? = null
    var numberOfCandidateProvided = 0
    var candidates: MutableList<Pair<DriverData, DistanceMatrixElement>> = mutableListOf()
        set(_candidates){
            field = Collections.synchronizedList(_candidates.sortedBy { it.second.durationInTraffic.value }.toMutableList())
        }

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

    fun getTripInfoAsJsonObject(): JsonObject {
        val tripDistanceAndDuration = tripDistanceAndDuration
        val pricesForAllVehicleCategories = getPricesForAllCarCategories(
            tripDistance = tripDistanceAndDuration.first,
            tripDuration = tripDistanceAndDuration.second
        )
        return buildJsonObject {
            put("prices", pricesForAllVehicleCategories)
            put("distance", tripDistanceAndDuration.first)
            put("duration", tripDistanceAndDuration.second)
            putJsonArray("direction_polylines") {
                for (polyline in tripDirectionPolylines)
                    add(polyline)
            }
        }
    }

    private fun getPricesForAllCarCategories(tripDistance: Long, tripDuration: Long): JsonObject {
        // TODO add price by car category (based on distance and duration --ASK LU FOR PRICE RANGE--).
        return buildJsonObject {
            put("STANDARD", "40.00 R")
            put("LITE", "20.00 R")
            put("PREMIUM", "70.00 R")
            put("CREW", "40.00 R")
            put("UBUNTU", "50.00 R")
        }
    }
}