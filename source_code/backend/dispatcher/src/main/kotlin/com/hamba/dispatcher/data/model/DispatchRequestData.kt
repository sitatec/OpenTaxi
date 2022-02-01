package com.hamba.dispatcher.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
class DispatchRequestData(
    @SerialName("id") val riderId: String,
    @SerialName("nam") val riderName: String,// TODO remove this field and make a request using the rider's id to get the name from the data access server.
    @SerialName("loc") val pickUpLocation: Location,
    @SerialName("des") val dropOffLocation: Location,
    @SerialName("pym") val paymentMethod: String,
    @SerialName("stp") val stops: List<Location> = emptyList(),
    @SerialName("gnr") val gender: String? = null,
    @SerialName("crT") val carType: String? = null,
    @SerialName("tim") val timestamp: Long? = null,
) {
    fun isFutureBookingRequest() = timestamp != null
}