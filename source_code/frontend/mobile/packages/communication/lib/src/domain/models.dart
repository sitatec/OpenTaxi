class ChannelData {
  final String currentUserId;
  final String remoteUserId;
  final String remoteUserName;
  late final String channelId = interlocutorsIds.join();
  // We sort the ids to make sure that the final string below is identic in both remote and current user side.
  late List<String> interlocutorsIds = [currentUserId, remoteUserId]..sort();

  ChannelData({
    required this.currentUserId,
    required this.remoteUserId,
    required this.remoteUserName,
  });
}
