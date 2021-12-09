import 'package:driver_app/authentication/ui/introduce_your_self_screen.dart';
import 'package:driver_app/authentication/ui/register_email_phone_address.dart';
import 'package:driver_app/authentication/ui/registration_status.dart';
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

import 'main_screen.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  final authenticationProvider = AuthenticationProvider.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // TODO check if internet connection is available, if not show appropriate screen
            // TODO show "something went wrong" screen when internet connection is available.
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<AuthState>(
                stream: authenticationProvider.authBinaryState,
                builder: (context, snapshot) {
                  if (snapshot.data == AuthState.authenticated) {
                    final userAccount = authenticationProvider.account!;
                    if (userAccount.status == AccountStatus.unregistered) {
                      return const IntroduceYourSelfScreen();
                    } else if (userAccount.status ==
                        AccountStatus.waitingForApproval) {
                      return const RegistrationStatusPage(
                          RegistrationStatus.underReview);
                    }
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
                      home: const SafeArea(child: MainScreen()),
                    );
                  } else {
                    return const PhoneAuthScreen();
                  }
                });
          }
          return const Center(child: Text("Loading..."));
        });
  }
}
