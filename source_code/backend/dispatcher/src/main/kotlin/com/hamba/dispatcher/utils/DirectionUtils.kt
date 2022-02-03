package com.hamba.dispatcher.utils

import com.hamba.dispatcher.data.model.DirectionAPIResponse

fun getDistanceAndDurationFromDriverLocationToPickup(direction: DirectionAPIResponse): Pair<Long, Long> {
    var distance = 0L
    var duration = 0L
    direction.routes.forEach { route ->
        route.legs.forEach { leg ->
            distance += leg.distance!!.value
            duration += leg.durationInTraffic!!.value

        }
    }
    return Pair(distance, duration)
}