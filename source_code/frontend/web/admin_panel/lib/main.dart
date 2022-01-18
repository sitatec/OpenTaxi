import 'package:admin_panel/pages/driver_registration_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_options.dart';

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
      onGenerateRoute: Router.generateRoute,
      home: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Router.wrappePageInDefaultScaffold(
                const DriverRegistrationPage(),
              );
            }
            return const Center(child: Text("Loading..."));
          }),
    );
  }
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    late Widget page;
    switch (settings.name) {
      case "/driver-registration":
        page = const DriverRegistrationPage();
        break;
      default:
    }

    return MaterialPageRoute(builder: (context) {
      return wrappePageInDefaultScaffold(page);
    });
  }

  static Widget wrappePageInDefaultScaffold(Widget page) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 50,
        title: const Text("Hamba Admin", textScaleFactor: 0.95),
        actions: [
          InkWell(
            onTap: () {},
            child: const CircleAvatar(
              radius: 19,
              child: Icon(
                Icons.person,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: page,
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: const [
              Text("Destination 1"),
              SizedBox(height: 8),
              Text("Destination 2"),
              SizedBox(height: 8),
              Text("Destination 3"),
              SizedBox(height: 8),
              Text("Destination 4"),
              SizedBox(height: 8),
              Text("Destination 5"),
              SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
