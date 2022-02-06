import 'package:rider_app/cache/base_cache.dart';
import 'package:rider_app/entities/address.dart';
import 'package:sqflite_common/sqlite_api.dart';

class RecentTripsAddressesCache extends BaseCache {
  RecentTripsAddressesCache() : super("recent_trips");

  @override
  Future<void> onDatabaseCreated(Database database, int databaseVersion) {
    return database.execute(
      "CREATE TABLE $tableName(id INTEGER NOT NULL PRYMARY KEY, street_address TEXT NOT NULL, latitude REAL NOT NULL, longitude REAL NOT NULL)",
    );
  }
}

extension on Address {
  Map<String, dynamic> toDatabaseEntity() => {
        "id": placeId.hashCode,
        "street_address": streetAddress,
        "latitude": coordinates!.latitude,
        "longitude": coordinates!.longitude
      };
}
