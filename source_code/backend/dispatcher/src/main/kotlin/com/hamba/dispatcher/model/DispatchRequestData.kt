package com.hamba.dispatcher.model

import kotlinx.serialization.Serializable

@Serializable
class  DispatchRequestData(
    val riderId: String,
    var location: Location,
    val gender: String,
    val carType: String,
    val stops: List<String>,
    val destination: String,
)