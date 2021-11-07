package com.hamba.dispatcher.data.model

import dilivia.s2.S2CellId
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
    fun toCellID(): S2CellId {
        return S2CellId.fromLatLng(S2LatLng.fromDegrees(latitude, longitude))
    }

    override fun toString(): String {
        return if (placeId != null) "place_id:$placeId" else "$latitude,$longitude"
    }
}

fun ULong.toLocation(): Location {
    val latLong = S2CellId(this).toLatLng()
    return Location(latLong.latRadians, latLong.lngRadians)
}