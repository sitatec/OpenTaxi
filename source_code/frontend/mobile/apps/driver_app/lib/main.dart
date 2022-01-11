import 'package:driver_app/authentication/ui/user_account_status.dart';
import 'package:driver_app/home_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared/shared.dart';

import 'entities/driver.dart';
import 'main_screen.dart';

void main() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  runApp(App());
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: theme.scaffoldBackgroundColor,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hamba Driver',
      theme: ThemeData(
        primaryColor: const Color(0xFF054BAC),
        errorColor: const Color(0xFFFE1917),
        disabledColor: const Color(0xFFB7B7B7),
        accentColor: const Color(0xFF2BC25F),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: SafeArea(
        child: true
            ? ChatScreen()
            : Scaffold(
                body: FutureBuilder<FirebaseApp>(
                    future: Firebase.initializeApp(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        // TODO check if internet connection is available, if not show appropriate screen
                        // TODO show "something went wrong" screen when internet connection is available.
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        final authenticationProvider =
                            AuthenticationProvider.instance;
                        return StreamBuilder<AuthState>(
                            stream: authenticationProvider.authBinaryState,
                            initialData: AuthState.uninitialized,
                            builder: (context, authSnapshot) {
                              if (authSnapshot.data ==
                                  AuthState.uninitialized) {
                                return const Center(
                                    child: Text("Authenticating..."));
                              }
                              if (authSnapshot.data ==
                                  AuthState.authenticated) {
                                final driverAccount =
                                    authenticationProvider.account!;
                                if (driverAccount.role !=
                                        AccountRole.UNDEFINED &&
                                    driverAccount.role != AccountRole.DRIVER) {
                                  return const Center(
                                    child: Text(
                                      "This account is not a driver account!",
                                    ),
                                  );
                                } else {
                                  final driver = Driver(account: driverAccount);
                                  if (driverAccount.status ==
                                      AccountStatus.LIVE) {
                                    return HomePage(
                                      driver,
                                      Dispatcher(),
                                      LocationManager(),
                                    );
                                  } else if (driverAccount.status ==
                                      AccountStatus.WAITING_FOR_APPROVAL) {
                                    return const UserAccountStatusPage(
                                      UserAccountStatus.accountUnderReview,
                                    );
                                  } else {
                                    return const UserAccountStatusPage(
                                      UserAccountStatus.accountSuspended,
                                    );
                                  }
                                }
                              } else {
                                return const PhoneAuthScreen();
                              }
                            });
                      }
                      return const Center(child: Text("Loading..."));
                    }),
              ),
      ),
    );
  }
}
