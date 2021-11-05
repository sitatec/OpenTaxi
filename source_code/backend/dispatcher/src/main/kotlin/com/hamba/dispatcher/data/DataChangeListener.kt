package com.hamba.dispatcher.data

class DataChangeListener(val onDataAdded: ()->Unit, val onDataUpdateNeeded: (()->Unit)->Unit, val onDataDeleted: ()->Unit)