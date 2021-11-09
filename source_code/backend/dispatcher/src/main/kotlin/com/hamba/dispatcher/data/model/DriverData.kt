package com.hamba.dispatcher.data.model

import dilivia.s2.index.point.PointData
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
        val cellIdComparison = cellId.compareTo(other.cellId)
        return if(cellIdComparison == 0) driverId.compareTo(other.driverId) else cellIdComparison
    }

}
