package com.hamba.dispatcher.data.model

import dilivia.s2.S2Point
import kotlinx.serialization.Serializable
import dilivia.s2.S2LatLng
import kotlinx.serialization.SerialName

@Serializable
data class Location(
    @SerialName("lat") private val latitude: Double,
    @SerialName("lng") private val longitude: Double,
    @SerialName("pId") private val placeId: String? = null
) {
    fun toS2Point(): S2Point {
        return S2LatLng.fromDegrees(latitude, longitude).toPoint();
    }

    override fun toString(): String {
        return if (placeId != null) "place_id:$placeId" else "$latitude,$longitude"
    }
}

fun S2Point.toLocation(): Location {
    val latLong = S2LatLng.fromPoint(this)
    return Location(latLong.latRadians, latLong.lngRadians)
}