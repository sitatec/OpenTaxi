package com.hamba.dispatcher.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
class DriverData(
    @SerialName("loc") var location: Location,
    @SerialName("gnr") val gender: String,
    @SerialName("crT") val carType: String,
    @SerialName("id") var driverId: String = "",
    @SerialName("cID") var cellId: ULong = 0UL
) : Comparable<DriverData> {
    override fun compareTo(other: DriverData): Int {
        return cellId.compareTo(other.cellId)
    }

}
