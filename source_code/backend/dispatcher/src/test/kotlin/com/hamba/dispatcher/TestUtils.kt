package com.hamba.dispatcher

import com.hamba.dispatcher.data.model.DispatchRequestData
import com.hamba.dispatcher.data.model.DriverData
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

@OptIn(ExperimentalSerializationApi::class)
fun DispatchRequestData.toJson() = Json.encodeToString(this)

@OptIn(ExperimentalSerializationApi::class)
fun DriverData.toJson() = Json.encodeToString(this)

@OptIn(ExperimentalSerializationApi::class)
inline fun <reified T> String.decodeFromJson() = Json.decodeFromString<T>(this)
