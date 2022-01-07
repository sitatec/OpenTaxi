import 'package:data_access/data_access.dart';
import 'package:shared/shared.dart';

class Account {
  String id;
  String firstName;
  String surname;
  String nickname;
  String email;
  String phoneNumber;
  String notificationToken;
  final DateTime registeredAt;
  AccountRole role;
  AccountStatus status;
  String profilePicture;
  double balance;
  Gender genre;
  final AccountRepository repository;
  final AuthenticationProvider _authenticationProvider;

  Future<String>? get accessToken =>
      _authenticationProvider.getCurrentAccountToken;

  Account({
    required this.id,
    required this.firstName,
    required this.surname,
    required this.email,
    required this.profilePicture,
    required this.phoneNumber,
    required this.registeredAt,
    required this.role,
    required this.status,
    required this.balance,
    required this.genre,
    this.nickname = "",
    this.notificationToken = "",
    AuthenticationProvider? authenticationProvider,
    AccountRepository? accountRepository,
  })  : _authenticationProvider =
            authenticationProvider ?? AuthenticationProvider.instance,
        repository = accountRepository ?? AccountRepository();

  Account.fromJson(JsonObject jsonObject)
      : this(
          id: jsonObject["id"],
          firstName: jsonObject["first_name"],
          surname: jsonObject["surname"],
          email: jsonObject["email"],
          profilePicture: jsonObject["profile_picture_url"],
          phoneNumber: jsonObject["phone_number"],
          registeredAt: DateTime.parse(jsonObject["registered_at"]),
          role: stringToEnum(jsonObject["role"], AccountRole.values),
          status:
              stringToEnum(jsonObject["account_status"], AccountStatus.values),
          genre: stringToEnum(jsonObject["gender"], Gender.values),
          balance: double.parse(jsonObject["balance"]),
          nickname: jsonObject["nickname"] ?? "",
          notificationToken: jsonObject["notification_token"] ?? "",
        );

  JsonObject toJsonObject() => {
        "id": id,
        "first_name": firstName,
        "surname": surname,
        "email": email,
        "phone_number": phoneNumber,
        "registered_at": registeredAt.toIso8601String(),
        "role": enumToString(role),
        "account_status": enumToString(status),
        "gender": enumToString(genre),
        "balance": balance,
        "nickname": nickname.isEmpty ? null : nickname,
        "profile_picture_url": profilePicture,
        "notification_token":
            notificationToken.isEmpty ? null : notificationToken
      };
}

enum AccountRole {
  DRIVER,
  RIDER,
  ADMIN,

  /// Account registration not finalize yet
  UNDEFINED,
}

enum AccountStatus {
  LIVE,
  WAITING_FOR_APPROVAL,
  SUSPENDED_FOR_UNPAID,
  TEMPORARILY_SUSPENDED,
  DEFINITIVELY_BANNED,
  REGISTRATION_IN_PROGRESS,
}

enum Gender {
  MALE,
  FEMALE,

  /// Account registration not finalize yet
  UNDEFINED,
}
