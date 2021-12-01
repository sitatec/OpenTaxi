part of 'api/phone_number_verifier.dart';

@internal
class FirebasePhoneVerifier extends PhoneNumberVerifier {
  final StreamController<PhoneNumberVerificationState>
      _verificationStateStream = StreamController();
  final FirebaseAuth _firebaseAuth;
  AuthenticationException? _exception;
  String _verificationId = "";

  FirebasePhoneVerifier({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super._internal();

  @override
  Stream<PhoneNumberVerificationState> get verificationStateChanges =>
      _verificationStateStream.stream;

  @override
  AuthenticationException? get exception => _exception;

  @override
  void verifyCode(String smsCode) {
    final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: smsCode);
    _completeVerification(credential);
  }

  @override
  Future<void> sendVerificationSMS(String phoneNumber) {
    return _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: _completeVerification,
      verificationFailed: _onVerificationFailed,
      codeSent: _onVerificationCodeSent,
      codeAutoRetrievalTimeout: _onAndroidAutoVerificationTimeout,
    );
  }

  void _completeVerification(PhoneAuthCredential phoneAuthCredential) {
    try {
      _firebaseAuth.signInWithCredential(phoneAuthCredential);
      _firebaseAuth.currentUser!.reload();
      _verificationStateStream.sink.add(PhoneNumberVerificationState.completed);
    } on FirebaseAuthException catch (e) {
      _onVerificationFailed(e);
    }
  }

  void _onVerificationFailed(FirebaseAuthException exception) {
    _exception = exception.toAuthenticationException();
    _verificationStateStream.add(PhoneNumberVerificationState.failed);
  }

  void _onVerificationCodeSent(String verificationId, int? resendToken) {
    _verificationStateStream.sink.add(PhoneNumberVerificationState.codeSent);
    _verificationId = verificationId;
  }

  void _onAndroidAutoVerificationTimeout(String verificationId) {
    // _verificationStateStream.sink
    //     .add(PhoneNumberVerificationState.androidAutoVerificationTimeout);
  }
}
