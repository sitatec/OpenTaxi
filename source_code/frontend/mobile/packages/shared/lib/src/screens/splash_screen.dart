import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  final bool authenticating;
  const SplashScreen({Key? key, this.authenticating = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/images/splash_screen_bg.png",
              package: "shared",
            ),
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/animated_logo.gif",
              package: "shared",
              width: MediaQuery.of(context).size.width * 0.65,
            ),
            const SizedBox(height: 40),
            if (!authenticating) ...[
              const Text(
                "Welcome to Hamba",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const Text("Let us go places together"),
            ],
            if (authenticating)
              const Text(
                "Authenticating...",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 140),
          ],
        ),
      ),
    );
  }
}
