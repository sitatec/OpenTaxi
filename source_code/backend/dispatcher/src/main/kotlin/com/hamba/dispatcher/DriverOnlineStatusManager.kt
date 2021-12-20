package com.hamba.dispatcher

import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

const val DRIVER_DATA_URL = "https://hamba-project.uc.r.appspot.com/driver"

// TODO find a solution for testing without having to "shadow" the method by overriding them and make the final by removing the open keyword.
open class DriverOnlineStatusManager(private val httpClient: HttpClient = HttpClient(CIO)) {

    open suspend fun goOnline(driverId: String) = setIsOnline(driverId, isOnline = true)

    open suspend fun goOffline(driverId: String) = setIsOnline(driverId, isOnline = false)

    private suspend fun setIsOnline(driverId: String, isOnline: Boolean) {
        httpClient.patch<HttpResponse>("$DRIVER_DATA_URL/$driverId") {
            body = Json.encodeToString(mapOf("isOnline" to isOnline))
        }
    }

    fun release() = httpClient.close()
}