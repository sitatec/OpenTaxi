package com.hamba.dispatcher

class DataChangeListener(val onDataAdded: ()->Unit, val onDataUpdated: ()->Unit,val onDataDeleted: ()->Unit)