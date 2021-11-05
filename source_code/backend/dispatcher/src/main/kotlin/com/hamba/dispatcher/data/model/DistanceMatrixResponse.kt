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
    val elements: List<Element>
)

@Serializable
class Element (
    val distance: Distance,
    val duration: Distance,
    val status: String
)

@Serializable
class Distance (
    val text: String,
    val value: Long
)
