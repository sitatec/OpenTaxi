package com.hamba.dispatcher

import com.hamba.dispatcher.data.model.DispatchRequestData
import com.hamba.dispatcher.data.model.DriverData
import com.hamba.dispatcher.data.model.Location

val fakeDriverData = DriverData(Location(11.310777, -12.312727)/*Near SALA*/, "MALE", "STANDARD", "nearSala")

// TODO replace places names by distances for collaboration.
val fakeDriverDataList = mutableListOf<DriverData>().apply {
    add(DriverData(Location(11.307769, -12.315753) /*NEAR HOME*/, "FEMALE", "STANDARD", "nearHome"))
    add(DriverData(Location(11.312763, -12.320231) /*GARAGE MALAL*/, "MALE", "VAN", "garageMalal"))
    add(
        DriverData(
            Location(11.312739, -12.313941)  /*PHARMACIE N'DIOLOU (FACE PERGOLA)*/,
            "MALE",
            "PREMIUM",
            "pharmacieNdiolou"
        )
    )
    add(DriverData(Location(11.259205, -12.367215) /*GARAMDBE*/, "MALE", "VAN", "garambe"))
    add(DriverData(Location(11.224548, -12.353052) /*TIMBO*/, "FEMALE", "LITE", "timbo"))
    add(DriverData(Location(11.330455, -12.295603) /*LABE AIRPORT*/, "FEMALE", "STANDARD", "labeAirport"))
    add(fakeDriverData)
}

val fakeDispatchRequestData = DispatchRequestData(
    riderId = "riderId",
    pickUpLocation = Location(11.309098, -12.318813),/*HOME*/
    dropOffLocation = Location(11.309098, -12.318813),/*HOME*/
    paymentMethod = "cash",
)

val fakeDispatchRequestDataWithGenderFilter = DispatchRequestData(
    riderId = "riderId1",
    pickUpLocation = Location(11.309098, -12.318813)/*HOME*/,
    dropOffLocation = Location(11.309098, -12.318813)/*HOME*/,
    paymentMethod = "cash",
    gender = "MALE"
)

val fakeDispatchRequestDataWithCarFilter = DispatchRequestData(
    riderId = "riderId2",
    pickUpLocation = Location(11.309098, -12.318813)/*HOME*/,
    dropOffLocation = Location(11.309098, -12.318813)/*HOME*/,
    paymentMethod = "cash",
    gender = null,
    carType = "PREMIUM"
)