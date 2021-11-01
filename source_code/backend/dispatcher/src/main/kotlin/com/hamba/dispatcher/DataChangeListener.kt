package com.hamba.dispatcher

class DataChangeListener(val onDataAdded: ()->Unit, val onDataUpdateNeeded: (()->Unit)->Unit, val onDataDeleted: ()->Unit)