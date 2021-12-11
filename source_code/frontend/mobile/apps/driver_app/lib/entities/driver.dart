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
  });
}
