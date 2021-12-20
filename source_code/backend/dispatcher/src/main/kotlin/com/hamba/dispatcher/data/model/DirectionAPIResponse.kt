package com.hamba.dispatcher.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class DirectionAPIResponse(
    @SerialName("geocoded_waypoints") var geocodedWaypoints: List<GeocodedWaypoints> = arrayListOf(),
    @SerialName("routes") var routes: List<Routes> = arrayListOf(),
    @SerialName("status") var status: String? = null
)

@Serializable
data class GeocodedWaypoints(
    @SerialName("geocoder_status") var geocoderStatus: String? = null,
    @SerialName("place_id") var placeId: String? = null,
    @SerialName("types") var types: List<String> = arrayListOf()
)

@Serializable
data class Coordinates(
    @SerialName("lat") var lat: Double? = null,
    @SerialName("lng") var lng: Double? = null
)

@Serializable
data class Bounds(
    @SerialName("northeast") var northeast: Coordinates? = Coordinates(),
    @SerialName("southwest") var southwest: Coordinates? = Coordinates()
)

@Serializable
data class Polyline(
    @SerialName("points") var points: String? = null
)

@Serializable
data class Steps(
    @SerialName("distance") var distance: Distance? = null,
    @SerialName("duration") var duration: Duration? = null,
    @SerialName("end_location") var endLocation: Coordinates? = Coordinates(),
    @SerialName("html_instructions") var htmlInstructions: String? = null,
    @SerialName("polyline") var polyline: Polyline? = Polyline(),
    @SerialName("start_location") var startLocation: Coordinates? = Coordinates(),
    @SerialName("travel_mode") var travelMode: String? = null
)

@Serializable
data class Legs(
    @SerialName("distance") var distance: Distance? = null,
    @SerialName("duration") var duration: Duration? = null,
    @SerialName("duration_in_traffic" ) var durationInTraffic : Duration? = null,
    @SerialName("end_address") var endAddress: String? = null,
    @SerialName("end_location") var endLocation: Coordinates? = Coordinates(),
    @SerialName("start_address") var startAddress: String? = null,
    @SerialName("start_location") var startLocation: Coordinates? = Coordinates(),
    @SerialName("steps") var steps: List<Steps> = arrayListOf(),
    @SerialName("traffic_speed_entry") var trafficSpeedEntry: List<TrafficSpeedEntry> = arrayListOf(),
    @SerialName("via_waypoint") var viaWaypoint: List<String> = arrayListOf(),
)

@Serializable
data class TrafficSpeedEntry(
    @SerialName("offset_meters") var offsetMeters: Int? = null,
    @SerialName("speed_category") var speedCategory: String? = null
)

@Serializable
data class OverviewPolyline(
    @SerialName("points") var points: String? = null
)

@Serializable
data class Routes(
    @SerialName("bounds") var bounds: Bounds? = Bounds(),
    @SerialName("copyrights") var copyrights: String? = null,
    @SerialName("legs") var legs: List<Legs> = arrayListOf(),
    @SerialName("overview_polyline") var overviewPolyline: OverviewPolyline? = OverviewPolyline(),
    @SerialName("summary") var summary: String? = null,
    @SerialName("warnings") var warnings: List<String> = arrayListOf(),
    @SerialName("waypoint_order") var waypointOrder: List<Int>? = emptyList()
)