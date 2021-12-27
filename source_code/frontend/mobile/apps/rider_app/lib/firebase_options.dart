// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAbLts73IVYsQCHv7fxJtlmUvlXbuy9FO8',
    appId: '1:211386480430:android:9c728999b9c719d0ccacbf',
    messagingSenderId: '211386480430',
    projectId: 'hamba-project',
    databaseURL: 'https://hamba-project-default-rtdb.firebaseio.com',
    storageBucket: 'hamba-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYBLWjXtOuXxJxczqGqg10jSpJfGTMu30',
    appId: '1:211386480430:ios:b666345b4aabe5c4ccacbf',
    messagingSenderId: '211386480430',
    projectId: 'hamba-project',
    databaseURL: 'https://hamba-project-default-rtdb.firebaseio.com',
    storageBucket: 'hamba-project.appspot.com',
    androidClientId: '211386480430-6jn5pt4ia96f83u68mddemjd92l977df.apps.googleusercontent.com',
    iosClientId: '211386480430-umf6c0mtevicftl1op8iac5gvtepr2sh.apps.googleusercontent.com',
    iosBundleId: 'com.hamba.rider',
  );
}
