import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

const registrationFromUrl = "https://github.com/sitatec/Hamba";

class PhoneNumberDoesntExistPage extends StatelessWidget {
  final String phoneNumber;
  const PhoneNumberDoesntExistPage(this.phoneNumber, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            foregroundColor: Colors.black),
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Expanded(child: SizedBox()),
              Text(
                "Unregistered Phone Number",
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.subtitle1,
                  text:
                      "No registered account is associated with the phone number ",
                  children: [
                    TextSpan(
                      text: phoneNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(
                      text:
                          ". If you don't have a account yet, please visit the link below to create one.",
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24, bottom: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: lightGray,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  registrationFromUrl,
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                "For a better experience open the link in a large screen device (e.g. PC or Tablet).",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyText2,
              ),
              const Expanded(child: SizedBox()),
              RoundedCornerButton(
                onPressed: () => _openRegistrationForm(context),
                child: const Text(
                  "Open the link on my phone",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _openRegistrationForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return const CustomWebView(
          title: "Registration Form",
          initialUrl: registrationFromUrl,
        );
      }),
    );
  }
}
