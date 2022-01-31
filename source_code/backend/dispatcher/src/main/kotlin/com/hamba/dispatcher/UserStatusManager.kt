package com.hamba.dispatcher

import com.hamba.dispatcher.services.api.DataAccessClient
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

// TODO find a solution for testing without having to "shadow" the method by overriding them and make the final by removing the open keyword.
class UserStatusManager(private val dataAccessClient: DataAccessClient) {

    suspend fun driverGoOnline(driverId: String) = dataAccessClient.setDriverIsOnline(driverId, isOnline = true)

    suspend fun driverGoOffline(driverId: String) = dataAccessClient.setDriverIsOnline(driverId, isOnline = false)

    suspend fun userCanConnect(userId: String): Boolean {
        return dataAccessClient.getUserAccountStatus(userId) == "LIVE";
    }

    fun release() = dataAccessClient.release()
}