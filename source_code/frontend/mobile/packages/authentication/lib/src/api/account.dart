import 'package:meta/meta.dart';
import 'package:data_access/data_access.dart';

class Account {
  String id;
  String firstName;
  String lastName;
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
    required this.lastName,
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

  /// Account not registered yet
  undefined,
}

extension AcountJsonParser on Account {
  @internal
  JsonObject toJsonObject() => {
        "id": id,
        "first_name": firstName,
        "last_name": lastName,
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
        lastName: jsonObject["last_name"],
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
