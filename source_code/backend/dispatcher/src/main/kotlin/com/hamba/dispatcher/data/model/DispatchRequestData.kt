package com.hamba.dispatcher.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
class  DispatchRequestData(
    @SerialName("id") val riderId: String,
    @SerialName("loc") var pickUpLocation: Location,
    @SerialName("des") var dropOfLocation: Location,
    @SerialName("gnr") val gender: String? = null,
    @SerialName("crT") val carType: String? = null,
)