part of 'api.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'hamba_chat_channel4', // id
  'Hamba chat channel 4', // title
  description:
      'This channel is used for displaying notification for text messages and audio calls.', // description
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound("chat_notification"),
);

Future<void> _handler(RemoteMessage message) async {
  print("---------- ON_BACKGROUND_NOTIFICATION ----------");
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  print("---------- FlutterLocalNotificationsPlugin INSTANCIATED ----------");
  // final Map<String, dynamic> sendbird = message.data["sendbird"];
  flutterLocalNotificationsPlugin.show(
      // message.hashCode,
      // sendbird["push_title"],
      // sendbird["message"],
      4,
      "Title",
      "Body",
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id, channel.name,
          channelDescription: channel.description,
          sound: channel.sound,
          icon: "@mipmap/ic_launcher",
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          visibility: NotificationVisibility.public,
          // other properties...
        ),
      ));

  print("---------- END_BACKGROUND_HANDLER ----------");
}

@internal
class NotificationManagerImpl implements NotificationManager {
  final FirebaseMessaging _firebaseMessaging;
  final FirebaseFunctions _firebaseFunctions;
  final _notificationStreamController = StreamController<Notification>();
  final _notificationTokenStreamController =
      StreamController<String>.broadcast();

  String? _notificationToken;

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
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
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
      if (_notificationToken != null) {
        _notificationTokenStreamController.add(_notificationToken!);
      }
    };
    _firebaseMessaging.getToken().then((token) {
      _notificationToken = token;
      if (token != null) {
        _notificationTokenStreamController.add(token);
      }
    });
    _firebaseMessaging.onTokenRefresh.listen((token) {
      _notificationToken = token;
      _notificationTokenStreamController.add(token);
    });
    FirebaseMessaging.onBackgroundMessage(_handler);
    Future.delayed(Duration(seconds: 25), () {
      print("------------------- handler manually called -------------------");
      _handler(RemoteMessage());
    });
  }

  @override
  Future<String?> getNotificationToken() => _firebaseMessaging.getToken();

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
