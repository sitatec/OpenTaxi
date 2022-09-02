import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class RegistrationFormTemplate extends StatefulWidget {
  final Widget child;
  final VoidCallback? onContinue;
  final String title, subtitle;
  final String loadingMessage;

  const RegistrationFormTemplate({
    Key? key,
    required this.child,
    this.onContinue,
    this.title = "Hi there,",
    this.subtitle = "Tell us more about you!",
    this.loadingMessage = "",
  }) : super(key: key);

  @override
  State<RegistrationFormTemplate> createState() =>
      _RegistrationFormTemplateState();
}

class _RegistrationFormTemplateState extends State<RegistrationFormTemplate> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
          elevation: 0, backgroundColor: Colors.transparent, toolbarHeight: 35),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: SvgPicture.asset(
                        "assets/images/introduce_your_self.svg"),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    widget.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.subtitle, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 30),
                  widget.child,
                  RoundedCornerButton(onPressed: widget.onContinue),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          if (widget.loadingMessage.isNotEmpty) ...[
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
                          Text(widget.loadingMessage)
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
    );
  }
}
