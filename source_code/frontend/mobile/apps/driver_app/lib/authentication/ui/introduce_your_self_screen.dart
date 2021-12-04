import 'package:driver_app/authentication/ui/introduce_your_self_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_widgets/shared_widgets.dart';

class IntroduceYourSelfScreen extends StatefulWidget {
  static const _semiBoldStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  const IntroduceYourSelfScreen({Key? key}) : super(key: key);

  @override
  State<IntroduceYourSelfScreen> createState() =>
      _IntroduceYourSelfScreenState();
}

class _IntroduceYourSelfScreenState extends State<IntroduceYourSelfScreen> {
  final userIcon = SvgPicture.asset("assets/images/user_icon.svg");

  String selectedGender = "";
  String firstName = "";
  String surName = "";
  // bool isSouthAfricanCitizen = false;

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).primaryColor.withAlpha(75);

    return IntroduceYourSelfTemplate(
        onContinue: _isContinueButtonEnabled() ? _showIsSouthAfricanCitizen : null,
        child: Column(
          children: [
            OutLinedTextField(
              onChanged: (newValue) => setState(() => firstName = newValue),
              prefixIcon: userIcon,
              fillColor: lightGray,
              hintText: "First Name",
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
              ],
            ),
            const SizedBox(height: 23),
            OutLinedTextField(
              onChanged: (newValue) => setState(() => surName = newValue),
              prefixIcon: userIcon,
              fillColor: lightGray,
              hintText: "Sur Name",
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Select Your Gender",
                      style: IntroduceYourSelfScreen._semiBoldStyle),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Gender(
                        "male",
                        onClicked: _selectGender,
                        backgroundColor:
                            selectedGender == "male" ? selectedColor : null,
                      ),
                      const SizedBox(width: 20),
                      Gender(
                        "female",
                        onClicked: _selectGender,
                        backgroundColor:
                            selectedGender == "female" ? selectedColor : null,
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ));
  }

  bool _isContinueButtonEnabled() =>
      selectedGender.isNotEmpty && firstName.isNotEmpty && surName.isNotEmpty;

  void _selectGender(String gender) => setState(() => selectedGender = gender);

  void _showIsSouthAfricanCitizen() {
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  children: [
                    const Text(
                      "Are you a citizen of",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Text(
                      "South Africa?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: RoundedCornerButton(
                            onPressed: () => _submit(true),
                            child: const Text(
                              "YES",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: RoundedCornerButton(
                            onPressed: () => _submit(false),
                            child: const Text(
                              "NO",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 17,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            enabledColor: lightGray,
                            borderSide: const BorderSide(
                              width: 0.6,
                              color: gray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  void _submit(bool isShoutAfricanCitizen) {

  }
}
