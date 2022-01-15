import 'package:communication/src/domain/config.dart';
import 'package:flutter/foundation.dart';

import 'sendbird_platform_channel.dart';
import 'models.dart';

class AudioCallManager {
  final ChannelData channelData;
  bool initialized = false;

  final _callReceivedListenners =
      <Function(String? callerId, String? callerNickname)>[];
  final _callConnectedListenners = <Function()>[];
  final _callEstablishedListenners = <Function()>[];
  final _callEndedListenners = <Function()>[];
  final _errorListenners = <Function(String)>[];
  final _logListenners = <Function(String)>[];

  @protected
  SendbirdPlatformChannel? sendbirdPlatformChannel;

  AudioCallManager(this.channelData, {this.sendbirdPlatformChannel});

  Future<void> initialize(String pushNotificationToken) async {
    sendbirdPlatformChannel ??= SendbirdPlatformChannel(
      directCallReceived: _onCallReceived,
      directCallConnected: _onCallConnected,
      directCallEstablished: _onCallEstablished,
      directCallEnded: _onCallEnded,
      onError: _onError,
      onLog: _onLog,
    );

    initialized = await sendbirdPlatformChannel!.initSendbird(
      appId: sendbirdAppId,
      userId: channelData.currentUserId,
    );
    print("AudioCallManager.initialized ==> " + initialized.toString());
  }

  void dispose() {
    _callConnectedListenners.clear();
    _callEstablishedListenners.clear();
    _callReceivedListenners.clear();
    _callEndedListenners.clear();
    _errorListenners.clear();
    _logListenners.clear();
  }

  void addEventListeners({
    dynamic Function(String?, String?)? onCallReceived,
    dynamic Function()? onCallConnected,
    dynamic Function()? onCallEstablished,
    dynamic Function()? onCallEnded,
    dynamic Function(String)? onError,
    dynamic Function(String)? onLog,
  }) {
    if (onCallReceived != null) _callReceivedListenners.add(onCallReceived);
    if (onCallConnected != null) _callConnectedListenners.add(onCallConnected);
    if (onCallEnded != null) _callEndedListenners.add(onCallEnded);
    if (onError != null) _errorListenners.add(onError);
    if (onLog != null) _logListenners.add(onLog);
    if (onCallEstablished != null) {
      _callEstablishedListenners.add(onCallEstablished);
    }
  }

  void removeEventListeners({
    dynamic Function(String?, String?)? onCallReceived,
    dynamic Function()? onCallConnected,
    dynamic Function()? onCallEstablished,
    dynamic Function()? onCallEnded,
    dynamic Function(String)? onError,
    dynamic Function(String)? onLog,
  }) {
    if (onCallReceived != null) _callReceivedListenners.remove(onCallReceived);
    if (onCallEnded != null) _callEndedListenners.remove(onCallEnded);
    if (onError != null) _errorListenners.remove(onError);
    if (onLog != null) _logListenners.remove(onLog);
    if (onCallConnected != null) {
      _callConnectedListenners.remove(onCallConnected);
    }
    if (onCallEstablished != null) {
      _callEstablishedListenners.remove(onCallEstablished);
    }
  }

  Future<bool> makeCall() {
    if (sendbirdPlatformChannel == null || !initialized) {
      throw Exception("AudioCallManager uninitialized!");
    }
    return sendbirdPlatformChannel!.startCall(channelData.remoteUserId);
  }

  Future<bool> answerCall() {
    if (sendbirdPlatformChannel == null || !initialized) {
      throw Exception("AudioCallManager uninitialized!");
    }
    return sendbirdPlatformChannel!.pickupCall();
  }

  Future<bool> endCall() {
    if (sendbirdPlatformChannel == null || !initialized) {
      throw Exception("AudioCallManager uninitialized!");
    }
    return sendbirdPlatformChannel!.endCall();
  }

  //------------------ LISTENNERS --------------------//

  _onCallReceived(String? callerId, String? callerNickname) {
    print("------------- AudioCallManager --_onCallReceived -----------");
    for (var listener in _callReceivedListenners) {
      listener(callerId, callerNickname);
    }
  }

  _onCallConnected() {
    for (var listener in _callConnectedListenners) {
      listener();
    }
  }

  _onCallEstablished() {
    for (var listener in _callEstablishedListenners) {
      listener();
    }
  }

  _onCallEnded() {
    for (var listener in _callEndedListenners) {
      listener();
    }
  }

  _onError(String message) {
    print(message);
    for (var listener in _errorListenners) {
      listener(message);
    }
  }

  _onLog(String message) {
    print(message);
    for (var listener in _logListenners) {
      listener(message);
    }
  }
}
