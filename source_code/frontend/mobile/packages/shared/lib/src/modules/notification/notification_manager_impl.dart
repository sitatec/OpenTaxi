part of 'api.dart';

@internal
class NotificationManagerImpl implements NotificationManager {
  final FirebaseMessaging _firebaseMessaging;
  final FirebaseFunctions _firebaseFunctions;
  final _notificationStreamController = StreamController<Notification>();
  final _notificationTokenStreamController =
      StreamController<String>.broadcast();

  @override
  String? notificationToken;

  static final NotificationManagerImpl _singleton = NotificationManagerImpl();

  @override
  Stream<Notification> get incomingNotificationStream =>
      _notificationStreamController.stream;

  @override
  Stream<String> get notificationTokenStream =>
      _notificationTokenStreamController.stream;

  NotificationManagerImpl([
    FirebaseMessaging? firebaseMessaging,
    FirebaseFunctions? firebaseFunctions,
  ])  : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance,
        _firebaseFunctions = firebaseFunctions ?? FirebaseFunctions.instance {
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _notificationStreamController
            .add(_remoteMessageToNotification(message));
      }
    });
    FirebaseMessaging.onMessage.listen(_addMessageToNotificationStream);
    FirebaseMessaging.onMessageOpenedApp
        .listen(_addMessageToNotificationStream);
    _notificationTokenStreamController.onListen = () {
      if (notificationToken != null) {
        _notificationTokenStreamController.add(notificationToken!);
      }
    };
    _firebaseMessaging.getToken().then((token) {
      notificationToken = token;
      if (token != null) {
        _notificationTokenStreamController.add(token);
      }
    });
    _firebaseMessaging.onTokenRefresh.listen((token) {
      notificationToken = token;
      _notificationTokenStreamController.add(token);
    });
  }

  Notification _remoteMessageToNotification(RemoteMessage message) =>
      Notification(
          data: message.data,
          body: message.notification?.body,
          title: message.notification?.title,
          sentDateTime: message.sentTime);

  void _addMessageToNotificationStream(RemoteMessage message) {
    _notificationStreamController.add(_remoteMessageToNotification(message));
  }

  @override
  Future<AuthorizationStatus> requestPermission() async {
    final notificationSettings =
        await _firebaseMessaging.requestPermission(carPlay: true);
    return notificationSettings.authorizationStatus;
  }

  @override
  Future<void> sendNotification(
    Notification notification,
    String recipientId,
  ) async {
    _firebaseFunctions.httpsCallable("sendNotification").call({
      "notification": {
        "title": notification.title,
        "body": notification.body,
      },
      "data": notification.data,
      "to": recipientId
    });
  }
}
