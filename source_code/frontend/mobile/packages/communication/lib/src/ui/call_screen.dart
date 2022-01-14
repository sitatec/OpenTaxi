import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'widgets/animated_ripples.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String _headerText = "Incoming Call...";
  bool _callAnswered = false;
  bool _speakerOn = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          children: [
            Text(
              _headerText,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: gray,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedRipples(
              color: Color(_callAnswered ? 0xFF054BAC : 0xFF2E2E2E),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  idToProfilePicture(""),
                ),
                radius: 70,
              ),
              size: 70,
            ),
            const SizedBox(height: 35),
            const Text(
              "Robert Fox",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
            ),
            const Expanded(child: SizedBox()),
            _callAnswered
                ? Column(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _speakerOn = !_speakerOn;
                          });
                        },
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              "assets/images/speaker.svg",
                              package: "communication",
                              color: _speakerOn ? theme.accentColor : null,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Speaker",
                              style: TextStyle(
                                color: _speakerOn ? theme.accentColor : gray,
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundColor: theme.errorColor.withAlpha(20),
                              child: Icon(
                                Icons.call_end,
                                color: theme.errorColor,
                                size: 33,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text("Decline"),
                          ],
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundColor: theme.errorColor.withAlpha(20),
                              child: Icon(
                                Icons.call_end,
                                color: theme.errorColor,
                                size: 33,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text("Decline"),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _callAnswered = true;
                          });
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundColor: theme.accentColor.withAlpha(20),
                              child: Icon(
                                Icons.call,
                                color: theme.accentColor,
                                size: 33,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text("Answer"),
                          ],
                        ),
                      ),
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
