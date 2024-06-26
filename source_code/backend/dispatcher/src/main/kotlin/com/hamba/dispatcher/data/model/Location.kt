package com.hamba.dispatcher.data.model

import dilivia.s2.S2CellId
import dilivia.s2.S2Point
import kotlinx.serialization.Serializable
import dilivia.s2.S2LatLng
import kotlinx.serialization.SerialName

@Serializable
data class Location(
    @SerialName("lat") val latitude: Double? = null,
    @SerialName("lng") val longitude: Double? = null,
    @SerialName("adr") val formattedAddress: String? = null,
    @SerialName("pId") private val placeId: String? = null,
    @SerialName("cod") internal val postalCode: String? = null,
    @SerialName("cit") internal val city: String? = null,
    @SerialName("pro") internal val province: String? = null,
) {
    init {
        require((latitude != null && longitude != null) || formattedAddress != null || placeId != null) {
            "Both (latitude, longitude), formattedAddress and placeId can't be null, One of those values must be specified"
        }
    }

    fun toCellID(): S2CellId {
        return S2CellId.fromLatLng(S2LatLng.fromDegrees(latitude!!, longitude!!))
    }

    override fun toString(): String {
        return if (placeId != null) "place_id:$placeId" else if (latitude != null && longitude != null) "$latitude,$longitude" else formattedAddress!!
    }
}