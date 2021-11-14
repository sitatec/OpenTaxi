part of 'api/phone_number_verifier.dart';

@internal
class FirebasePhoneVerifier extends PhoneNumberVerifier {
  final StreamController<PhoneNumberVerificationState>
      _verificationStateStream = StreamController();
  final FirebaseAuth _firebaseAuth;
  AuthenticationException? _exception;
  String _verificationId = "";

  FirebasePhoneVerifier(String phoneNumber, {FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(phoneNumber);

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
  Future<void> sendVerificationSMS() {
    return _firebaseAuth.verifyPhoneNumber(
      phoneNumber: _phoneNumber,
      verificationCompleted: _completeVerification,
      verificationFailed: _onVerificationFailed,
      codeSent: _onVerificationCodeSent,
      codeAutoRetrievalTimeout: _onAndroidAutoVerificationTimeout,
    );
  }

  void _completeVerification(PhoneAuthCredential phoneAuthCredential) {
    try {
      _firebaseAuth.currentUser?.linkWithCredential(phoneAuthCredential) ??
          (throw const AuthenticationException
              .verifyingPhoneNumberWhileUserSignedOut());
      _firebaseAuth.currentUser!.reload();
      _verificationStateStream.sink.add(PhoneNumberVerificationState.completed);
    } on FirebaseAuthException catch (e) {
      _onVerificationFailed(e);
    }
  }

  void _onVerificationFailed(FirebaseAuthException exception) {
    _exception = exception.toAuthenticationException();
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
