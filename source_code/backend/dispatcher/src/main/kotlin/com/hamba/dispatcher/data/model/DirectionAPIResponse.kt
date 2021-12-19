package com.hamba.dispatcher.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class DirectionAPIResponse(
    @SerialName("DirectionsResponse") var Response: Response? = Response()
)


@Serializable
data class Response(
    @SerialName("status") var status: String? = null,
    @SerialName("route") var route: Route? = Route(),
    @SerialName("geocoded_waypoint") var geocodedWaypoint: List<GeocodedWaypoint> = arrayListOf()
)

@Serializable
data class Coordinates(
    @SerialName("lat") var lat: String? = null,
    @SerialName("lng") var lng: String? = null
)

@Serializable
data class Polyline(
    @SerialName("points") var points: String? = null
)

typealias OverviewPolyline = Polyline

@Serializable
data class Step(
    @SerialName("travel_mode") var travelMode: String? = null,
    @SerialName("start_location") var startLocation: Coordinates? = Coordinates(),
    @SerialName("end_location") var endLocation: Coordinates? = Coordinates(),
    @SerialName("polyline") var polyline: Polyline? = Polyline(),
    @SerialName("duration") var duration: Coordinates? = Coordinates(),
    @SerialName("html_instructions") var htmlInstructions: String? = null,
    @SerialName("distance") var distance: Distance
)

@Serializable
data class Leg(
    @SerialName("step") var step: List<Step> = arrayListOf(),
    @SerialName("duration") var duration: Duration? = null,
    @SerialName("distance") var distance: Distance? = null,
    @SerialName("start_location") var startLocation: Coordinates? = Coordinates(),
    @SerialName("end_location") var endLocation: Coordinates? = Coordinates(),
    @SerialName("start_address") var startAddress: String? = null,
    @SerialName("end_address") var endAddress: String? = null
)

@Serializable
data class Southwest(
    @SerialName("lat") var lat: String? = null,
    @SerialName("lng") var lng: String? = null
)

typealias Northeast = Southwest

@Serializable
data class Bounds(
    @SerialName("southwest") var southwest: Southwest? = Southwest(),
    @SerialName("northeast") var northeast: Northeast? = Northeast()
)

@Serializable
data class Route(
    @SerialName("summary") var summary: String? = null,
    @SerialName("leg") var leg: List<Leg> = arrayListOf(),
    @SerialName("copyrights") var copyrights: String? = null,
    @SerialName("overview_polyline") var overviewPolyline: OverviewPolyline? = OverviewPolyline(),
    @SerialName("waypoint_index") var waypointIndex: String? = null,
    @SerialName("bounds") var bounds: Bounds? = Bounds()
)

@Serializable
data class GeocodedWaypoint(
    @SerialName("geocoder_status") var geocoderStatus: String? = null,
    @SerialName("type") var type: List<String> = arrayListOf(),
    @SerialName("place_id") var placeId: String? = null
)