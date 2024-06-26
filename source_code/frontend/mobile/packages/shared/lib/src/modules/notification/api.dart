import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

part 'notification_manager_impl.dart';

abstract class NotificationManager {
  Stream<Notification> get incomingNotificationStream;
  Stream<String> get notificationTokenStream;

  factory NotificationManager() => NotificationManagerImpl._singleton;

  Future<AuthorizationStatus> requestPermission();

  Future<void> sendNotification(Notification notification, String recipientId);

  Future<String?> getNotificationToken();
}

class Notification {
  final String? id;
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final DateTime sentDateTime;

  Notification({
    this.title,
    this.body,
    this.data,
    DateTime? sentDateTime,
    this.id,
  }) : sentDateTime = sentDateTime?.toLocal() ?? DateTime.now();
}
