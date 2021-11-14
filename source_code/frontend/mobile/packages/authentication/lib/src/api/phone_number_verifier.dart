import 'dart:async';
import 'package:authentication/src/api/authentication_exception.dart';
import 'package:meta/meta.dart';
import '../firebase_auth_adapter.dart';

import 'package:firebase_auth/firebase_auth.dart';

part '../firebase_phone_verifier.dart';

abstract class PhoneNumberVerifier {
  Stream<PhoneNumberVerificationState> get verificationStateChanges;
  final String _phoneNumber;
  AuthenticationException? get exception;

  PhoneNumberVerifier(this._phoneNumber);

  void verifyCode(String smsCode);

  Future<void> sendVerificationSMS();

}

enum PhoneNumberVerificationState {
  codeSent,
  completed,
  failed,
  // androidAutoVerificationTimeout,
}
