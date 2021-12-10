import 'package:meta/meta.dart';
import 'package:data_access/data_access.dart';

class Account {
  String id;
  String firstName;
  String surname;
  String nickname;
  String email;
  String phoneNumber;
  String notificationToken;
  final DateTime registeredAt;
  final AccountRole role;
  AccountStatus status;
  double balance;

  Account({
    required this.id,
    required this.firstName,
    required this.surname,
    required this.email,
    required this.phoneNumber,
    required this.registeredAt,
    required this.role,
    required this.status,
    required this.balance,
    this.nickname = "",
    this.notificationToken = "",
  });
}

enum AccountRole {
  driver,
  rider,
  admin,
  /// Account not registered yet
  undefined,
}

enum AccountStatus {
  live,
  waitingForApproval,
  unpaidSubscription,
  temporarilySuspended,
  definitivelyBanned,
  unverifiedPhoneNumber,
  unregistered,
}

extension AcountJsonParser on Account {
  @internal
  JsonObject toJsonObject() => {
        "id": id,
        "first_name": firstName,
        "surname": surname,
        "email": email,
        "phone_number": phoneNumber,
        "registered_at": registeredAt.toIso8601String(),
        "role": role.toString().toUpperCase(),
        "status": status.toString().toUpperCase(),
        "balance": balance,
        "nickname": nickname.isEmpty ? null : nickname,
        "notification_token":
            notificationToken.isEmpty ? null : notificationToken
      };

  @internal
  static Account fromJson(JsonObject jsonObject) => Account(
        id: jsonObject["id"],
        firstName: jsonObject["first_name"],
        surname: jsonObject["surname"],
        email: jsonObject["email"],
        phoneNumber: jsonObject["phone_number"],
        registeredAt: jsonObject["registered_at"],
        role: jsonObject["role"],
        status: jsonObject["status"],
        balance: jsonObject["balance"],
        nickname: jsonObject["nickname"] ?? "",
        notificationToken: jsonObject["notification_token"] ?? "",
      );
}
