package com.hamba.dispatcher

import com.hamba.dispatcher.model.DispatchRequestData
import com.hamba.dispatcher.model.DriverData
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

@OptIn(kotlinx.serialization.ExperimentalSerializationApi::class)
fun DispatchRequestData.toJson() = Json.encodeToString(this)
@OptIn(kotlinx.serialization.ExperimentalSerializationApi::class)
fun DriverData.toJson() = Json.encodeToString(this)