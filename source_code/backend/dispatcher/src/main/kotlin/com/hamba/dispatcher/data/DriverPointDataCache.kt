package com.hamba.dispatcher.data

import com.google.common.collect.SortedMultiset
import com.google.common.collect.TreeMultiset
import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.utils.toCellId
import dilivia.s2.S2CellId
import dilivia.s2.index.point.PointData
import java.util.*


class DriverPointDataCache(
    val map: TreeMap<S2CellId, SortedMultiset<PointData<DriverData>>> = TreeMap<S2CellId, SortedMultiset<PointData<DriverData>>>()
) {
    private val onDataChangedListeners: MutableList<() -> Unit> = Collections.synchronizedList(mutableListOf())

    val size: Int
        get() = map.size

    fun addOnDataChangedListener(listener: () -> Unit) = onDataChangedListeners.add(listener)

    fun removeOnDataChangedListener(listener: () -> Unit) = onDataChangedListeners.remove(listener)

    @Synchronized
    fun add(driverData: DriverData) {
        val pointData = driverData.toPointData()
        val id = S2CellId.fromPoint(pointData.point)
        map.getOrPut(id) { TreeMultiset.create() }.add(pointData)
        onDataChangedListeners.forEach { it() }
    }

    @Synchronized
    fun remove(driverData: DriverData): Boolean {
        val pointData = driverData.toPointData()
        val key = S2CellId.fromPoint(pointData.point)
        val dataSet = map[key] ?: return false
        val removed = dataSet.remove(pointData)
        if (removed) {
            onDataChangedListeners.forEach { it() }
            if (dataSet.isEmpty()) {
                map.remove(key)
            }
        }
        return removed
    }

    @Synchronized
    fun update(driverData: DriverData) {
        // TODO optimize time complexity
        val pointData = driverData.toPointData()
        var key: S2CellId? = null
        for ((_, pointDataList) in map) {
            try {
                val previousPointData = pointDataList.first { it.data.driverId == pointData.data.driverId }
                pointDataList.remove(previousPointData)
                if(pointDataList.isEmpty()){
                    key = previousPointData.data.cellId.toCellId()
                }
                break
            } catch (e: NoSuchElementException) {
            }
        }
        key?.let { map.remove(key) }
    }

    fun contains(driverData: DriverData): Boolean {
        val key = driverData.cellId.toCellId()
        return map.contains(key)
    }

    fun isEmpty() = map.isEmpty()

    @Synchronized
    fun clear(): Unit = map.clear()
}