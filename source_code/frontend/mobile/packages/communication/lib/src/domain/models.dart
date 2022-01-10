class InterlocutorsData {
  final String currentUserId;
  final String remoteUserId;
  final String remoteUserName;

  List<String> get interlocutorsIds => [currentUserId, remoteUserId];

  InterlocutorsData({
    required this.currentUserId,
    required this.remoteUserId,
    required this.remoteUserName,
  });
}
