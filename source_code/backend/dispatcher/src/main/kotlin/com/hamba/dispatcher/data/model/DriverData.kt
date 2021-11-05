package com.hamba.dispatcher.data.model

import kotlinx.serialization.Serializable

@Serializable
class DriverData(val driverId: String, var location: Location, val gender: String, val carType: String)
