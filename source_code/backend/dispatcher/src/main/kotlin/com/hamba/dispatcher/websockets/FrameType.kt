package com.hamba.dispatcher.websockets

enum class FrameType(private val code: Byte) {
    BOOKING_REQUEST(0),
    ADD_DRIVER_DATA(1),
    UPDATE_DRIVER_DATA(2),
    DELETE_DRIVER_DATA(3),
    ACCEPT_BOOKING(4),
    REFUSE_BOOKING(5),
    DISPATCH_REQUEST(6),
    CANCEL_BOOKING(7),
    INVALID_DISPATCH_ID(8),
    NO_MORE_DRIVER_AVAILABLE(9),
    PAIR_DISCONNECTED(10),
    BOOKING_REQUEST_TIMEOUT(11),
    BOOKING_SENT(12),
    TRIP_ROOM(13),
    BOOKING_ID(14),
    START_FUTURE_BOOKING_TRIP(15),
    ;

    override fun toString(): String {
        return code.toString()
    }

    companion object {
        fun fromRawFrame(rawFrameText: String): FrameType?{
            val code = rawFrameText.substringBefore(":")
            return values().firstOrNull { it.code == code.toByte() }
        }
    }
}