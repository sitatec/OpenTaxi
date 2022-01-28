import 'package:flutter/material.dart';

Future<void> showInfoDialog(String title, String message, BuildContext context,
    {String? dismissButtonText, Widget? actionButton}) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: message.isEmpty ? null : Text(message),
          actions: [
            if (actionButton != null) actionButton,
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(dismissButtonText ?? "OK"),
            )
          ],
        );
      });
}
