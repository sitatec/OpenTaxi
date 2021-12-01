import 'dart:async';

import 'package:authentication/src/api/phone_number_verifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';


class PhoneAuthScreen extends StatefulWidget {
  static const minNumberLength = 9;
  static const phoneNumberFieldStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  const PhoneAuthScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  bool isContinueButtonEnabled = false;
  String phoneNumber = "";

  // final phoneNumberVerifier = PhoneNumberVerifier();
  StreamSubscription? verificationStateStreamSubscription;

  @override
  void initState() {
    super.initState();
    verificationStateStreamSubscription =
        null?.verificationStateChanges.listen((event) {
          switch (event) {
            case PhoneNumberVerificationState.codeSent:
            // TODO: Handle this case.

              break;
            case PhoneNumberVerificationState.completed:
              throw Exception(
                  "Illegal State: phone verification can't be completed before user entering the code");
            case PhoneNumberVerificationState.failed:
            // TODO: Handle this case.
              break;
          }
        });
  }

  void _showCodeSentMessage() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        isDismissible: false,
        context: context,
        builder: (context) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.bottomRight,
                child: SvgPicture.asset(
                  "assets/images/code_sent.svg",
                  package: "authentication",
                ),
              ),
              Container(
                padding: const EdgeInsets.all(19),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 25),
                      child: Text.rich(
                        TextSpan(
                            text: "We have sent 6-digit code to ",
                            children: [
                              TextSpan(
                                text: phoneNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                ),
                              )
                            ]),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _RoundedCornerButton(onPressed: () {}),
                  ],
                ),
              ),
            ],
          );
        });
  }

  @override
  void dispose() {
    verificationStateStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            SvgPicture.asset(
              "assets/images/enter_phone_number.svg",
              package: "authentication",
            ),
            const SizedBox(height: 25),
            Text(
              "Enter your Phone Number",
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              "Hamba will send you a text with a verification code.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 39),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(right: 4),
                    child: const Center(
                        child: Text("+27",
                            style: PhoneAuthScreen.phoneNumberFieldStyle)),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFF565656),
                          width: 0.9,
                        ),
                        color: const Color(0xFFF3F3F3)),
                    height: 54,
                  ),
                  flex: 2,
                ),
                const SizedBox(
                  width: 7,
                ),
                Expanded(
                  child: TextField(
                    onChanged: (newValue) {
                      if (newValue.length >= PhoneAuthScreen.minNumberLength &&
                          !isContinueButtonEnabled) {
                        setState(() {
                          isContinueButtonEnabled = true;
                          phoneNumber = "+27 $newValue";
                        });
                      } else if (newValue.length <
                          PhoneAuthScreen.minNumberLength &&
                          isContinueButtonEnabled) {
                        setState(() {
                          isContinueButtonEnabled = false;
                        });
                      }
                    },
                    style: PhoneAuthScreen.phoneNumberFieldStyle.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: Color(0xFF565656),
                          width: 0.6,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      filled: true,
                      fillColor: const Color(0xFFF3F3F3),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(),
                  ),
                  flex: 8,
                ),
              ],
            ),
            const SizedBox(height: 60),
            _RoundedCornerButton(onPressed: _sendVerificationCode),
          ]),
        ),
      ),
    );
  }

  void _sendVerificationCode() async {
    _showCodeSentMessage();
    // await phoneNumberVerifier.sendVerificationSMS(phoneNumber);
  }
}

class _RoundedCornerButton extends StatelessWidget {
  Color? disabledColor, enabledColor;
  final VoidCallback onPressed;

  _RoundedCornerButton(
      {this.disabledColor, this.enabledColor, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    disabledColor ??= theme.disabledColor;
    enabledColor ??= theme.primaryColor;
    return SizedBox(
      height: 54,
      child: TextButton(
        onPressed: onPressed,
        child: SizedBox(
          width: double.infinity,
          child: Text(
            "Continue",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          backgroundColor: MaterialStateProperty.resolveWith(
                (states) => states.contains(MaterialState.disabled)
                ? disabledColor
                : enabledColor,
          ),
        ),
      ),
    );
  }
}


