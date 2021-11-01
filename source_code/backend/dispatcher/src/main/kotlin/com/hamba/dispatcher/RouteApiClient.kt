package com.hamba.dispatcher

import com.hamba.dispatcher.model.DistanceMatrixResponse
import com.hamba.dispatcher.model.Location
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*

const val API_KEY = ""

private const val BASE_URL = "https://maps.googleapis.com/maps/api/"
private const val DISTANCE_MATRIX_URL = "$BASE_URL/distancematrix/json?key=$API_KEY"
private const val DIRECTION_URL = "$BASE_URL/directions/json?key=$API_KEY"

class RouteApiClient(private val httpClient: HttpClient = HttpClient(CIO)) {

    suspend fun distanceMatrix(origins: List<Location>, destination: Location): Int {
        val url = "$DISTANCE_MATRIX_URL&origins=${origins.joinToString("|")}&destinations=$destination"
        val httpResponse: DistanceMatrixResponse = httpClient.get(url)
        var indexOfTheClosestLocation = Int.MIN_VALUE
        var distanceOfToTheClosestLocation = Long.MIN_VALUE
        httpResponse.rows.first().elements.forEachIndexed { index, element ->
            if(element.distance.value < distanceOfToTheClosestLocation){
                distanceOfToTheClosestLocation = element.distance.value
                indexOfTheClosestLocation = index
            }
        }
        return indexOfTheClosestLocation;
    }

    suspend fun findDirection(origin: Location, destination: Location, stops: List<String>): String {
        val url = "$DIRECTION_URL&origin=$origin&destination=$destination&waypoints=${stops.joinToString("|")}"
        return httpClient.get(url)
    }

    fun release() {
        httpClient.close()
    }
}
