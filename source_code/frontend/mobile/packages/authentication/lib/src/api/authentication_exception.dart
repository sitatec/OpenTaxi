class AuthenticationException implements Exception {
  final AuthenticationExceptionType exceptionType;
  final String message;

  const AuthenticationException(
      {required this.exceptionType, required this.message});

  const AuthenticationException.unknown()
      : this(
          exceptionType: AuthenticationExceptionType.unknown,
          message:
              "A critical error occurred during authentication, please try again, if the error persists please restart the app.",
        );

  const AuthenticationException.invalidVerificationCode()
      : this(
          exceptionType: AuthenticationExceptionType.invalidVerificationCode,
          message: 'The code you entered does not match the one we sent you.',
        );

  const AuthenticationException.emailAlreadyUsed()
      : this(
          exceptionType: AuthenticationExceptionType.emailAlreadyUsed,
          message: "The email address you entered is already used.",
        );

  const AuthenticationException.weakPassword()
      : this(
          exceptionType: AuthenticationExceptionType.weakPassword,
          message: 'The password you entered is too weak.',
        );

  const AuthenticationException.invalidEmail()
      : this(
          exceptionType: AuthenticationExceptionType.invalidEmail,
          message: 'Invalid email address.',
        );

  const AuthenticationException.userDisabled()
      : this(
          exceptionType: AuthenticationExceptionType.userDisabled,
          message:
              'Your account has been temporarily deactivated, if you do not know the reasons why your account has been deactivated please contact us.',
        );

  const AuthenticationException.userNotFound()
      : this(
          exceptionType: AuthenticationExceptionType.userNotFound,
          message:
              "The email address you entered does not match any existing account. Please enter the correct email address or create a new account if you are not already registered.",
        );

  const AuthenticationException.wrongPassword()
      : this(
          exceptionType: AuthenticationExceptionType.wrongPassword,
          message: 'Incorrect password.',
        );

  const AuthenticationException.invalidCredential()
      : this(
          exceptionType: AuthenticationExceptionType.invalidCredential,
          message:
              "We were unable to obtain permission to log in using your facebook account. Please make sure that you have not disabled Taluxi permission on your facebook account settings.",
        );

  const AuthenticationException.accountExistsWithDifferentCredential()
      : this(
          exceptionType:
              AuthenticationExceptionType.accountExistsWithDifferentCredential,
          message:
              "An identifier conflict occurred. This type of error can happen if you have created a Taluxi account with an email address and then try to connect with a facebook account which is linked to this email address, in this case you must connect by entering your email and password instead of trying to log in with your facebook account.",
        );

  const AuthenticationException.facebookLoginFailed()
      : this(
          exceptionType: AuthenticationExceptionType.facebookLoginFailed,
          message:
              "Login using your facebook account failed, please try again. If you are shown a facebook login page, log in the same way you usually do to log into your facebook account.",
        );

  const AuthenticationException.tooManyRequests()
      : this(
          exceptionType: AuthenticationExceptionType.tooManyRequests,
          message: 'Too many attempts, please try again later.',
        );

  const AuthenticationException.verifyingPhoneNumberWhileUserSignedOut()
      : this(
          exceptionType: AuthenticationExceptionType
              .verifyingPhoneNumberWhileUserSignedOut,
          message:
              'The user must be signed in before verifying his phone number.',
        );
}

enum AuthenticationExceptionType {
  unknown,
  invalidVerificationCode,
  emailAlreadyUsed,
  weakPassword,
  invalidEmail,
  userDisabled,
  userNotFound,
  wrongPassword,
  invalidCredential,
  accountExistsWithDifferentCredential,
  facebookLoginFailed,
  tooManyRequests,
  verifyingPhoneNumberWhileUserSignedOut,
}
