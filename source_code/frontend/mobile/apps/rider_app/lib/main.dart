import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rider_app/pages/rating_page.dart';
import 'package:rider_app/pages/trip_page.dart';
import 'package:shared/shared.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'configs/firebase_options.dart';
import 'pages/home_page.dart';
import 'pages/order_page.dart';

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hamba',
      theme: ThemeData(
        primaryColor: const Color(0xFF054BAC),
        errorColor: const Color(0xFFFE1917),
        disabledColor: const Color(0xFFB7B7B7),
        accentColor: const Color(0xFF2BC25F),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      home: true
          ? RatingPage()
          : SafeArea(
              child: FutureBuilder<FirebaseApp>(
                  future: Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
                  ),
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
                            if (authSnapshot.data == AuthState.uninitialized) {
                              return const Center(
                                  child: Text("Authenticating..."));
                            }
                            if (authSnapshot.data == AuthState.authenticated) {
                              final riderAccount =
                                  authenticationProvider.account!;
                              if (riderAccount.role != AccountRole.UNDEFINED &&
                                  riderAccount.role != AccountRole.RIDER) {
                                // TODO handle if the user is not a driver.
                                return const Center(
                                  child: Text(
                                    "This account is not a driver account!",
                                  ),
                                );
                              } else {
                                return HomePage();
                                // return MainScreen(driver);
                                // if (riderAccount.status ==
                                //     AccountStatus.REGISTRATION_IN_PROGRESS) {
                                //   return RegistrationScreen(driver);
                                // } else if (riderAccount.status ==
                                //     AccountStatus.WAITING_FOR_APPROVAL) {
                                //   return const RegistrationStatusPage(
                                //     RegistrationStatus.underReview,
                                //   );
                                // }
                                // return MainScreen(driver);
                              }
                            } else {
                              return const PhoneAuthScreen();
                            }
                          });
                    }
                    return const Center(child: Text("Loading..."));
                  }),
            ),
    );
  }
}
