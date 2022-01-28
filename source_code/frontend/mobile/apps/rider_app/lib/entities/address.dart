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
}
