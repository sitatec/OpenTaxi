package com.hamba.dispatcher

import com.google.common.collect.SortedMultiset
import com.google.common.collect.TreeMultiset
import dilivia.s2.S2CellId
import dilivia.s2.S2Point
import dilivia.s2.index.point.PointData
import mu.KotlinLogging
import java.util.*

/**
 * A custom version of `S2PointIndex`
 */
class PointIndex<T : Comparable<T>>(val map: TreeMap<S2CellId, SortedMultiset<PointData<T>>>,val predicate: (T?)-> Boolean = {it != null}) {

    // Returns the number of points in the index.
    fun numPoints(): Int = map.map { entry -> entry.value.size }.sum()

    // Adds the given point to the index.  Invalidates all iterators.
    fun add(point: S2Point, data: T) = add(PointData(point, data))
    fun add(pointData: PointData<T>) {
        val id = S2CellId.fromPoint(pointData.point)
        map.getOrPut(id) { TreeMultiset.create() }.add(pointData)
    }

    // Removes the given point from the index.  Both the "point" and "data"
    // fields must match the point to be removed.  Returns false if the given
    // point was not present.  Invalidates all iterators.
    fun remove(point: S2Point, data: T): Boolean = remove(PointData(point, data))
    fun remove(pointData: PointData<T>): Boolean {
        val id = S2CellId.fromPoint(pointData.point)
        val dataSet = map[id] ?: return false
        val removed = dataSet.remove(pointData)
        if (removed && dataSet.isEmpty()) {
            map.remove(id)
        }
        return removed
    }

    // Resets the index to its original empty state.  Invalidates all iterators.
    fun clear(): Unit = map.clear()

    fun iterator(): Iterator<T> = Iterator(this)

    override fun toString(): String {
        return map.entries.joinToString("\n") { entry -> "- ${entry.key}: ${entry.value.joinToString(";")}" }
    }

    companion object {
        private val logger = KotlinLogging.logger(PointIndex::class.java.name)
    }


    class Iterator<T : Comparable<T>>(index: PointIndex<T>) {

        private lateinit var index: PointIndex<T>
        private var currentCellId: S2CellId = S2CellId.none
        private var currentPointData: PointData<T>? = null
        private var currentOccurence: Int = 0
        private val predicate = index.predicate

        init {
            init(index)
        }

        // Initializes an iterator for the given PointIndex.  If the index is
        // non-empty, the iterator is positioned at the first cell.
        //
        // This method may be called multiple times, e.g. to make an iterator
        // valid again after the index is modified.
        fun init(index: PointIndex<T>) {
            this.index = index
            begin()
        }

        // The S2CellId for the current index entry.
        // REQUIRES: !done()
        fun id(): S2CellId = currentCellId

        // The point associated with the current index entry.
        // REQUIRES: !done()
        fun point(): S2Point = currentPointData!!.point

        // The client-supplied data associated with the current index entry.
        // REQUIRES: !done()
        fun data(): T = currentPointData!!.data

        // The (S2Point, data) pair associated with the current index entry.
        fun pointData(): PointData<T> = currentPointData!!

        // Returns true if the iterator is positioned past the last index entry.
        fun done(): Boolean = currentPointData == null

        // Positions the iterator at the first index entry (if any).
        fun begin() {
            currentPointData = null
            currentCellId = if (index.map.isNotEmpty()) index.map.firstKey() else S2CellId.sentinel
            // TODO take into account filter(predicate)
            while (currentPointData == null && currentCellId != S2CellId.sentinel) {
                currentPointData = index.map[currentCellId]?.firstOrNull()
                if (currentPointData == null) {
                    currentCellId = index.map.higherKey(currentCellId) ?: S2CellId.sentinel
                }
            }
            if (currentPointData != null) currentOccurence = 1

            logger.trace { """
                |Iterator.begin()
                |--------------------------
                | Current cell id: $currentCellId
                | Current point data: $currentPointData
                | Current occurence: $currentOccurence
            """.trimMargin() }
        }

