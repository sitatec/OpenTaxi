package com.hamba.dispatcher.model

import kotlinx.serialization.Serializable

@Serializable
data class DriverData(val id: String, var location: Location, val gender: String, val carType: String) :
    Comparable<DriverData> {
    override fun compareTo(other: DriverData): Int {
        return if (this == other) 0
        else -1
    }
}
