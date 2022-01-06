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

const val DATA_ACCESS_SERVER_URL = "https://hamba-project.uc.r.appspot.com"
private const val SERVERS_ACCESS_TOKEN = "skfS43Z5ljSFSJS_sjzr-kss4643jslSGSAOPBN?p"
// TODO create a authentication system for the servers as well, instead of using a hard coded token.

// TODO find a solution for testing without having to "shadow" the method by overriding them and make the final by removing the open keyword.
open class UserStatusManager(private val httpClient: HttpClient = HttpClient(CIO)) {

    open suspend fun driverGoOnline(driverId: String) = setDriverIsOnline(driverId, isOnline = true)

    open suspend fun driverGoOffline(driverId: String) = setDriverIsOnline(driverId, isOnline = false)

    open suspend fun userCanConnect(userId: String): Boolean {
        val response = httpClient.get<JsonObject>("$DATA_ACCESS_SERVER_URL/account/account_status?id=$userId");
        return response["data"]?.jsonObject?.get("account_status")?.jsonPrimitive.toString() == "LIVE";
    }

    private suspend fun setDriverIsOnline(driverId: String, isOnline: Boolean) {
        httpClient.patch<HttpResponse>("$DATA_ACCESS_SERVER_URL/driver/$driverId") {
            contentType(ContentType.Application.Json)
            body = Json.encodeToString(mapOf("is_online" to isOnline))
            header("Authorization", "Bearer $SERVERS_ACCESS_TOKEN")
        }
    }

    fun release() = httpClient.close()
}