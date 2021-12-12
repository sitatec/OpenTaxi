import 'package:authentication/authentication.dart';
import 'package:data_access/data_access.dart';

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
    this.alternativePhoneNumber = "",
    this.priceByMinute = 0,
    this.priceByKm = 0,
    required this.account,
    DriverRepository? driverRepository,
  }) : repository = driverRepository ?? DriverRepository();

  Driver.fromJsonAndAccount(JsonObject jsonObject, Account account): this(
    account: account,
    idImageUrl: jsonObject["id_url"],
    driverLicenceUrl: jsonObject["driver_licence_url"],
    proofOfResidenceUrl: jsonObject["proof_of_residence_url"],
    bankAccountConfirmationUrl: jsonObject["bank_account_confirmation_url"],
    additionalCertificationUrls: jsonObject["additional_certification_urls"],
    otherPlatformsRatingUrl: jsonObject["other_platform_rating_url"],
    bio: jsonObject["bio"],
    priceByMinute: jsonObject["price_by_minute"],
    priceByKm: jsonObject["price_by_km"],
    isSouthAfricanCitizen: jsonObject["is_south_african_citizen"],
    homeAddress: jsonObject["address"],
    alternativePhoneNumber: jsonObject["alternative_phone_number"],
  );

  Driver.fromJson(JsonObject jsonObject): this(
    account: Account.fromJson(jsonObject["account"]),
    idImageUrl: jsonObject["driver"]["id_url"],
    driverLicenceUrl: jsonObject["driver"]["driver_licence_url"],
    proofOfResidenceUrl: jsonObject["driver"]["proof_of_residence_url"],
    bankAccountConfirmationUrl: jsonObject["driver"]["bank_account_confirmation_url"],
    additionalCertificationUrls: jsonObject["driver"]["additional_certification_urls"],
    otherPlatformsRatingUrl: jsonObject["driver"]["other_platform_rating_url"],
    bio: jsonObject["driver"]["bio"],
    priceByMinute: jsonObject["driver"]["price_by_minute"],
    priceByKm: jsonObject["driver"]["price_by_km"],
    isSouthAfricanCitizen: jsonObject["driver"]["is_south_african_citizen"],
    homeAddress: jsonObject["driver"]["address"],
    alternativePhoneNumber: jsonObject["driver"]["alternative_phone_number"],
  );

  JsonObject toJsonObject() => {
    "account": account.toJsonObject(),
    "driver": {
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
