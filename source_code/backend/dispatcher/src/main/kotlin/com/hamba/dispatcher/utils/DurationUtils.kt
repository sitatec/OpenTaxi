package com.hamba.dispatcher.utils

import java.time.Duration

fun Duration.formatDuration(): String{
    var formattedDuration = ""
    val days = toDays()
    val hours = toHours()
    val minutes = toMinutes()

    if(days >= 1L){
        formattedDuration += toDays().toString() + if(days > 1L) " days " else " day "
    }
    if(hours >= 1L){
        formattedDuration += toDays().toString() + if(hours > 1L) " hours " else " hour "
    }
    if(minutes >= 1L){
        formattedDuration += toDays().toString() + if(minutes > 1L) " mins " else " min "
    }
    if(formattedDuration.isBlank()) return "$seconds seconds"
    return formattedDuration
}