import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';

import 'registration_form_template.dart';

class RegisterEmailPhoneAddress extends StatefulWidget {
  final VoidCallback goToNextPage;

  const RegisterEmailPhoneAddress(this.goToNextPage, {Key? key})
      : super(key: key);

  @override
  State<RegisterEmailPhoneAddress> createState() =>
      _RegisterEmailPhoneAddressState();
}

class _RegisterEmailPhoneAddressState extends State<RegisterEmailPhoneAddress> {
  String homeAddress = "";
  String email = "";
  String? alternativePhoneNumber;
  bool isAlternativePhoneEmpty = true;
  String? homeAddressFieldErrorMsg;
  String? emailAddressFieldErrorMsg;
  String? alternativePhoneFieldErrorMsg;

  @override
  Widget build(BuildContext context) {
    return RegistrationFormTemplate(
        title: "Enter your",
        subtitle: "Email address, home address and alternative phone number",
        onContinue: _isContinueButtonEnabled() ? _submit : null,
        child: Column(
          children: [
            OutLinedTextField(
              onChanged: (newValue) => setState(() {
                email = newValue;
                emailAddressFieldErrorMsg =
                    null; // Reset error msg when input change
              }),
              prefixIcon: const Icon(Icons.email),
              fillColor: lightGray,
              hintText: "Email",
              errorMessage: emailAddressFieldErrorMsg,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 23),
            OutLinedTextField(
              onChanged: (newValue) => setState(() {
                homeAddress = newValue;
                homeAddressFieldErrorMsg =
                    null; // Reset error msg when input change
              }),
              fillColor: lightGray,
              hintText: "Type your home address here...",
              errorMessage: homeAddressFieldErrorMsg,
              maxLines: 2,
              keyboardType: TextInputType.streetAddress,
            ),
            const SizedBox(height: 23),
            OutLinedTextField(
              prefixIcon: isAlternativePhoneEmpty
                  ? const Icon(Icons.local_phone)
                  : null,
              onChanged: (newValue) {
                alternativePhoneNumber = newValue;
                if (isAlternativePhoneEmpty != newValue.isEmpty ||
                    alternativePhoneNumber != null) {
                  setState(() {
                    isAlternativePhoneEmpty = newValue.isEmpty;
                    alternativePhoneFieldErrorMsg =
                        null; // Reset error msg when input change
                  });
                }
              },
              fillColor: lightGray,
              hintText: "Alternative Phone (optional)",
              prefixText: isAlternativePhoneEmpty ? null : "+27 ",
              errorMessage: alternativePhoneFieldErrorMsg,
              keyboardType: TextInputType.number,
              inputFormatters: [MaskedInputFormatter("00 000 0000")],
            ),
            const SizedBox(height: 50),
          ],
        ));
  }

  bool _isContinueButtonEnabled() => homeAddress.isNotEmpty && email.isNotEmpty;

  void _submit() {
    if (isFormValid()) {
      // SUBMIT
      widget.goToNextPage();
    }
  }

  bool isFormValid() {
    if (!RegExp(emailPattern).hasMatch(email)) {
      setState(() => emailAddressFieldErrorMsg = "Invalid email address");
    }
    if (homeAddress.length < 5) {
      // TODO implement better validation
      setState(() => homeAddressFieldErrorMsg = "Home address too short");
    }
    if (alternativePhoneNumber != null) {
      alternativePhoneNumber = alternativePhoneNumber!.replaceAll(" ", "");
      if (!RegExp(r'^[0-9]{9}$').hasMatch(alternativePhoneNumber!)) {
        setState(() => alternativePhoneFieldErrorMsg = "Invalid phone number");
      }
    }
    return emailAddressFieldErrorMsg == null &&
        homeAddressFieldErrorMsg == null &&
        alternativePhoneFieldErrorMsg == null;
  }
}
