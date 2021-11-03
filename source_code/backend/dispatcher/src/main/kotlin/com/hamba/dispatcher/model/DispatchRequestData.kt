package com.hamba.dispatcher.model

import kotlinx.serialization.Serializable

@Serializable
class  DispatchRequestData(
    val riderId: String,
    var location: Location,
    val stops: List<String>,
    val destination: String,
    val gender: String? = null,
    val carType: String? = null,
)