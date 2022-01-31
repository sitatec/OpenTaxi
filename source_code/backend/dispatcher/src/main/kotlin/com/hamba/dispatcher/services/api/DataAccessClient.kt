package com.hamba.dispatcher.services.api

import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*
import io.ktor.http.*
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject

private const val DATA_ACCESS_SERVER_URL = "https://hamba-project.uc.r.appspot.com"
private const val SERVERS_ACCESS_TOKEN = "skfS43Z5ljSFSJS_sjzr-kss4643jslSGSAOPBN?p"

/**
 * A Client of the data access server.
 */
class DataAccessClient(private val httpClient: HttpClient = HttpClient(CIO)) {
    suspend fun createTrip(tripData: JsonObject): Map<String, String>{
        return httpClient.post("$DATA_ACCESS_SERVER_URL/trip/with_booking"){
            contentType(ContentType.Application.Json)
            body = Json.encodeToString(tripData)
            header("Authorization", "Bearer $SERVERS_ACCESS_TOKEN")
        }
    }
}