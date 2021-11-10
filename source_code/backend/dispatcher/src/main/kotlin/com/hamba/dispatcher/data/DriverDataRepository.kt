package com.hamba.dispatcher.data

import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.data.model.Location
import com.hamba.dispatcher.services.api.FirebaseFirestoreWrapper
import com.hamba.dispatcher.utils.toDriverData
import com.hamba.dispatcher.utils.toJsonForFirebaseDb
import kotlinx.serialization.ExperimentalSerializationApi

@OptIn(ExperimentalSerializationApi::class)
class DriverDataRepository(private val firebaseDatabaseClient: FirebaseFirestoreWrapper) {
    // TODO create a utils package with JsonUtils file on it and refactor all json conversion

    suspend fun getDriverData(driverId: String): DriverData? {
        val result: Any = firebaseDatabaseClient.getData("drivers/$driverId") ?: return null
        return (result as Map<String, Any>).toDriverData(driverId)
    }

    suspend fun getDriversAllData(): List<DriverData> {
        val driversJsonData: List<Map<String, Any>> = firebaseDatabaseClient.getCollection("drivers") ?: return listOf()
        return driversJsonData.map{it.toDriverData()}
    }

    fun addDriverData(data: DriverData) {
        data.cellId = data.location.toCellID().id
        firebaseDatabaseClient.putData("drivers/${data.driverId}", data.toJsonForFirebaseDb())
    }

    fun updateDriverLocation(driverId: String, location: Location) {
        val cellId = location.toCellID().id
        val locationJson = location.toJsonForFirebaseDb()
        val jsonData = mapOf("loc" to locationJson, "cID" to cellId.toLong()) // ULong not supported by firestore serializer
        firebaseDatabaseClient.patchData("drivers/$driverId", jsonData)
    }

    fun deleteDriverData(driverId: String) {
        firebaseDatabaseClient.deleteData("drivers/$driverId")
    }

    private fun Map<String, Any>.toDriverDataList(): List<DriverData> {
        return map { (driverId, driverData) -> (driverData as Map<String, Any>).toDriverData(driverId) }
    }
}
