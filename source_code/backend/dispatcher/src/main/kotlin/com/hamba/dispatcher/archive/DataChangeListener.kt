package com.hamba.dispatcher.archive

private class DataChangeListener(val onDataAdded: ()->Unit, val onDataUpdateNeeded: (()->Unit)->Unit, val onDataDeleted: ()->Unit)