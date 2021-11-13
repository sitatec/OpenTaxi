import 'package:meta/meta.dart';

@internal
class Account {
  final String id;
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

enum AccountRole { driver, rider, admin }

enum AccountStatus {
  live,
  waitingForApproval,
  unpaidSubscription,
  temporarilySuspended,
  definitivelyBanned
}
