package com.hamba.dispatcher.data

import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.data.model.Location
import com.hamba.dispatcher.services.api.FirebaseDatabaseWrapper
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

@OptIn(ExperimentalSerializationApi::class)
class DriverDataRepository(private val firebaseDatabaseClient: FirebaseDatabaseWrapper) {
    // TODO create a utils package with JsonUtils file on it and refactor all json conversion

    suspend fun getDriverData(driverId: String): DriverData {
        // TODO handle where driver with `driverId` doesn't exist
        return firebaseDatabaseClient.getData<DriverData>("drivers/$driverId").apply { this.driverId = driverId }
    }

    suspend fun getAllData(): List<DriverData> {
        val driversJsonData: Map<String, Any> = firebaseDatabaseClient.getData("drivers")
        return driversJsonData.toDriverData()
    }

    fun addDriverData(data: DriverData) {
        data.cellId = data.location.toCellID().id
        firebaseDatabaseClient.putData("drivers/${data.driverId}", data.toJsonForFirebaseDb())
    }

    fun updateDriverLocation(driverId: String, location: Location) {
        val cellId = location.toCellID().id
        val locationJson = Json.encodeToString(location)
        val jsonData = mapOf("loc" to locationJson, "cID" to cellId)
        firebaseDatabaseClient.patchData("drivers/$driverId", jsonData)
    }

    fun deleteDriverData(driverId: String) {
        firebaseDatabaseClient.deleteData("drivers/$driverId")
    }

    fun onDriverAdded(): Flow<DriverData> = firebaseDatabaseClient.onChildAdd<DriverData>("drivers").map {
        it.second.driverId = it.first
        it.second
    }

    fun onDriverDeleted(): Flow<String> = firebaseDatabaseClient.onChildDeleted("drivers")

    fun onDriverUpdated(vararg fields: String): Flow<Map<String, Any>> = firebaseDatabaseClient.onChildUpdated("drivers", *fields)

    private fun Map<String, Any>.toDriverData(): List<DriverData> {
        return map { (driverId, driverData) ->
            driverData as Map<*, *>
            val locationMap = driverData["loc"] as Map<*, *>
            val location = Location(locationMap["lat"] as Double, locationMap["lng"] as Double)
            DriverData(
                location,
                driverData["gnr"] as String,
                driverData["crT"] as String,
                driverId,
                driverData["cID"] as ULong
            )
        }
    }

    private fun DriverData.toJsonForFirebaseDb(): String {
        val locationJson = Json.encodeToString(location)
        // We are using the driver's id as the node's key in firebase db,
        // so we exclude it from the serialized fields to prevent duplication.
        return "{loc:$locationJson,gnr:$gender,crT:$carType,cID:$cellId}"
    }
}
