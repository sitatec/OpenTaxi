import 'package:flutter/services.dart';

class SendbirdPlatformChannel {
  Function(String? callerId, String? callerNickname)? directCallReceived;
  Function()? directCallEnded;
  Function()? directCallEstablished;
  Function()? directCallConnected;
  Function(String message)? onError;
  Function(String message)? onLog;
  late String appId;
  late String userId;

  SendbirdPlatformChannel({
    this.directCallReceived,
    this.directCallConnected,
    this.directCallEstablished,
    this.directCallEnded,
    this.onError,
    this.onLog,
  });

  static const platform = MethodChannel('com.sendbird.calls/method');

  // Trigger native code to initialize Sendbird Calls with given args
  Future<bool> initSendbird({
    required String appId,
    required String userId,
    String? accessToken,
  }) async {
    try {
      platform.setMethodCallHandler(_handleNativeMethods);

      final bool result = await platform.invokeMethod(
        "init",
        {
          "app_id": appId,
          "user_id": userId,
          "access_token": accessToken,
        },
      );
      this.appId = appId;
      this.userId = userId;
      return result;
    } catch (e) {
      print('sendbird_channels: initSendbird: ERROR: $e');
      return false;
    }
  }

  // Handle incoming platform channel messages from native side
  Future<dynamic> _handleNativeMethods(MethodCall call) async {
    switch (call.method) {
      case "direct_call_received":
        final callerId = call.arguments['caller_id'];
        final callerNickname = call.arguments['caller_nickname'];
        directCallReceived?.call(callerId, callerNickname);
        return Future.value("");
      case "direct_call_established":
        // When callee has accepted but media streams not yet connected
        directCallEstablished?.call();
        return Future.value("");
      case "direct_call_connected":
        directCallConnected?.call();
        return Future.value("");
      case "direct_call_ended":
        directCallEnded?.call();
        return Future.value("");
      case "log":
        final message = call.arguments['message'];
        onLog?.call(message);
        return Future.value("");
      case "error":
        final message = call.arguments['message'];
        onError?.call(message);
        return Future.value("");
      default:
        // Unimplemented message received
        print(
            'sendbird_channels: _handleNativeMethods: Unexpected message received: $call.method');
        return Future.value("");
    }
  }

  Future<bool> startCall(String calleeId) async {
    final bool result = await platform.invokeMethod("start_direct_call", {
      "callee_id": calleeId,
    });
    return result;
  }

  Future<bool> pickupCall() async {
    final bool result = await platform.invokeMethod("answer_direct_call", {});
    return result;
  }

  Future<bool> endCall() async {
    final bool result = await platform.invokeMethod("end_direct_call", {});
    return result;
  }
}
