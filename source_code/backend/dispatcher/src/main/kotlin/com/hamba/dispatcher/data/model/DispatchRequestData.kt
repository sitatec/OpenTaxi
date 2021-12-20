package com.hamba.dispatcher.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
class  DispatchRequestData(
    @SerialName("id") val riderId: String,
    @SerialName("loc") val pickUpLocation: Location,
    @SerialName("des") val dropOffLocation: Location,
    @SerialName("pym") val paymentMethod: String,
    @SerialName("stp") val stops: List<Location> = emptyList(),
    @SerialName("gnr") val gender: String? = null,
    @SerialName("crT") val carType: String? = null,
)