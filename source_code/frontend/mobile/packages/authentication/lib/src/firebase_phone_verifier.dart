part of 'api/phone_number_verifier.dart';

@internal
class FirebasePhoneVerifier extends PhoneNumberVerifier {
  final StreamController<PhoneNumberVerificationState>
      _verificationStateStream = StreamController.broadcast();
  final FirebaseAuth _firebaseAuth;
  AuthenticationException? _exception;
  String _verificationId = "";
  static const _resendCodeDelay = 30;
  String _currentPhoneNumber = "";

  // Create a list of counters that match the numbers so even if the user change a number
  // and change back, the resent code counter will still working and the user won't be
  // able to resend the code before the end of the counter.
  final _counters = <String, CountDown>{};

  FirebasePhoneVerifier({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super._internal();

  @override
  Stream<PhoneNumberVerificationState> get verificationStateChanges =>
      _verificationStateStream.stream;

  @override
  AuthenticationException? get exception => _exception;

  @override
  CountDown? get resendCodeCounter => _counters[_currentPhoneNumber];

  @override
  String get currentPhoneNumber => _currentPhoneNumber;

  @override
  void verifyCode(String smsCode) {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: smsCode,
    );
    _completeVerification(credential);
  }

  @override
  Future<void> sendVerificationSMS(String phoneNumber) {
    if (_counters.containsKey(phoneNumber) &&
        _counters[phoneNumber]!.currentValue > 0) {
      // if the resent code counter is not done we don't resend the code.
      _onVerificationCodeSent(_verificationId, phoneNumber);
    }
    return _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: _completeVerification,
      verificationFailed: _onVerificationFailed,
      codeSent: (verificationId, _) =>
          _onVerificationCodeSent(verificationId, phoneNumber),
      codeAutoRetrievalTimeout: _onAndroidAutoVerificationTimeout,
    );
  }

  void _completeVerification(PhoneAuthCredential phoneAuthCredential) {
    try {
      _firebaseAuth.signInWithCredential(phoneAuthCredential);
      _verificationStateStream.sink.add(PhoneNumberVerificationState.completed);
      _counters.clear();
    } on FirebaseAuthException catch (e) {
      _onVerificationFailed(e);
    }
  }

  void _onVerificationFailed(FirebaseAuthException exception) {
    _exception = exception.toAuthenticationException();
    _verificationStateStream.add(PhoneNumberVerificationState.failed);
  }

  void _onVerificationCodeSent(String verificationId, String phoneNumber) {
    _verificationId = verificationId;
    _currentPhoneNumber = phoneNumber;
    _counters[_currentPhoneNumber] = CountDown(_resendCodeDelay);
    _verificationStateStream.sink.add(PhoneNumberVerificationState.codeSent);
  }

  void _onAndroidAutoVerificationTimeout(String verificationId) {
    // _verificationStateStream.sink
    //     .add(PhoneNumberVerificationState.androidAutoVerificationTimeout);
  }
}
