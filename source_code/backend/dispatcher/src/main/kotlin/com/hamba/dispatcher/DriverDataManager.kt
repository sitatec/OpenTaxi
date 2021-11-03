package com.hamba.dispatcher

import com.hamba.dispatcher.model.DriverData
import com.hamba.dispatcher.model.Location
import dilivia.s2.index.point.PointData
import dilivia.s2.index.point.S2PointIndex

class DriverDataManager(val locationIndex: S2PointIndex<String>) {

    private val driverData = mutableMapOf<String, DriverData>()
    private val dataChangeListener = mutableListOf<DataChangeListener>()

    fun addDataChangeListener(listener: DataChangeListener) = dataChangeListener.add(listener)

    fun getDriverData(driverId: String) = driverData[driverId]

    @Synchronized
    fun addDriverData(data: DriverData) {
        val pointData = PointData(data.location.toS2Point(), data.driverId)
        driverData[data.driverId] = data
        locationIndex.add(pointData)
        dataChangeListener.forEach {
            it.onDataAdded()
        }
    }

    @Synchronized
    fun updateDriverData(driverId: String, location: Location) {
        dataChangeListener.forEach {
            it.onDataUpdateNeeded {
                val data = driverData[driverId] ?: return@onDataUpdateNeeded
                locationIndex.remove(data.location.toS2Point(), driverId)
                data.location = location
                locationIndex.add(location.toS2Point(), driverId)
            }
        }
    }

    @Synchronized
    fun deleteDriverData(driverId: String) {
        val data = driverData[driverId] ?: return
        locationIndex.remove(data.location.toS2Point(), driverId)
        locationIndex.iterator().init(locationIndex)
        driverData.remove(driverId)
        dataChangeListener.forEach {
            it.onDataDeleted()
        }
    }
}
