package com.hamba.dispatcher.model

import dilivia.s2.S2Point
import kotlinx.serialization.Serializable
import dilivia.s2.S2LatLng

@Serializable
class Location(val latitude: Double, val longitude: Double) {
    fun toS2Point(): S2Point {
        return S2LatLng.fromDegrees(latitude, longitude).toPoint();
    }
}