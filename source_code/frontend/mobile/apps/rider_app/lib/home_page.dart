import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          MapWidget(),
          SafeArea(
            child: TextButton(
              child: Icon(Icons.menu, color: theme.disabledColor),
              onPressed: () {},
              style: TextButton.styleFrom(primary: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}
