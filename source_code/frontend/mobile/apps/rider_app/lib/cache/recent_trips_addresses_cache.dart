import 'package:rider_app/cache/base_cache.dart';
import 'package:rider_app/entities/address.dart';
import 'package:shared/shared.dart';
import 'package:sqflite_common/sqlite_api.dart';

class RecentTripsAddressesCache extends BaseCache {
  RecentTripsAddressesCache() : super("recent_trips");

  @override
  Future<void> onDatabaseCreated(Database database, int databaseVersion) {
    return database.execute(
      "CREATE TABLE $tableName(place_id TEXT NOT NULL PRYMARY KEY, street_address TEXT NOT NULL, latitude REAL NOT NULL, longitude REAL NOT NULL, created_ad INTEGER NOT NULL) WITHOUT ROWID",
    );
  }
}

extension on Address {
  JsonObject toDatabaseEntity() => {
        "place_id": placeId,
        "street_address": streetAddress,
        "latitude": coordinates!.latitude,
        "longitude": coordinates!.longitude,
        "created_ad": createdAt,
      };

  static Address fromDatabaseEntity(JsonObject entity) => Address(
        placeId: entity["place_id"],
        streetAddress: entity["street_address"],
        coordinates: Coordinates(
          latitude: entity["latitude"],
          longitude: entity["longitude"],
        ),
        createdAt: entity["created_ad"],
      );
}
