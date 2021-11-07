package com.hamba.dispatcher

import com.hamba.dispatcher.data.model.DispatchRequestData
import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.data.model.Location

val fakeDriverData = DriverData(Location(11.310777, -12.312727)/*Near SALA*/, "MALE", "STANDARD", "nearSala")

val fakeDriverDataList = mutableListOf<DriverData>().apply {
    add(fakeDriverData)
    add(DriverData( Location(11.307769, -12.315753) /*NEAR HOME*/, "FEMALE", "STANDARD", "nearHome"))
    add(DriverData(Location(11.312763, -12.320231) /*GARAGE MALAL*/, "MALE", "PREMIUM", "garageMalal"))
    add(DriverData(Location(14.345643, -11.463644)  /*PHARMACIE N'DIOLOU (FACE PERGOLA)*/, "MALE", "STANDARD", "pharmacieNdiolou"))
    add(DriverData(Location(11.259205, -12.367215) /*GARAMDBE*/  , "MALE", "VAN", "garambe"))
    add(DriverData(Location(11.224548, -12.353052) /*TIMBO*/  , "FEMALE", "LITE", "timbo"))
    add(DriverData(Location(11.330455, -12.295603) /*LABE AIRPORT*/  , "FEMALE", "STANDARD", "labeAirport"))
}

val fakeDispatchRequestData = DispatchRequestData(
    "riderId",
    Location(11.309098, -12.318813)/*HOME*/,
    listOf("11.313145, -12.315527"/*BASEL*/),
    "11.314165, -12.300839"/*YALI*/
)