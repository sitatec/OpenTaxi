package com.hamba.dispatcher.utils

import java.util.*

fun <T> SortedSet<T>.closestOrExactIndexOf(value: T, startIndex: Int = 0, endIndex: Int = size, compare: (T,T) -> Int): Int {
    if (startIndex > endIndex) return startIndex
    val middleIndex = (endIndex + startIndex) / 2
    val middleElement = elementAt(middleIndex)
    return if (compare(middleElement,value) < 0) {
        closestOrExactIndexOf(value, middleIndex + 1, endIndex, compare)
    } else if (compare(middleElement, value) > 0) {
        closestOrExactIndexOf(value, startIndex, middleIndex - 1, compare)
    } else {
        middleIndex
    }
}

fun <T : Comparable<T>> SortedSet<T>.closestOrExactIndexOf(value: T, startIndex: Int = 0, endIndex: Int = size): Int {
    if (startIndex > endIndex) return startIndex
    val middleIndex = (endIndex + startIndex) / 2
    val middleElement = elementAt(middleIndex)
    return if (middleElement < value) {
        closestOrExactIndexOf(value, middleIndex + 1, endIndex)
    } else if (middleElement > value) {
        closestOrExactIndexOf(value, startIndex, middleIndex - 1)
    } else {
        middleIndex
    }
}
