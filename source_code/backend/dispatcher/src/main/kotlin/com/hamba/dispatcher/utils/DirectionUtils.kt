package com.hamba.dispatcher.utils

import com.hamba.dispatcher.data.model.DirectionAPIResponse
import java.time.Duration

/**
 * Addition the distance and duration of all the given [directions] and return them in __meter__ and __second__.
 */
fun getTotalDistanceAndDurationFromDirections(directions: List<DirectionAPIResponse>): Pair<Long, Long> {
    var distance = 0L
    var duration = 0L
    directions.forEach { direction ->
        direction.routes.forEach { route ->
            route.legs.forEach { leg ->
                distance += leg.distance!!.value
                duration += leg.durationInTraffic!!.value

            }
        }
    }
    return Pair(distance, duration)
}

fun formatDistanceAndDuration(distance: Long, duration: Long): Pair<String, String> {
    if (distance > 1000) {
        return Pair(String.format("%.2f km", distance / 1000.0), Duration.ofSeconds(duration).formatDuration())
    }
    return Pair("$distance m", Duration.ofSeconds(duration).formatDuration())
}