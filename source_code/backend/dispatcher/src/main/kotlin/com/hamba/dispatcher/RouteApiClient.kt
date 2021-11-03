package com.hamba.dispatcher

import com.hamba.dispatcher.model.DistanceMatrixResponse
import com.hamba.dispatcher.model.Element
import com.hamba.dispatcher.model.Location
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

const val API_KEY = "AIzaSyAwvDFbXeO-hMSzDldugtisPhk_MArmztA"

private const val BASE_URL = "https://maps.googleapis.com/maps/api"
private const val DISTANCE_MATRIX_URL = "$BASE_URL/distancematrix/json?key=$API_KEY"
private const val DIRECTION_URL = "$BASE_URL/directions/json?key=$API_KEY"

class RouteApiClient(private val httpClient: HttpClient = HttpClient(CIO)) {

    suspend fun distanceMatrix(origins: List<Location>, destination: Location): List<Element> {
        val url = "$DISTANCE_MATRIX_URL&origins=${origins.joinToString("|")}&destinations=$destination"
        val httpRawResponse: String = httpClient.get(url)
        val httpJsonResponse = Json.decodeFromString<DistanceMatrixResponse>(httpRawResponse)
        return httpJsonResponse.rows.map { it.elements.first() }
    }

    suspend fun findDirection(origin: Location, destination: String, stops: List<String>): String {
        val url = "$DIRECTION_URL&origin=$origin&destination=$destination&waypoints=${stops.joinToString("|")}"
        return httpClient.get(url)
    }

    fun release() {
        httpClient.close()
    }
}
