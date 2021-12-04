import 'package:flutter/material.dart';
import 'package:shared_widgets/shared_widgets.dart';

class IntroduceYourSelfTemplate extends StatelessWidget {
  final Widget child;
  final VoidCallback? onContinue;
  final String title, subtitle;

  const IntroduceYourSelfTemplate({
    Key? key,
    required this.child,
    this.onContinue,
    this.title = "Hi there,",
    this.subtitle = "Tell us more about you!",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0, backgroundColor: Colors.transparent, toolbarHeight: 35),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child:
                    SvgPicture.asset("assets/images/introduce_your_self.svg"),
              ),
              const SizedBox(height: 50),
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(subtitle, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 30),
              child,
              RoundedCornerButton(onPressed: onContinue),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
