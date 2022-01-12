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
      onGenerateRoute: Router.generateRoute,
      theme: ThemeData(
          // TODO
          ),
    );
  }
}

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Widget? page;
    switch (settings.name) {
      case "/driver-registration":
        page = const DriverRegistrationPage();
        break;
      default:
    }
    return MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: const Text("Hamba Admin", textScaleFactor: 0.96),
          actions: [
            InkWell(
              onTap: () {},
              child: const CircleAvatar(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.person),
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
    });
  }
}
