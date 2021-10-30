package com.hamba.dispatcher.model

import kotlinx.serialization.Serializable

@Serializable
class RequestData(val id: String, var location: Location, val gender: String, val carType: String) :
    Comparable<RequestData> {
    override fun compareTo(other: RequestData): Int {
        return if (this == other) 0
        else -1
    }
}
