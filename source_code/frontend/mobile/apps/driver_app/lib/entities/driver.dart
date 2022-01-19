import 'package:shared/shared.dart';

class Driver {
  String bio;
  String homeAddressId;
  String alternativePhoneNumber;
  double priceByMinute;
  double priceByKm;
  bool hasAdditionalCertifications;
  final Account account;
  final DriverRepository repository;
  late final Future<Vehicle> car;

  Driver({
    this.bio = "",
    this.homeAddressId = "",
    this.alternativePhoneNumber = "0",
    this.priceByMinute = 0,
    this.priceByKm = 0,
    this.hasAdditionalCertifications = false,
    required this.account,
    DriverRepository? driverRepository,
    VehicleRepository? carReposioty,
  }) : repository = driverRepository ?? DriverRepository() {
    carReposioty ??= VehicleRepository();
    car = Future.value(Vehicle(
      make: "BMW",
      model: "n:a",
      registrationNumber: "GS454",
      color: "bleu",
      driverId: account.id,
      category: VehicleCategory.STANDARD,
      id: 1,
    ));
    // account.accessToken!.then((accessToken) async {
    //   final response =
    //       await carReposioty!.get({"driver_id": account.id}, accessToken);
    //   return Car.fromJson(response["data"]);
    // });
  }

  Driver.fromJsonAndAccount(JsonObject jsonObject, Account account)
      : this(
          account: account,
          bio: jsonObject["bio"],
          priceByMinute: double.parse(jsonObject["price_by_minute"]),
          priceByKm: double.parse(jsonObject["price_by_km"]),
          homeAddressId: jsonObject["address_id"],
          alternativePhoneNumber: jsonObject["alternative_phone_number"],
          hasAdditionalCertifications:
              jsonObject["has_additional_certifications"],
        );

  Driver.fromJson(JsonObject jsonObject)
      : this(
          account: Account.fromJson(jsonObject),
          bio: jsonObject["bio"],
          priceByMinute: double.parse(jsonObject["price_by_minute"]),
          priceByKm: double.parse(jsonObject["price_by_km"]),
          homeAddressId: jsonObject["address"],
          alternativePhoneNumber: jsonObject["alternative_phone_number"],
          hasAdditionalCertifications:
              jsonObject["has_additional_certifications"],
        );

  void updateWithJson(JsonObject jsonObject) {
    bio = jsonObject["bio"];
    priceByMinute = double.parse(jsonObject["price_by_minute"]);
    priceByKm = double.parse(jsonObject["price_by_km"]);
    homeAddressId = jsonObject["address"];
    alternativePhoneNumber = jsonObject["alternative_phone_number"] ?? "";
    hasAdditionalCertifications = jsonObject["has_additional_certifications"];
  }

  JsonObject toJsonObject() => {
        "account": account.toJsonObject(),
        "driver": {
          "account_id": account.id,
          "bio": bio,
          "price_by_minute": priceByMinute,
          "price_by_km": priceByKm,
          "address_id": homeAddressId,
          "alternative_phone_number": alternativePhoneNumber,
          "has_additional_certifications": hasAdditionalCertifications,
        }
      };
}
