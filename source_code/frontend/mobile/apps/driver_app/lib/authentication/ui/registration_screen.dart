import 'package:driver_app/authentication/ui/introduce_your_self_screen.dart';
import 'package:driver_app/authentication/ui/register_email_phone_address.dart';
import 'package:driver_app/entities/driver.dart';
import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  final Driver driver;
  late final PageController _pageController;

  RegistrationScreen(this.driver, {Key? key}) : super(key: key) {
    int initialPageIndex = 0;
    if (driver.account.firstName.isNotEmpty) {
      initialPageIndex = 1;
    }
    _pageController = PageController(initialPage: initialPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      children: [
        IntroduceYourSelfScreen(driver, _goToNextPage),
        RegisterEmailPhoneAddress(_goToNextPage),
      ],
    );
  }

  void _goToNextPage() {
    _pageController.nextPage(
        duration: const Duration(seconds: 1), curve: Curves.easeIn);
  }
}