        // Positions the iterator so that done() is true.
        fun finish() {
            currentCellId = S2CellId.sentinel
            currentPointData = null
            currentOccurence = 0

            logger.trace { """
                |Iterator.finish()
                |--------------------------
                | Current cell id: $currentCellId
                | Current point data: $currentPointData
                | Current occurence: $currentOccurence
            """.trimMargin() }
        }

        // Advances the iterator to the next index entry.
        // REQUIRES: !done()
        fun next() {
            var nextPointData: PointData<T>? = null
            var cellId = currentCellId
            var nextOccurence = currentOccurence + 1
            while (nextPointData == null && cellId != S2CellId.sentinel) {
                val pointMultiset = index.map[cellId]
                if (pointMultiset != null) {
                    if (nextOccurence > pointMultiset.count(currentPointData)) {
                        nextPointData = pointMultiset.elementSet()?.higher(currentPointData)
                        nextOccurence = 1
                    } else {
                        nextPointData = currentPointData
                    }
                }
                if (nextPointData == null) {
                    cellId = index.map.higherKey(cellId) ?: S2CellId.sentinel
                    nextPointData = cellId.let { index.map[it]?.firstOrNull() }
                    nextOccurence = if (nextPointData == null) 0 else 1
                }
            }
            currentCellId = cellId
            currentPointData = nextPointData
            currentOccurence = nextOccurence

            if(!predicate(currentPointData?.data) && !done()) next()

            logger.trace { """
                |Iterator.next()
                |--------------------------
                | Current cell id: $currentCellId
                | Current point data: $currentPointData
                | Current occurence: $currentOccurence
            """.trimMargin() }

        }

        // If the iterator is already positioned at the beginning, returns false.
        // Otherwise positions the iterator at the previous entry and returns true.
        fun prev(): Boolean {
            var previousPointData: PointData<T>? = null
            var cellId = currentCellId
            var previousOccurence = currentOccurence - 1
            while (previousPointData == null && cellId != S2CellId.none) {
                var pointMultiset = index.map[cellId]
                if (pointMultiset != null) {
                    if (previousOccurence <= 0) {
                        previousPointData = index.map[cellId]?.elementSet()?.lower(currentPointData)
                        previousOccurence = pointMultiset.count(previousPointData)
                    } else {
                        previousPointData = currentPointData
                    }
                }
                if (previousPointData == null) {
                    cellId = index.map.lowerKey(cellId) ?: S2CellId.none
                    pointMultiset = cellId.let { index.map[it] }
                    previousPointData = pointMultiset?.lastOrNull()
                    previousOccurence = pointMultiset?.size ?: 0
                }
            }
            val result = if (previousPointData != null) {
                currentCellId = cellId
                currentPointData = previousPointData
                currentOccurence = previousOccurence
                if(predicate(currentPointData?.data)) true
                else prev()
            } else false

            logger.trace { """
                |Iterator.prev()
                |--------------------------
                | Current cell id: $currentCellId
                | Current point data: $currentPointData
                | Current occurence: $currentOccurence
                | Has moved: $result
            """.trimMargin() }

            return result
        }

        // Positions the iterator at the first entry with id() >= target, or at the
        // end of the index if no such entry exists.
        fun seek(target: S2CellId) {
            currentCellId = index.map.ceilingKey(target) ?: S2CellId.sentinel
            currentPointData = null
            currentOccurence = 0
            while (currentPointData == null && currentCellId != S2CellId.sentinel) {
                val pointList = index.map.getValue(currentCellId)
                if (pointList.isNotEmpty()) {
                    currentPointData = pointList.first()
                    currentOccurence = 1
                }
                else {
                    currentCellId = index.map.higherKey(currentCellId) ?: S2CellId.sentinel
                }
            }


            logger.trace { """
                |Iterator.seek($target)
                |--------------------------
                | Current cell id: $currentCellId
                | Current point data: $currentPointData
                | Current occurence: $currentOccurence
            """.trimMargin() }
        }

        companion object {
            private val logger = KotlinLogging.logger(Iterator::class.java.name)
        }

    }

}
