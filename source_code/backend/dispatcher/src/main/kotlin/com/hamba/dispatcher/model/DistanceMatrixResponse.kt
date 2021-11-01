package com.hamba.dispatcher.model

import kotlinx.serialization.Serializable

@Serializable
class DistanceMatrixResponse (
    val destinationAddresses: List<String>,
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
