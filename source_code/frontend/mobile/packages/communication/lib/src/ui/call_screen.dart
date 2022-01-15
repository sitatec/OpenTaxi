import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import 'widgets/animated_ripples.dart';

final _audioPlayer = AudioPlayer(playerId: "call");

class CallScreen extends StatefulWidget {
  final AudioCache _audioCache;
  final AudioCallManager _audioCallManager;
  final bool isReceived;
  CallScreen(this._audioCallManager,
      {Key? key, AudioCache? audioCache, this.isReceived = false})
      : _audioCache = audioCache ??
            AudioCache(
                prefix: "packages/communication/assets/audios/",
                fixedPlayer: _audioPlayer),
        super(key: key) {
    if (isReceived) {
      _audioCache
        ..duckAudio = true
        ..loop("call_notification.mpeg");
    }
  }

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  String _headerText = "Incoming Call...";
  bool _callAnswered = false;
  bool _speakerOn = false;
  bool _callEnded = false;
  Timer? _callTimer;
  late final _audioCallManager = widget._audioCallManager;

  @override
  void initState() {
    super.initState();
    _audioCallManager.addEventListeners(
      onCallConnected: _onCallConnected,
      onCallEnded: _onCallEnded,
      onError: _onError,
    );
  }

  @override
  void dispose() {
    _audioCallManager.removeEventListeners(
      onCallConnected: _onCallConnected,
      onCallEnded: _onCallEnded,
      onError: _onError,
    );
    _callTimer?.cancel();
    widget._audioCache.fixedPlayer!.stop();
    widget._audioCache.fixedPlayer!.release();
    super.dispose();
  }

  _onCallConnected() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callAnswered = true;
        _headerText = Duration(seconds: timer.tick).toString().substring(0, 5);
      });
    });
  }

  _onCallEnded() {
    // TODO play hangup sound.
    setState(() {
      _callEnded = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
    });
  }

  _onError(String message) {
    //TOOD
    print("\n");
    print("---- ERROR ---- message ===>" + message);
    print("\n");
  }

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
            Text(
              _audioCallManager.channelData.remoteUserName,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
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
                        onTap: () {
                          // TODO  check if success or not and handle accordingly
                          _audioCallManager.endCall();
                        },
                        child: CircleAvatar(
                          radius: 38,
                          backgroundColor: theme.errorColor.withAlpha(20),
                          child: Icon(
                            Icons.call_end,
                            color: theme.errorColor,
                            size: 33,
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () {
                          // TODO  check if success or not and handle accordingly
                          _audioCallManager.endCall();
                          widget._audioCache.fixedPlayer!.stop();
                        },
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
                          // TODO  check if success or not and handle accordingly
                          final answeredSuccessfully =
                              _audioCallManager.answerCall();
                          widget._audioCache.fixedPlayer!.stop();
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
