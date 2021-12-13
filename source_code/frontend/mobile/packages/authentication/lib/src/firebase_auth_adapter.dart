import 'dart:async';
import 'package:data_access/data_access.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'api/account.dart';
import 'api/authentication_exception.dart';
import 'api/authentication_provider.dart';

class FirebaseAuthProvider
    with ChangeNotifier
    implements AuthenticationProvider {
  final FirebaseAuth _firebaseAuth;
  AuthState _currentAuthState = AuthState.uninitialized;
  final _authStateStreamController = StreamController<AuthState>.broadcast();
  final AccountRepository _accountRepository;
  Account? _account;

  static final _singleton = FirebaseAuthProvider._internal();

  factory FirebaseAuthProvider() => _singleton;

  FirebaseAuthProvider._internal()
      : _accountRepository = AccountRepository(),
        _firebaseAuth = FirebaseAuth.instance {
    _initialize();
  }

  @visibleForTesting
  FirebaseAuthProvider.forTest(this._accountRepository, this._firebaseAuth) {
    _initialize();
  }

  void _initialize() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    _authStateStreamController.onListen =
        () => _authStateStreamController.sink.add(_currentAuthState);
  }

  @override
  AuthState get authState => _currentAuthState;

  @override
  Account? get account => _account;

  @override
  Stream<AuthState> get authBinaryState => _authStateStreamController.stream;

  @override
  Future<String>? get getCurrentAccountToken => _firebaseAuth.currentUser?.getIdToken();

  @override
  void dispose() {
    _authStateStreamController.close();
    super.dispose();
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    // TODO: refactoring
    try {
      if (firebaseUser == null) {
        _account = null;
        _switchState(AuthState.unauthenticated);
      } else {
        // `_account` may have been initialized in the `registerAccount(...)` methods to avoid sending data and fetching it again.
        _account ??= await firebaseUser.toAccount(_accountRepository);
        _switchState(AuthState.authenticated);
      }
    } catch (e) {
      //TODO: rapport error.
      signOut();
    }
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _switchState(AuthState.authenticating);
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw await _handleException(FirebaseAuthException(
        email: email, // The email is missing by default.
        message: e.message,
        code: e.code,
      ));
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<void> registerAccount(Account account, String password) async {
    try {
      _switchState(AuthState.registering);
      final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
        email: account.email,
        password: password,
      );
      // initialize _account to avoid fetching the same data in `_onAuthStateChanged(...)`.
      _account = account..id = credentials.user!.uid;
      final userIdToken = await credentials.user!.getIdToken();
      await _accountRepository
          .create(account.toJsonObject(), userIdToken) // Retry on fail.
          .catchError((e) => _accountRepository.create(account.toJsonObject(), userIdToken));
      // TODO handle the case when the user is registered with firebase but the account creation on our db fails.
    } catch (e) {
      _account = null;
      throw _handleException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      //TODO: tests sendPasswordResetEmail.
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw _handleException(e);
    }
  }

  void _switchState(AuthState targetState) {
    if (_currentAuthState == targetState) return;
    _currentAuthState = targetState;
    if (targetState == AuthState.authenticated ||
        targetState == AuthState.unauthenticated) {
      _authStateStreamController.sink.add(targetState);
    }
    notifyListeners();
  }

  _handleException(dynamic exception) {
    if (_firebaseAuth.currentUser == null) {
      _switchState(AuthState.unauthenticated);
    }
    if (exception is FirebaseAuthException) {
      return exception.toAuthenticationException();
    }
    // TODO: implement error reporting.
    return exception;
  }
}

extension Converter on FirebaseAuthException {
  AuthenticationException toAuthenticationException() {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const AuthenticationException
            .accountExistsWithDifferentCredential();
      case 'invalid-credential':
        return const AuthenticationException.invalidCredential();
      case 'invalid-verification-code':
        return const AuthenticationException.invalidVerificationCode();
      case 'email-already-in-use':
        return const AuthenticationException.emailAlreadyUsed();
      case 'weak-password':
        return const AuthenticationException.weakPassword();
      case 'invalid-email':
        return const AuthenticationException.invalidEmail();
      case 'user-disabled':
        return const AuthenticationException.userDisabled();
      case 'user-not-found':
        return const AuthenticationException.userNotFound();
      case 'wrong-password':
        return const AuthenticationException.wrongPassword();
      case 'too-many-requests':
        return const AuthenticationException.tooManyRequests();
      case 'invalid-phone-number':
        return const AuthenticationException.invalidPhoneNumber();
      default:
        return const AuthenticationException.unknown();
    }
  }
}

extension on User {
  Future<Account> toAccount(AccountRepository accountRepository) async {
    final idToken = await getIdToken();
    try {
      final response = await accountRepository.get({"id": uid}, idToken);
      return Account.fromJson(response.data);
    } on HttpException catch (e) {
      if (e.response!.statusCode == 404) {
        // 404 => user not created yet | return temporary account
        return Account(
          id: uid,
          firstName: "",
          surname: "",
          profilePicture: "",
          email: "",
          genre: Gender.UNDEFINED,
          phoneNumber: phoneNumber!.replaceFirst("+27", ""),
          registeredAt: metadata.creationTime ?? DateTime.now(),
          role: AccountRole.UNDEFINED,
          status: AccountStatus.REGISTRATION_IN_PROGRESS,
          balance: 0,
          accountRepository: accountRepository,
        );
      }else {
        rethrow;
      }
    }
  }
}
