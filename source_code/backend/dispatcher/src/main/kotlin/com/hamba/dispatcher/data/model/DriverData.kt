package com.hamba.dispatcher.data.model

import com.hamba.dispatcher.utils.toCellId
import dilivia.s2.index.point.PointData
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
class DriverData(
    // TODO remove abbreviations from all Data models (on the properties @SerialNames)
    @SerialName("loc") var location: Location,
    @SerialName("gnr") val gender: String,
    @SerialName("crT") val carType: String,
    @SerialName("nam") val name: String,
    @SerialName("id") var driverId: String = "",
    @SerialName("cID") var cellId: ULong = 0UL
) : Comparable<DriverData> {
    override fun compareTo(other: DriverData): Int {
        val cellIdComparison = cellId.compareTo(other.cellId)
        return if(cellIdComparison == 0) driverId.compareTo(other.driverId) else cellIdComparison
    }

    fun toPointData() = PointData(cellId.toCellId().toPoint(), this)
}
