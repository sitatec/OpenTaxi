package com.hamba.dispatcher

import com.hamba.dispatcher.model.RequestData
import com.hamba.dispatcher.model.Location
import dilivia.s2.index.point.PointData
import dilivia.s2.index.point.S2PointIndex

class DriverDataManager(private val dispatcher: Dispatcher, val locationIndex: S2PointIndex<String>) {

    private val driverData = mutableMapOf<String, RequestData>()
    private val dataChangeListener = mutableListOf<DataChangeListener>()

    fun addDataChangeListener(listener: DataChangeListener) = dataChangeListener.add(listener)

    @Synchronized
    fun addDriverData(data: RequestData) {
        val pointData = PointData(data.location.toS2Point(), data.id)
        driverData[data.id] = data
        locationIndex.add(pointData)
        dataChangeListener.forEach {
            it.onDataAdded()
        }
    }

    @Synchronized
    fun updateDriverData(driverId: String, location: Location) {
        val data = driverData[driverId]
        locationIndex.remove(data!!.location.toS2Point(), driverId)
        data.location = location
        locationIndex.add(location.toS2Point(), driverId)
        dataChangeListener.forEach {
            it.onDataDeleted()
        }
    }

    @Synchronized
    fun deleteDriverData(driverId: String) {
        val data = driverData[driverId]
        locationIndex.remove(data!!.location.toS2Point(), driverId)
        locationIndex.iterator().init(locationIndex)
        driverData.remove(driverId)
        dataChangeListener.forEach {
            it.onDataUpdated()
        }
    }
}
