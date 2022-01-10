class CommunicationChannelData {
  final String currentUserId;
  final String remoteUserId;
  final String remoteUserName;
  late final String channelId;
  List<String> get interlocutorsIds => [currentUserId, remoteUserId];

  CommunicationChannelData({
    required this.currentUserId,
    required this.remoteUserId,
    required this.remoteUserName,
  }) {
    interlocutorsIds.sort();
    // We sort the ids to make sure that the final string below is identic in both remote and current user side.
    channelId = interlocutorsIds.join();
  }
}
