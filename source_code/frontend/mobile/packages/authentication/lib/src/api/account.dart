import 'package:data_access/data_access.dart';
import 'package:shared/shared.dart';

class Account {
  String id;
  String firstName;
  String lastName;
  String displayName;
  String email;
  String phoneNumber;
  String notificationToken;
  final DateTime registeredAt;
  AccountRole role;
  AccountStatus status;
  String profilePicture;
  Gender genre;
  final AccountRepository repository;
  final AuthenticationProvider _authenticationProvider;

  Future<String>? get accessToken =>
      _authenticationProvider.getCurrentAccountToken;

  Account({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePicture,
    required this.phoneNumber,
    required this.registeredAt,
    required this.role,
    required this.status,
    required this.genre,
    this.displayName = "",
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
          lastName: jsonObject["surname"],
          email: jsonObject["email"],
          profilePicture: jsonObject["profile_picture_url"],
          phoneNumber: jsonObject["phone_number"],
          registeredAt: DateTime.parse(jsonObject["registered_at"]),
          role: stringToEnum(jsonObject["role"], AccountRole.values),
          status:
              stringToEnum(jsonObject["account_status"], AccountStatus.values),
          genre: stringToEnum(jsonObject["gender"], Gender.values),
          displayName: jsonObject["nickname"] ?? "",
          notificationToken: jsonObject["notification_token"] ?? "",
        );

  JsonObject toJsonObject() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone_number": phoneNumber,
        "registered_at": registeredAt.toIso8601String(),
        "role": enumToString(role),
        "account_status": enumToString(status),
        "gender": enumToString(genre),
        "diplay_name": displayName.isEmpty ? null : displayName,
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
