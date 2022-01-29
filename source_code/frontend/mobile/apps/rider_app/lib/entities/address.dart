import 'package:google_maps_webservice/geocoding.dart';
import 'package:rider_app/configs/secrets.dart';
import 'package:shared/shared.dart';

class Address {
  /// Google place id.
  String placeId;
  String streetAddress;
  String postalCode;
  String city;
  String province;
  Coordinates? coordinates;

  Address({
    required this.streetAddress,
    this.postalCode = "",
    this.city = "",
    this.province = "",
    this.placeId = "",
    this.coordinates,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{"adr": streetAddress};
    if (placeId.isNotEmpty) {
      map["pId"] = placeId;
    }
    if (coordinates != null) {
      map["lat"] = coordinates!.latitude;
      map["lng"] = coordinates!.longitude;
    }
    if (city.isNotEmpty && province.isNotEmpty && postalCode.isNotEmpty) {
      map["cod"] = postalCode;
      map["pro"] = province;
      map["cit"] = city;
    }
    return map;
  }

  Future<void> completeAddress() async {
    if (coordinates == null) {
      final geocoder = GoogleMapsGeocoding(apiKey: googlePlacesAPIKey);
      final result = await geocoder.searchByAddress(
        streetAddress,
        language: "en",
      );

      placeId = result.results.first.placeId;
      final location = result.results.first.geometry.location;
      coordinates = Coordinates(
        latitude: location.lat,
        longitude: location.lng,
      );

      for (var addressComponent in result.results.first.addressComponents) {
        if (addressComponent.types.contains("postal_code")) {
          postalCode = addressComponent.longName;
        } else if (addressComponent.types.contains("locality")) {
          city = addressComponent.longName;
        } else if (addressComponent.types
            .contains("administrative_area_level_2")) {
          // TODO check if the "administrative_area_level_2" match South African provinces.
          province = addressComponent.longName;
        }
      }
    }
  }
}
