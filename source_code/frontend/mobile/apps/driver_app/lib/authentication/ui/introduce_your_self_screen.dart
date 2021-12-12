import 'package:driver_app/authentication/ui/register_email_phone_address.dart';
import 'package:driver_app/authentication/ui/registration_form_template.dart';
import 'package:driver_app/entities/driver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';
import 'package:authentication/authentication.dart';

class IntroduceYourSelfScreen extends StatefulWidget {
  static const _semiBoldStyle = TextStyle(
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  final Driver driver;

  const IntroduceYourSelfScreen(this.driver, {Key? key}) : super(key: key);

  @override
  State<IntroduceYourSelfScreen> createState() =>
      _IntroduceYourSelfScreenState();
}

class _IntroduceYourSelfScreenState extends State<IntroduceYourSelfScreen> {
  final userIcon = SvgPicture.asset("assets/images/user_icon.svg");

  String? firstNameFieldErrorMsg;
  String? surNameFieldErrorMsg;
  String selectedGender = "";
  String firstName = "";
  String surName = "";
  String _loadingMessage = "";

  @override
  Widget build(BuildContext context) {
    final selectedColor = Theme.of(context).primaryColor.withAlpha(75);

    return RegistrationFormTemplate(
        loadingMessage: _loadingMessage,
        onContinue: _isContinueButtonEnabled() ? _submit : null,
        child: Column(
          children: [
            OutLinedTextField(
              onChanged: (newValue) => setState(() {
                firstName = newValue;
                firstNameFieldErrorMsg = null;
              }),
              prefixIcon: userIcon,
              fillColor: lightGray,
              hintText: "First Name",
              keyboardType: TextInputType.name,
              errorMessage: firstNameFieldErrorMsg,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
              ],
            ),
            const SizedBox(height: 25),
            OutLinedTextField(
              onChanged: (newValue) => setState(() {
                surName = newValue;
                surNameFieldErrorMsg = null;
              }),
              prefixIcon: userIcon,
              fillColor: lightGray,
              hintText: "Sur Name",
              keyboardType: TextInputType.name,
              errorMessage: surNameFieldErrorMsg,
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
                      GenderWidget(
                        "male",
                        onClicked: _selectGender,
                        backgroundColor:
                            selectedGender == "male" ? selectedColor : null,
                      ),
                      const SizedBox(width: 20),
                      GenderWidget(
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

  void _submit() {
    if (_isValidForm()) {
      _showIsSouthAfricanCitizen();
    }
  }

  bool _isValidForm() {
    if (firstName.length < 2) {
      setState(() => firstNameFieldErrorMsg = "At least 2 letters");
    }
    if (surName.length < 2) {
      setState(() => surNameFieldErrorMsg = "At least 2 letters");
    }
    return firstNameFieldErrorMsg == null && surNameFieldErrorMsg == null;
  }

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
                            onPressed: () => _saveDataAndGoNext(true),
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
                            onPressed: () => _saveDataAndGoNext(false),
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

  Future<void> _saveDataAndGoNext(bool isShoutAfricanCitizen) async {
    Navigator.of(context).pop(); // Hide IsSouthAfricanCitizen bottom sheet.
    setState(() => _loadingMessage = "Saving data...");
    final driverAccount = widget.driver.account;
    final accessToken = await driverAccount.accessToken!;
    driverAccount
      ..firstName = firstName
      ..surname = surName
      ..role = AccountRole.DRIVER
      ..genre = stringToEnum(selectedGender, Gender.values);
    widget.driver.isSouthAfricanCitizen = isShoutAfricanCitizen;
    try {
      await widget.driver.repository
          .create(widget.driver.toJsonObject(), accessToken);
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const RegisterEmailPhoneAddress(),
        ),
      );
    } on HttpException catch (e) {
      //TODO first check if internet connection is available, then handle the exception properly.
      print("\n");
      print(e);
      print("\n");
    } finally {
      setState(() => _loadingMessage = ""); // Hide the loading widget.
    }
  }
}
