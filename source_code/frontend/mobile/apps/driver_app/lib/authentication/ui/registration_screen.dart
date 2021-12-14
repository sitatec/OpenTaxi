import 'package:driver_app/authentication/ui/introduce_your_self_screen.dart';
import 'package:driver_app/authentication/ui/register_email_phone_address.dart';
import 'package:driver_app/entities/driver.dart';
import 'package:flutter/material.dart';
import 'package:authentication/authentication.dart';

class RegistrationScreen extends StatefulWidget {
  final Driver driver;

  const RegistrationScreen(this.driver, {Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late PageController _pageController;
  bool _isFetchingDriverData = false;

  @override
  void initState() {
    super.initState();
    final driverAccount = widget.driver.account;
    int initialPageIndex = 0;
    if (driverAccount.firstName.isNotEmpty) {
      initialPageIndex = 1;
      _fetchDriverData(driverAccount);
    }
    _pageController = PageController(initialPage: initialPageIndex);
  }

  Future<void> _fetchDriverData(Account driverAccount) async {
    _isFetchingDriverData = true;
    final accessToken = await driverAccount.accessToken!;
    final response = await widget.driver.repository
        .get({"account_id": driverAccount.id}, accessToken);
    widget.driver.updateWithJson(response["data"]);
    setState(() => _isFetchingDriverData = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        PageView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            IntroduceYourSelfScreen(widget.driver, _goToNextPage),
            RegisterEmailPhoneAddress(widget.driver, _goToNextPage),
          ],
        ),
        if (_isFetchingDriverData) ...[
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
                        CircularProgressIndicator(color: theme.primaryColor),
                        const SizedBox(height: 30),
                        const Text("Checking for saved data...")
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ],
    );
  }

  void _goToNextPage() => _pageController.nextPage(
        duration: const Duration(seconds: 1),
        curve: Curves.easeIn,
      );
}
