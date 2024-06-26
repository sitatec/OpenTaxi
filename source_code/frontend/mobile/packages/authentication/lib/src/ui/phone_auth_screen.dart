import 'dart:async';

import 'package:authentication/src/ui/phone_number_doesnt_exist_page.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

// TODO refactor
class PhoneAuthScreen extends StatefulWidget {
  static const numberLength = 11;
  static const phoneNumberFieldStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  final bool phoneNumberShouldExist;

  const PhoneAuthScreen({this.phoneNumberShouldExist = false, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  bool isContinueButtonEnabled = false;
  bool isInvalidPhoneNumber = false;
  String phoneNumber = "";
  bool isSendingVerificationCode = false;
  bool loginInProgress = false;
  bool checkingIfNumberRegistered = false;

  final phoneNumberVerifier = PhoneNumberVerifier();
  StreamSubscription? verificationStateStreamSubscription;

  @override
  void initState() {
    super.initState();
    verificationStateStreamSubscription =
        phoneNumberVerifier.verificationStateChanges.listen((event) {
      if (isSendingVerificationCode) {
        setState(() {
          isSendingVerificationCode = false;
        });
      }
      if (event == PhoneNumberVerificationState.codeSent) {
        _showCodeSentMessage();
      } else if (event == PhoneNumberVerificationState.failed) {
        if (phoneNumberVerifier.exception?.exceptionType ==
            AuthenticationExceptionType.invalidPhoneNumber) {
          setState(() => isInvalidPhoneNumber = true);
        } else {
          // TODO handle
        }
      }
    });
  }

  void _showCodeSentMessage() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        isScrollControlled: true,
        isDismissible: false,
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 25),
                    child: Text(
                      "We have sent 6-digit code\nto $phoneNumber",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SvgPicture.asset(
                          "assets/images/code_sent.svg",
                          package: "authentication",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RoundedCornerButton(onPressed: () async {
                              Navigator.of(context).pop(); // close bottom sheet
                              // wait for the bottom sheet to complete closing
                              // and then navigate to the CodeVerificationScreen
                              final isLogedIn = await Navigator.of(context)
                                  .push<bool>(MaterialPageRoute(
                                builder: (context) => CodeVerificationScreen(
                                  phoneNumberVerifier,
                                ),
                              ));
                              if (isLogedIn ?? false) {
                                setState(() => loginInProgress = true);
                              }
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        });
  }

  @override
  void deactivate() {
    verificationStateStreamSubscription?.pause();
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    verificationStateStreamSubscription?.resume();
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
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                        "We will send you a text with a verification code.",
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 39),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(
                                  right: 4, top: 11, bottom: 14),
                              child: const Center(
                                child: Text(
                                  "+224",
                                  style: PhoneAuthScreen.phoneNumberFieldStyle,
                                ),
                              ),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xFF565656),
                                    width: 0.9,
                                  ),
                                  color: const Color(0xFFF3F3F3)),
                            ),
                            flex: 2,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: TextField(
                              maxLength: PhoneAuthScreen.numberLength,
                              onSubmitted: (value) {
                                if (value.length ==
                                    PhoneAuthScreen.numberLength) {
                                  _sendVerificationCode();
                                }
                              },
                              onChanged: (newValue) {
                                if (isInvalidPhoneNumber) {
                                  setState(() {
                                    isInvalidPhoneNumber = false;
                                  });
                                }
                                if (newValue.length >=
                                    PhoneAuthScreen.numberLength) {
                                  setState(() {
                                    isContinueButtonEnabled = true;
                                    phoneNumber = "+224 $newValue";
                                  });
                                } else if (newValue.length <
                                        PhoneAuthScreen.numberLength &&
                                    isContinueButtonEnabled) {
                                  setState(() {
                                    isContinueButtonEnabled = false;
                                  });
                                }
                              },
                              style: PhoneAuthScreen.phoneNumberFieldStyle
                                  .copyWith(
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                counter: Container(),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF565656),
                                    width: 0.6,
                                  ),
                                ),
                                errorText: isInvalidPhoneNumber
                                    ? "Invalid phone number"
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 14),
                                filled: true,
                                fillColor: const Color(0xFFF3F3F3),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                MaskedInputFormatter("00 000 0000")
                              ],
                            ),
                            flex: 8,
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),
                      RoundedCornerButton(
                          onPressed: isContinueButtonEnabled
                              ? _sendVerificationCode
                              : null),
                    ]),
              ),
            ),
            if (isSendingVerificationCode) ...[
              Container(color: const Color(0x70000000)),
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  // width: min(screenWidth * 0.75, 350),
                  // height: 350,
                  children: [
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 25),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                                color: theme.primaryColor),
                            const SizedBox(height: 30),
                            const Text(
                                "Sending SMS containing verification code")
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
            if (loginInProgress) ...[
              Container(color: const Color(0x70000000)),
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  // width: min(screenWidth * 0.75, 350),
                  // height: 350,
                  children: [
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 25),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                                color: theme.primaryColor),
                            const SizedBox(height: 30),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16,
                              ),
                              child: Text("Login..."),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
            if (checkingIfNumberRegistered) ...[
              Container(color: const Color(0x70000000)),
              Align(
                alignment: Alignment.center,
                child: Wrap(
                  // width: min(screenWidth * 0.75, 350),
                  // height: 350,
                  children: [
                    Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 25),
                        child: Column(
                          children: [
                            CircularProgressIndicator(
                                color: theme.primaryColor),
                            const SizedBox(height: 30),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16,
                              ),
                              child: Text(
                                "Checking if your phone number is registered",
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  void _sendVerificationCode() async {
    FocusScope.of(context).unfocus();
    if (widget.phoneNumberShouldExist &&
        !(await _phoneNumberExists(phoneNumber))) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PhoneNumberDoesntExistPage(phoneNumber),
        ),
      );
    } else {
      phoneNumberVerifier.sendVerificationSMS(phoneNumber);
      setState(() {
        isSendingVerificationCode = true;
      });
    }
  }

  Future<bool> _phoneNumberExists(String phoneNumber) async {
    setState(() => checkingIfNumberRegistered = true);
    try {
      final cleanedPhoneNumber = phoneNumber.substring(4).replaceAll(" ", "");
      final response = await FirebaseFunctions.instance
          .httpsCallable("checkIfPhoneNumberExist")
          .call(cleanedPhoneNumber);
      return response.data;
    } finally {
      // TODO catch and handle exception.
      setState(() => checkingIfNumberRegistered = false);
    }
  }
}
