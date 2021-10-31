package com.hamba.dispatcher.model

import dilivia.s2.S2Point
import kotlinx.serialization.Serializable
import dilivia.s2.S2LatLng

@Serializable
class Location(private val lat: Double, private val lng: Double, private val placeId: String? = null) {
    fun toS2Point(): S2Point {
        return S2LatLng.fromDegrees(lat, lng).toPoint();
    }

    override fun toString(): String {
        return if(placeId != null) "place_id:$placeId" else "$lat,$lng"
    }
}

fun S2Point.toLocation(): Location {
    val latLong = S2LatLng.fromPoint(this)
    return Location(latLong.latRadians, latLong.lngRadians)
}