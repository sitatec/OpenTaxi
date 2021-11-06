package com.hamba.dispatcher.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
class DriverData(
    @SerialName("id") var driverId: String? = null,
    @SerialName("loc") var location: Location,
    @SerialName("gnr") val gender: String,
    @SerialName("crT") val carType: String,
    @SerialName("cID") val cellId: ULong? = null
)
