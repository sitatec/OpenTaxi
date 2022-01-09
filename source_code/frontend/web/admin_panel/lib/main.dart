import 'package:admin_panel/pages/driver_registration_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hamba Admin',
      initialRoute: "/driver-registration",
      routes: {"/driver-registration": (_) => const DriverRegistrationPage()},
      theme: ThemeData(
          // TODO
          ),
    );
  }
}
