import 'package:driver_app/authentication/ui/introduce_your_self_screen.dart';
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, data) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Hamba Driver',
            theme: ThemeData(
              primaryColor: const Color(0xFF054BAC),
              errorColor: const Color(0xFFFE1917),
              disabledColor: const Color(0xFFA7A7A7),
              fontFamily: GoogleFonts.poppins().fontFamily,
            ),
            home: data.hasData
                ? const SafeArea(
                    child: IntroduceYourSelfScreen(),
                  )
                : const Center(child: Text("Loading...")),
          );
        });
  }
}
