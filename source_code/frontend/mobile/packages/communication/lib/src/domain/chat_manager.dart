import 'dart:async';
import 'dart:io';

import 'package:communication/src/domain/config.dart';
import 'package:communication/src/domain/models.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

// TODO refactor (Completly encapsulate the sendbird api and don't expose any class from sendbird)
class ChatManager {
  static const messageLoadPageSize = 20;

  final ChannelData channelData;
  SendbirdSdk? _sendbirdSdk;
  GroupChannel? _comunicationChannel;

  bool isInitialized = false;
  PreviousMessageListQuery? previousMessagesQuery;

  Stream<BaseMessage?>? get newMessagesStream =>
      _sendbirdSdk?.messageReceiveStream(channelUrl: channelData.channelId);

  ChatManager(this.channelData, {SendbirdSdk? sendbirdSdk})
      : _sendbirdSdk = sendbirdSdk;

  Future<void> initialize([String? notificationToken]) async {
    // TODO set envent listenners such as `onReconnectionSucceeded` to `refresh` data when user reconnected
    if (isInitialized) return;
    try {
      _sendbirdSdk ??= SendbirdSdk(appId: sendbirdAppId);
      await _sendbirdSdk!.connect(channelData.currentUserId);
      previousMessagesQuery = PreviousMessageListQuery(
          channelType: ChannelType.group, channelUrl: channelData.channelId)
        ..reverse = true
        ..limit = messageLoadPageSize;
      if (notificationToken != null) {
        await _sendbirdSdk!.registerPushToken(
          type: PushTokenType.fcm,
          token: notificationToken,
        );
      }
      isInitialized = true;
    } catch (e) {
      //TODO
      print(e);
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
        ..channelUrl = channelData.channelId
        ..isPublic = false
        ..isDistinct = true
        ..userIds = channelData.interlocutorsIds;
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
          await GroupChannel.getChannel(channelData.channelId);
      await _comunicationChannel!.join();
    } catch (e) {
      //TODO
    }
  }

  Future<UserMessage> sendTextMessage(String message) async {
    if (_comunicationChannel == null) {
      throw Exception("ComunicationManager not initialized");
    }
    try {
      final completer = Completer<UserMessage>();
      _comunicationChannel!.sendUserMessageWithText(message,
          onCompleted: (message, error) {
        if (error != null) {
          print(error); //TODO handle
        }
        completer.complete(message);
      });
      return completer.future;
    } catch (e) {
      print(e);
      rethrow; //TODO handle
    }
  }

  Future<FileMessage> sendFileMessage(
    File file, {
    void Function(int, int)? progress,
  }) async {
    if (_comunicationChannel == null) {
      throw Exception("ComunicationManager not initialized");
    }
    try {
      final completer = Completer<FileMessage>();
      _comunicationChannel!.sendFileMessage(FileMessageParams.withFile(file),
          progress: progress, onCompleted: (message, error) {
        if (error != null) {
          print(error); //TODO handle
        }
        completer.complete(message);
      });
      return completer.future;
    } catch (e) {
      print(e);
      rethrow; //TODO handle
    }
  }

  Future<void> updateFileMessage(FileMessage message) async {
    if (_comunicationChannel == null) {
      return; // TODO: must join before been able to send messages
    }
    try {
      await _comunicationChannel!.updateFileMessage(
        message.messageId,
        FileMessageParams.withUrl(message.url),
      );
    } catch (e) {
      print(e);
      rethrow; //TODO handle
    }
  }

  Future<void> updateTextMessage(UserMessage message) async {
    if (_comunicationChannel == null) {
      return; // TODO: must join before been able to send messages
    }
    try {
      await _comunicationChannel!.updateUserMessage(
        message.messageId,
        UserMessageParams.withMessage(message),
      );
    } catch (e) {
      print(e);
      rethrow; //TODO handle
    }
  }

  Future<void> deleteMessage(int messageId) async {
    if (_comunicationChannel == null) {
      return; // TODO: must join before been able to send messages
    }
    try {
      await _comunicationChannel!.deleteMessage(messageId);
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
