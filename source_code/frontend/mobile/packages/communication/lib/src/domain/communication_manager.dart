import 'dart:async';
import 'dart:io';

import 'package:communication/src/domain/config.dart';
import 'package:communication/src/domain/models.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

// TODO refactor (Completly encapsulate the sendbird api and don't expose any class from sendbird)
class ComunicationManager {
  final CommunicationChannelData _channelData;
  SendbirdSdk? _sendbirdSdk;
  GroupChannel? _comunicationChannel;

  bool isInitialized = false;
  PreviousMessageListQuery? previousMessagesQuery;

  Stream<BaseMessage?>? get newMessagesStream =>
      _sendbirdSdk?.messageReceiveStream(channelUrl: _channelData.channelId);

  ComunicationManager(this._channelData, {SendbirdSdk? sendbirdSdk})
      : _sendbirdSdk = sendbirdSdk;

  Future<void> initialize() async {
    try {
      _sendbirdSdk ??= SendbirdSdk(appId: sendbirdAppId);
      await _sendbirdSdk!.connect(_channelData.currentUserId);
      previousMessagesQuery = PreviousMessageListQuery(
          channelType: ChannelType.group, channelUrl: _channelData.channelId)
        ..reverse = true
        ..limit = 20;
      isInitialized = true;
    } catch (e) {
      //TODO
    } finally {
      dispose();
    }
  }

  Future<void> createChatChannel() async {
    if (!isInitialized) {
      return; // TODO throw uninitialized.
    }
    if (_comunicationChannel != null) {
      return; // TODO throw already joinned
    }
    try {
      final channelParams = GroupChannelParams()
        ..channelUrl = _channelData.channelId
        ..isPublic = false
        ..isDistinct = true
        ..userIds = _channelData.interlocutorsIds;
      _comunicationChannel = await GroupChannel.createChannel(channelParams);
      await _comunicationChannel!.join();
    } catch (e) {
      // TODO
    }
  }

  Future<void> joinChatChannel() async {
    if (!isInitialized) {
      return; // TODO throw uninitialized.
    }
    if (_comunicationChannel != null) {
      return; // TODO already joinned
    }
    try {
      _comunicationChannel =
          await GroupChannel.getChannel(_channelData.channelId);
      await _comunicationChannel!.join();
    } catch (e) {
      //TODO
    }
  }

  Future<bool> sendTextMessage(String message) async {
    if (_comunicationChannel == null) {
      return false; // TODO throw must join before been able to send messages
    }
    try {
      final completer = Completer<bool>();
      _comunicationChannel!.sendUserMessageWithText(message,
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
    if (_comunicationChannel == null) {
      return false; // TODO: must join before been able to send messages
    }
    try {
      final completer = Completer<bool>();
      _comunicationChannel!.sendFileMessage(FileMessageParams.withFile(file),
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
