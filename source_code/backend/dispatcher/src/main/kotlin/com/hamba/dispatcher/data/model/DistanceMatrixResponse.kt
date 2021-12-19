package com.hamba.dispatcher.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
class DistanceMatrixResponse (
    @SerialName("destination_addresses")
    val destinationAddresses: List<String>,

    @SerialName("origin_addresses")
    val originAddresses: List<String>,

    val rows: List<Row>,
    val status: String
)

@Serializable
class Row (
    val distanceMatrixElements: List<DistanceMatrixElement>
)

@Serializable
class DistanceMatrixElement (
    val distance: Distance,
    val duration: Duration,
    @SerialName("duration_in_traffic")
    val durationInTraffic: Distance,
    val status: String
)

typealias Duration = Distance

@Serializable
class Distance (
    val text: String,
    val value: Long
)

private val EmptyDistance = Distance("", 0)
val EmptyDistanceMatrixElement = DistanceMatrixElement(EmptyDistance, EmptyDistance, EmptyDistance,"")
