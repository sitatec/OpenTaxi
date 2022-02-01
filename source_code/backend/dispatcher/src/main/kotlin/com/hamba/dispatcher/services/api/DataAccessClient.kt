package com.hamba.dispatcher.services.api

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

private const val DATA_ACCESS_SERVER_URL = "https://hamba-project.uc.r.appspot.com"
private const val SERVERS_ACCESS_TOKEN = "skfS43Z5ljSFSJS_sjzr-kss4643jslSGSAOPBN?p"
// TODO create a authentication system for the servers as well, instead of using a hard coded token.

/**
 * A Client of the data access server.
 */
class DataAccessClient(private val httpClient: HttpClient = HttpClient(CIO)) {

    suspend fun createTrip(tripData: JsonObject): Map<String, String> {
        val response: JsonObject = httpClient.post("$DATA_ACCESS_SERVER_URL/trip/with_booking") {
            contentType(ContentType.Application.Json)
            body = Json.encodeToString(tripData)
            header("Authorization", "Bearer $SERVERS_ACCESS_TOKEN")
        }
        if(response["status"]!!.jsonPrimitive.toString() == "success"){
            return response["data"]!!.jsonObject.mapValues { it.value.jsonPrimitive.toString() }
        }else{
            throw Exception(message = "Failed to Create Trip")
        }
    }

    suspend fun createBooking(bookingData: JsonObject): String {
        val response: JsonObject = httpClient.post("$DATA_ACCESS_SERVER_URL/booking/with_addresses") {
            contentType(ContentType.Application.Json)
            body = Json.encodeToString(bookingData)
            header("Authorization", "Bearer $SERVERS_ACCESS_TOKEN")
        }
        if(response["status"]!!.jsonPrimitive.toString() == "success"){
            return response["data"]!!.jsonPrimitive.toString()
        }else{
            throw Exception(message = "Failed to Create Booking")
        }
    }

    suspend fun setDriverIsOnline(driverId: String, isOnline: Boolean) {
        httpClient.patch<HttpResponse>("${DATA_ACCESS_SERVER_URL}/driver/$driverId") {
            contentType(ContentType.Application.Json)
            body = Json.encodeToString(mapOf("is_online" to isOnline))
            header("Authorization", "Bearer $SERVERS_ACCESS_TOKEN")
        }
    }

    suspend fun getUserAccountStatus(userId: String): String {
        val response =
            httpClient.get<JsonObject>("${DATA_ACCESS_SERVER_URL}/account/account_status?id=$userId")
        return response["data"]?.jsonObject?.get("account_status")?.jsonPrimitive.toString()
    }

    fun release() = httpClient.close()
}