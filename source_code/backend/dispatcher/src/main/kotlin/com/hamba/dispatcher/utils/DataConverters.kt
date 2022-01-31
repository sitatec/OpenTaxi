package com.hamba.dispatcher.utils

import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.data.model.Location
import dilivia.s2.S2CellId
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put


fun Map<String, Any>.toDriverData(driverId: String = this["id"] as String): DriverData {
    val locationMap = this["loc"] as Map<*, *>
    val location = Location(locationMap["lat"] as Double, locationMap["lng"] as Double)
    return DriverData(
        location,
        this["gnr"] as String,
        this["crT"] as String,
        driverId,
        (this["cID"] as Long).toULong()
    )
}

fun DriverData.toJsonForFirebaseDb(): Map<String, *> {
    val locationJson = location.toJsonForFirebaseDb()
    // We are using the driver's id as the node's key in firebase db,
    // so we exclude it from the serialized fields to prevent duplication. Long().toULong()
    return mapOf("loc" to locationJson, "gnr" to gender, "crT" to carType, "cID" to cellId.toLong())
}

fun Location.toJsonForFirebaseDb() = mapOf("lat" to latitude, "lng" to longitude)

fun ULong.toCellId() = S2CellId(this)

fun Location.toJsonForDataAccessServer() = buildJsonObject {
    put("street_address", formattedAddress)
    put("postal_code", postalCode)
    put("city", city)
    put("province", province)
}