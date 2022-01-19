import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rider_app/pages/qrcode_scan_page.dart';
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
    final channelData = ChannelData(
      currentUserId: "rider",
      remoteUserId: "driver",
      remoteUserName: "Driver",
    );
    final communicationManager =
        ChatManager(channelData); // AudioCallManager(channelData);
    final splashDelay = Future.delayed(const Duration(seconds: 2));
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
      home:
          // ? FutureBuilder(
          //     future: communicationManager
          //         .initialize()
          //         .then((value) => communicationManager.joinChatChannel()),
          //     builder: (context, snapshot) {
          //       if (snapshot.connectionState == ConnectionState.done) {
          //         return ChatScreen(communicationManager);
          //       }
          //       return Text("Loading");
          //     })
          // FutureBuilder(
          // future: communicationManager.initialize(""),
          // builder: (context, snapshot) {
          //   if (snapshot.connectionState == ConnectionState.done) {
          //     communicationManager.addEventListeners(
          //         onCallReceived: (_, __) {
          //       print("----------- onCallReceived --------------");
          //       Navigator.of(context).push(MaterialPageRoute(
          //           builder: (context) =>
          //               CallScreen(communicationManager)));
          //     });
          //     return Text("Waiting For call");
          //   }
          //   return Text("Loading");
          // })
          SafeArea(
        child: FutureBuilder<FirebaseApp>(
            future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            ).then((value) async {
              await splashDelay;
              return value;
            }),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                // TODO check if internet connection is available, if not show appropriate screen
                // TODO show "something went wrong" screen when internet connection is available.
              }
              if (snapshot.connectionState == ConnectionState.done) {
                final authenticationProvider = AuthenticationProvider.instance;
                return StreamBuilder<AuthState>(
                    stream: authenticationProvider.authBinaryState,
                    initialData: AuthState.uninitialized,
                    builder: (context, authSnapshot) {
                      if (authSnapshot.data == AuthState.uninitialized) {
                        return const SplashScreen(authenticating: true);
                      }
                      if (authSnapshot.data == AuthState.authenticated) {
                        final riderAccount = authenticationProvider.account!;
                        if (riderAccount.role != AccountRole.UNDEFINED &&
                            riderAccount.role != AccountRole.RIDER) {
                          // TODO handle if the user is not a driver.
                          return Scaffold(
                            body: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "This account is not a rider account!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  TextButton(
                                    onPressed: authenticationProvider.signOut,
                                    child: const Text(
                                      "Logout",
                                      textScaleFactor: 1.5,
                                    ),
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                        side: BorderSide(
                                          color: Theme.of(context)
                                              .primaryColor
                                              .withAlpha(30),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        } else {
                          return const HomePage();
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
              return const SplashScreen();
            }),
      ),
    );
  }
}
