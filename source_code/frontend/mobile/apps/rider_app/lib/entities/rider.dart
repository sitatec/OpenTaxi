import 'package:shared/shared.dart';

class Rider {
  final Account account;
  Gender driverGenderPreference;
  final RiderRepository repository;
  String paymentToken;
  double balance;

  Rider({
    required this.account,
    this.driverGenderPreference = Gender.UNDEFINED,
    RiderRepository? riderRepository,
    this.paymentToken = "",
    this.balance = 0,
  }) : repository = riderRepository ?? RiderRepository();

  Rider.fromJsonAndAccount(JsonObject jsonObject, Account account)
      : this(
          account: account,
          balance: double.parse(jsonObject["balance"]),
          paymentToken: jsonObject["payment_token"],
          driverGenderPreference: stringToEnum(
            jsonObject["driver_gender_preference"],
            Gender.values,
          ),
        );

  Rider.fromJson(JsonObject jsonObject)
      : this(
          account: Account.fromJson(jsonObject),
          balance: double.parse(jsonObject["balance"]),
          paymentToken: jsonObject["payment_token"],
          driverGenderPreference: stringToEnum(
            jsonObject["driver_gender_preference"],
            Gender.values,
          ),
        );

  void updateWithJson(JsonObject jsonObject) {
    balance = double.parse(jsonObject["balance"]);
    paymentToken = jsonObject["payment_token"];
    driverGenderPreference = stringToEnum(
      jsonObject["driver_gender_preference"],
      Gender.values,
    );
  }

  JsonObject toJsonObject() => {
        "account": account.toJsonObject(),
        "driver": {
          "account_id": account.id,
          "balance": balance,
          "driver_gender_preference": enumToString(driverGenderPreference),
          "payment_token": paymentToken,
        }
      };
}
