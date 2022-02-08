import 'package:shared/shared.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'base_cache.dart';

class NotificationCache extends BaseCache {
  NotificationCache() : super("notifications");

  @override
  Future<void> onDatabaseCreated(Database database, int databaseVersion) {
    return database.execute(
      "CREATE TABLE $tableName(id INTERGER NOT NULL PRIMARY KEY, title TEXT NOT NULL, body TEXT NOT NULL, type INTEGER NOT NULL, data TEXT, created_ad INTEGER NOT NULL)",
    );
  }
}

extension on Notification {
  NotificationType getNotificationType() {
    // TODO check notification data end return the right type
    return NotificationType.standard;
  }

  int getNotificationTypeAsInt() {
    return getNotificationType().index;
  }

  JsonObject toMap() => {
        "id": id!,
        "title": title!,
        "body": body!,
        "type": getNotificationTypeAsInt(),
        "data": data,
        "created_ad": sentDateTime.millisecondsSinceEpoch,
      };

  Notification fromMap(JsonObject data) => Notification(
        id: data["id"],
        title: data["title"],
        body: data["body"],
        data: data["data"],
        sentDateTime: DateTime.fromMillisecondsSinceEpoch(data["created_ad"]),
      );
}

enum NotificationType { standard, textMessage, voiceCall }
