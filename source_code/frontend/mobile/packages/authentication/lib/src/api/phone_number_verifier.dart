import 'dart:async';
import 'package:authentication/src/api/authentication_exception.dart';
import 'package:authentication/src/count_down.dart';
import 'package:meta/meta.dart';
import '../firebase_auth_adapter.dart';

import 'package:firebase_auth/firebase_auth.dart';

part '../firebase_phone_verifier.dart';

abstract class PhoneNumberVerifier {
  Stream<PhoneNumberVerificationState> get verificationStateChanges;
  AuthenticationException? get exception;
  CountDown? get resendCodeCounter;
  String get currentPhoneNumber;
  // TODO create a timer for resend code
  PhoneNumberVerifier._internal();

  factory PhoneNumberVerifier() => FirebasePhoneVerifier();

  void verifyCode(String smsCode);

  Future<void> sendVerificationSMS(String phoneNumber);

}

enum PhoneNumberVerificationState {
  codeSent,
  completed,
  failed,
  // androidAutoVerificationTimeout,
}
