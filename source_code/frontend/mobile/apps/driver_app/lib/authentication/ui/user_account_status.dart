import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class UserAccountStatusPage extends StatelessWidget {
  final UserAccountStatus registrationStatus;
  final VoidCallback? action;

  const UserAccountStatusPage(this.registrationStatus, {Key? key, this.action})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: Container(
              decoration: BoxDecoration(
                color: theme.disabledColor.withAlpha(200),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Text(
                  "?",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Column(
          children: [
            const Expanded(child: Center(), flex: 2),
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  Image.asset("assets/images/${registrationStatus.imageName}"),
                  const SizedBox(height: 35),
                  Text(
                    registrationStatus.title,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    registrationStatus.subtitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            RoundedCornerButton(
              onPressed: action,
              child: Text(
                registrationStatus.actionText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UserAccountStatus {
  final String imageName;
  final String title;
  final String subtitle;
  final String actionText;

  const UserAccountStatus({
    required this.imageName,
    required this.title,
    required this.subtitle,
    required this.actionText,
  });

  static const accountUnderReview = UserAccountStatus(
    imageName: "registration_in_review.png",
    title: "Profile is under Review",
    subtitle: "It usually takes less than a day for us to complete the process",
    actionText: "Ok",
  );

  static const registrationRefused = UserAccountStatus(
    imageName: "registration_refused.png",
    title: "Your profile is not approved",
    subtitle: "Your profile has not approved. Contact Support to learn more.",
    actionText: "Contact Support",
  );

  static const accountSuspended = UserAccountStatus(
    imageName: "registration_refused.png",
    title: "Your account has been suspended",
    subtitle:
        "Unfurtunatly you can't login until your account get reactivated. Contact Support for further information.", // TODO check the text with Lu.
    actionText: "Contact Support",
  );
}
