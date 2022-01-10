import 'package:communication/src/domain/config.dart';
import 'package:communication/src/domain/models.dart';
import 'package:sendbird_sdk/constant/enums.dart';
import 'package:sendbird_sdk/core/channel/open/open_channel.dart';
import 'package:sendbird_sdk/params/open_channel_params.dart';
import 'package:sendbird_sdk/sdk/sendbird_sdk_api.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart';

class ComunicationManager {
  final InterlocutorsData _interlocutorsData;
  SendbirdSdk? _sendbirdSdk;

  ComunicationManager(this._interlocutorsData, {SendbirdSdk? sendbirdSdk})
      : _sendbirdSdk = sendbirdSdk;

  Future<void> initialize() async {
    try {
      _sendbirdSdk ??= SendbirdSdk(appId: sendbirdAppId);
      await _sendbirdSdk!.connect(_interlocutorsData.currentUserId);
    } catch (e) {
      //TODO
    } finally {
      dispose();
    }
  }

  Future<void> createChatChannel() async {
    try {
      final channelParams = GroupChannelParams()
        ..isPublic = false
        ..isDistinct = true
        ..userIds = _interlocutorsData.interlocutorsIds;
      final channel = await GroupChannel.createChannel(channelParams);
      await channel.join();
    } catch (e) {
      // TODO
    }
  }

  Future<void> joinChatChannel() async {
    try {
      final channelQuery = GroupChannelListQuery()
        ..userIdsExactlyIn = _interlocutorsData.interlocutorsIds;
      final channel = await channelQuery.loadNext();
      await channel.first.join();
    } catch (e) {
      //TODO
    }
  }

  Future<void> sendTextMessage(String message) async {}

  Future<void> makeAudioCall() async {}

  Future<void> dispose() async {}
}
