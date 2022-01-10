import 'dart:async';
import 'dart:io';

import 'package:communication/src/domain/config.dart';
import 'package:communication/src/domain/models.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/core/channel/open/open_channel.dart';
import 'package:sendbird_sdk/params/open_channel_params.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ComunicationManager {
  final CommunicationChannelData _channelData;
  SendbirdSdk? _sendbirdSdk;
  GroupChannel? comunicationChannel;
  bool isInitialized = false;

  ComunicationManager(this._channelData, {SendbirdSdk? sendbirdSdk})
      : _sendbirdSdk = sendbirdSdk;

  Future<void> initialize() async {
    try {
      _sendbirdSdk ??= SendbirdSdk(appId: sendbirdAppId);
      await _sendbirdSdk!.connect(_channelData.currentUserId);
      isInitialized = true;
    } catch (e) {
      //TODO
    } finally {
      dispose();
    }
  }

  Future<void> createChatChannel() async {
    try {
      final channelParams = GroupChannelParams()
        ..channelUrl = _channelData.channelId
        ..isPublic = false
        ..isDistinct = true
        ..userIds = _channelData.interlocutorsIds;
      comunicationChannel = await GroupChannel.createChannel(channelParams);
      await comunicationChannel!.join();
    } catch (e) {
      // TODO
    }
  }

  Future<void> joinChatChannel() async {
    if (comunicationChannel != null) {
      return; // TODO already joinned
    }
    try {
      comunicationChannel =
          await GroupChannel.getChannel(_channelData.channelId);
      await comunicationChannel!.join();
    } catch (e) {
      //TODO
    }
  }

  Future<bool> sendTextMessage(String message) async {
    if (comunicationChannel == null) {
      return false; // TODO must join before been able to send messages
    }
    try {
      final completer = Completer<bool>();
      comunicationChannel!.sendUserMessageWithText(message,
          onCompleted: (message, error) {
        if (error != null) {
          print(error); //TODO handle
        }
        completer
            .complete(message.sendingStatus == MessageSendingStatus.succeeded);
      });
      return completer.future;
    } catch (e) {
      print(e);
      rethrow; //TODO handle
    }
  }

  Future<bool> sendFileMessage(File file) async {
    if (comunicationChannel == null) {
      return false; // TODO must join before been able to send messages
    }
    try {
      final completer = Completer<bool>();
      comunicationChannel!.sendFileMessage(FileMessageParams.withFile(file),
          onCompleted: (message, error) {
        if (error != null) {
          print(error); //TODO handle
        }
        completer
            .complete(message.sendingStatus == MessageSendingStatus.succeeded);
      });
      return completer.future;
    } catch (e) {
      print(e);
      rethrow; //TODO handle
    }
  }

  Future<void> makeAudioCall() async {}

  Future<void> dispose() async {
    _sendbirdSdk?.disconnect();
  }
}
