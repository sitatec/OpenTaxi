import 'dart:async';

import 'package:flutter/material.dart';

class CountdownSlider extends StatefulWidget {
  final Duration duration;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? warningColor;
  final Duration warningDuration;
  final CountdownSliderController? controller;
  final VoidCallback? onTimeout;
  const CountdownSlider({
    required this.duration,
    required this.activeColor,
    required this.inactiveColor,
    required this.warningColor,
    required this.warningDuration,
    this.controller,
    this.onTimeout,
    Key? key,
  }) : super(key: key);

  @override
  _CountdownSliderState createState() => _CountdownSliderState();
}

class _CountdownSliderState extends State<CountdownSlider> {
  late final double durationInMilliseconds;
  late final double warningDurationInMs;
  late double requestTimeoutCountdown;

  @override
  void initState() {
    durationInMilliseconds = widget.duration.inMilliseconds.toDouble();
    warningDurationInMs = widget.warningDuration.inMilliseconds.toDouble();
    requestTimeoutCountdown = durationInMilliseconds;
    final countdownTimer =
        Timer.periodic(const Duration(milliseconds: 1), (timer) {
      setState(() => requestTimeoutCountdown--);
      if (requestTimeoutCountdown <= 0) {
        if (widget.onTimeout != null) {
          widget.onTimeout!();
        }
        timer.cancel();
      }
    });
    widget.controller?._onCanceled = () => countdownTimer.cancel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isWarningColor = requestTimeoutCountdown <= warningDurationInMs;
    return Scaffold(
      body: Center(
        child: SliderTheme(
          child: Slider(
            value: requestTimeoutCountdown,
            onChanged: (_) {},
            min: 0,
            max: durationInMilliseconds,
            activeColor:
                isWarningColor ? widget.warningColor : widget.activeColor,
            inactiveColor: widget.inactiveColor,
          ),
          data: SliderTheme.of(context).copyWith(
            thumbColor: Colors.transparent,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 0.0),
            trackShape: RectangularSliderTrackShape(),
          ),
        ),
      ),
    );
  }
}

class CountdownSliderController {
  VoidCallback? _onCanceled;

  void cancel() {
    if (_onCanceled != null) {
      _onCanceled!();
    }
  }
}
