import 'package:authentication/authentication.dart';
import 'package:data_access/data_access.dart';
import 'package:shared/shared.dart';

class Driver {
  String idImageUrl;
  String driverLicenceUrl;
  String proofOfResidenceUrl;
  String bankAccountConfirmationUrl;
  List<String> additionalCertificationUrls;
  String otherPlatformsRatingUrl;
  String bio;
  bool isSouthAfricanCitizen;
  String homeAddress;
  String alternativePhoneNumber;
  double priceByMinute;
  double priceByKm;
  final Account account;
  final DriverRepository repository;
  late final Future<Car> car;

  Driver({
    this.idImageUrl = "",
    this.driverLicenceUrl = "",
    this.proofOfResidenceUrl = "",
    this.bankAccountConfirmationUrl = "",
    this.additionalCertificationUrls = const [],
    this.otherPlatformsRatingUrl = "",
    this.bio = "",
    this.isSouthAfricanCitizen = false,
    this.homeAddress = "",
    this.alternativePhoneNumber = "0",
    this.priceByMinute = 0,
    this.priceByKm = 0,
    required this.account,
    DriverRepository? driverRepository,
    CarRepository? carReposioty,
  }) : repository = driverRepository ?? DriverRepository() {
    carReposioty ??= CarRepository();
    car = account.accessToken!.then((accessToken) async {
      final response =
          await carReposioty!.get({"driver_id": account.id}, accessToken);
      return Car.fromJson(response["data"]);
    });
  }

  Driver.fromJsonAndAccount(JsonObject jsonObject, Account account)
      : this(
          account: account,
          idImageUrl: jsonObject["id_url"],
          driverLicenceUrl: jsonObject["driver_licence_url"],
          proofOfResidenceUrl: jsonObject["proof_of_residence_url"],
          bankAccountConfirmationUrl:
              jsonObject["bank_account_confirmation_url"],
          additionalCertificationUrls:
              List.from(jsonObject["additional_certification_urls"]),
          otherPlatformsRatingUrl: jsonObject["other_platform_rating_url"],
          bio: jsonObject["bio"],
          priceByMinute: double.parse(jsonObject["price_by_minute"]),
          priceByKm: double.parse(jsonObject["price_by_km"]),
          isSouthAfricanCitizen: jsonObject["is_south_african_citizen"],
          homeAddress: jsonObject["address"],
          alternativePhoneNumber: jsonObject["alternative_phone_number"],
        );

  Driver.fromJson(JsonObject jsonObject)
      : this(
          account: Account.fromJson(jsonObject),
          idImageUrl: jsonObject["id_url"],
          driverLicenceUrl: jsonObject["driver_licence_url"],
          proofOfResidenceUrl: jsonObject["proof_of_residence_url"],
          bankAccountConfirmationUrl:
              jsonObject["bank_account_confirmation_url"],
          additionalCertificationUrls:
              List.from(jsonObject["additional_certification_urls"]),
          otherPlatformsRatingUrl: jsonObject["other_platform_rating_url"],
          bio: jsonObject["bio"],
          priceByMinute: double.parse(jsonObject["price_by_minute"]),
          priceByKm: double.parse(jsonObject["price_by_km"]),
          isSouthAfricanCitizen: jsonObject["is_south_african_citizen"],
          homeAddress: jsonObject["address"],
          alternativePhoneNumber: jsonObject["alternative_phone_number"],
        );

  void updateWithJson(JsonObject jsonObject) {
    idImageUrl = jsonObject["id_url"];
    driverLicenceUrl = jsonObject["driver_licence_url"];
    proofOfResidenceUrl = jsonObject["proof_of_residence_url"];
    bankAccountConfirmationUrl = jsonObject["bank_account_confirmation_url"];
    additionalCertificationUrls =
        List.from(jsonObject["additional_certification_urls"]);
    otherPlatformsRatingUrl = jsonObject["other_platform_rating_url"] ?? "";
    bio = jsonObject["bio"];
    priceByMinute = double.parse(jsonObject["price_by_minute"]);
    priceByKm = double.parse(jsonObject["price_by_km"]);
    isSouthAfricanCitizen = jsonObject["is_south_african_citizen"];
    homeAddress = jsonObject["address"];
    alternativePhoneNumber = jsonObject["alternative_phone_number"] ?? "";
  }

  JsonObject toJsonObject() => {
        "account": account.toJsonObject(),
        "driver": {
          "account_id": account.id,
          "id_url": idImageUrl,
          "driver_licence_url": driverLicenceUrl,
          "proof_of_residence_url": proofOfResidenceUrl,
          "bank_account_confirmation_url": bankAccountConfirmationUrl,
          "additional_certification_urls": additionalCertificationUrls,
          "other_platform_rating_url": otherPlatformsRatingUrl,
          "bio": bio,
          "price_by_minute": priceByMinute,
          "price_by_km": priceByKm,
          "is_south_african_citizen": isSouthAfricanCitizen,
          "address": homeAddress,
          "alternative_phone_number": alternativePhoneNumber,
        }
      };
}
