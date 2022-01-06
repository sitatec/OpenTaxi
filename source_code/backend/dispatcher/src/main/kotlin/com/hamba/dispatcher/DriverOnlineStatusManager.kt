package com.hamba.dispatcher

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

const val DRIVER_DATA_URL = "https://hamba-project.uc.r.appspot.com/driver"
private const val SERVERS_ACCESS_TOKEN = "skfS43Z5ljSFSJS_sjzr-kss4643jslSGSAOPBN?p"
// TODO create a authentication system for the servers as well, instead of using a hard coded token.

// TODO find a solution for testing without having to "shadow" the method by overriding them and make the final by removing the open keyword.
open class DriverOnlineStatusManager(private val httpClient: HttpClient = HttpClient(CIO)) {

    open suspend fun goOnline(driverId: String) = setIsOnline(driverId, isOnline = true)

    open suspend fun goOffline(driverId: String) = setIsOnline(driverId, isOnline = false)

    open suspend fun canGoOnline(driverId: String): Boolean {
        val response = httpClient.get<JsonObject>("$DRIVER_DATA_URL/data/account_status?account_id=$driverId");
        return response["data"]?.jsonObject?.get("account_status")?.jsonPrimitive.toString() == "LIVE";
    }

    private suspend fun setIsOnline(driverId: String, isOnline: Boolean) {
        httpClient.patch<HttpResponse>("$DRIVER_DATA_URL/$driverId") {
            contentType(ContentType.Application.Json)
            body = Json.encodeToString(mapOf("is_online" to isOnline))
            header("Authorization", "Bearer $SERVERS_ACCESS_TOKEN")
        }
    }

    fun release() = httpClient.close()
}