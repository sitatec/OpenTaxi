import 'package:driver_app/entities/driver.dart';
import 'package:shared/shared.dart' show Coordinates, JsonObject, enumToString;

JsonObject locationToJson(Coordinates location) => {
      "lat": location.latitude,
      "lng": location.longitude,
    };

Future<JsonObject> driverToDispatcherData(Driver driver) async => {
      "id": driver.account.id,
      "gnr": enumToString(driver.account.genre),
      "crT": enumToString((await driver.car).category),
      "nam": driver.account.displayName,
    };
