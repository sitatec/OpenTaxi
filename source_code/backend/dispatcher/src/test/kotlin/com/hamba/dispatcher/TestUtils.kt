package com.hamba.dispatcher

import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.hamba.dispatcher.data.model.DispatchRequestData
import com.hamba.dispatcher.data.model.DriverData
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import java.io.FileInputStream

@OptIn(ExperimentalSerializationApi::class)
fun DispatchRequestData.toJson() = Json.encodeToString(this)

@OptIn(ExperimentalSerializationApi::class)
fun DriverData.toJson() = Json.encodeToString(this)

@OptIn(ExperimentalSerializationApi::class)
inline fun <reified T> String.decodeFromJson() = Json.decodeFromString<T>(this)
