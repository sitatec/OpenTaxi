package com.hamba.dispatcher.services.api

import com.hamba.dispatcher.data.model.DirectionAPIResponse
import com.hamba.dispatcher.data.model.DistanceMatrixResponse
import com.hamba.dispatcher.data.model.DistanceMatrixElement
import com.hamba.dispatcher.data.model.Location
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*
import kotlinx.coroutines.*
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.json.Json

const val API_KEY = "AIzaSyAwvDFbXeO-hMSzDldugtisPhk_MArmztA"

private const val BASE_URL = "https://maps.googleapis.com/maps/api"
private const val DISTANCE_MATRIX_URL = "$BASE_URL/distancematrix/json?departure_time=now&language=en&key=$API_KEY"
private const val DIRECTION_URL = "$BASE_URL/directions/json?departure_time=now&language=en&key=$API_KEY"

class RouteApiClient(private val httpClient: HttpClient = HttpClient(CIO)) {

    @OptIn(ExperimentalSerializationApi::class)
    suspend fun distanceMatrix(origins: List<Location>, destination: Location): List<DistanceMatrixElement> {
        val url = "$DISTANCE_MATRIX_URL&origins=${origins.joinToString("|")}&destinations=$destination"
        return withContext(Dispatchers.IO) {
            val httpRawResponse: String = httpClient.get(url)
            val httpJsonResponse = Json.decodeFromString<DistanceMatrixResponse>(httpRawResponse)
            httpJsonResponse.rows.map { it.distanceMatrixElements.first() }
        }
    }

    suspend fun findDirection(origin: Location, destination: Location): String {
        return withContext(Dispatchers.IO) {
            httpClient.get(buildDirectionUrl(origin, destination))
        }
    }

    suspend fun getConsecutiveDirections(locations: List<Location>): List<DirectionAPIResponse> {
        // TODO
        val lastLocationIndex = locations.lastIndex
        var currentLocationIndex = 0
        val result = mutableListOf<Deferred<DirectionAPIResponse>>()
        var currentUrl: String
        withContext(Dispatchers.IO) {
            while (currentLocationIndex < lastLocationIndex) {
                currentUrl = buildDirectionUrl(locations[currentLocationIndex], locations[++currentLocationIndex])
                result.add(async {
                    val response: String = httpClient.get(currentUrl)
                    Json.decodeFromString(response)
                })
            }
        }
        return awaitAll(*result.toTypedArray())
    }

    private fun buildDirectionUrl(origin: Location, destination: Location) =
        "$DIRECTION_URL&origin=$origin&destination=$destination"

    fun release() {
        httpClient.close()
    }
}
