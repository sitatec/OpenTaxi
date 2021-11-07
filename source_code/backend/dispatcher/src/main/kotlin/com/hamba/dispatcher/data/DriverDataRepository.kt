package com.hamba.dispatcher.data

import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.data.model.Location
import com.hamba.dispatcher.services.api.FirebaseDatabaseClient
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.decodeFromString
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

@OptIn(ExperimentalSerializationApi::class)
class DriverDataRepository(private val firebaseDatabaseClient: FirebaseDatabaseClient) {
    // TODO create a utils package with JsonUtils file on it and refactor all json conversion
    private val dataChangeListener = mutableListOf<DataChangeListener>()

    fun addDataChangeListener(listener: DataChangeListener) = dataChangeListener.add(listener)

    suspend fun getDriverData(driverId: String): DriverData {
        // TODO handle where driver with `driverId` doesn't exist
        val queryBuilder = FirebaseDatabaseClient.QueryBuilder("drivers/$driverId")
        val driverJsonData = firebaseDatabaseClient.getData(queryBuilder)
        return Json.decodeFromString<DriverData>(driverJsonData).apply { this.driverId = driverId }
    }

    suspend fun getAllData(): List<DriverData> {
        val queryBuilder = FirebaseDatabaseClient.QueryBuilder("drivers")
        val driversJsonData = firebaseDatabaseClient.getData(queryBuilder)
        return Json.decodeFromString<Map<String, Map<String, Any>>>(driversJsonData).toDriverData()
    }

    suspend fun addDriverData(data: DriverData) {
        val queryBuilder = FirebaseDatabaseClient.QueryBuilder("drivers/${data.driverId}")
        data.cellId = data.location.toCellID().id
        firebaseDatabaseClient.putData(queryBuilder, data.toJsonForFirebaseDb())
    }

    suspend fun updateDriverLocation(driverId: String, location: Location) {
        val queryBuilder = FirebaseDatabaseClient.QueryBuilder("drivers/$driverId")
        val cellId = location.toCellID().id
        val locationJson = Json.encodeToString(location)
        val jsonData = "{loc: $locationJson, cID: $cellId}"
        firebaseDatabaseClient.patchData(queryBuilder, jsonData)
    }

    suspend fun deleteDriverData(driverId: String) {
        val queryBuilder = FirebaseDatabaseClient.QueryBuilder("drivers/$driverId")
        firebaseDatabaseClient.deleteData(queryBuilder)
    }

    suspend fun findDriversByCellId(minCellId: Long, maxCellId: Long, maxResult: Int = 0): List<DriverData> {
        val queryBuilder = FirebaseDatabaseClient.QueryBuilder(path = "drivers", timeout = "3s")
            .orderBy("cID")
            .startAt(minCellId)
            .endAt(maxCellId)
            .limitToFirst(maxResult)
        return Json.decodeFromString(firebaseDatabaseClient.getData(queryBuilder))
    }

    private fun Map<String, Map<String, Any>>.toDriverData(): List<DriverData> {
        return map { (driverId, driverData) ->
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
