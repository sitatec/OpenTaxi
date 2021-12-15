import 'package:driver_app/entities/driver.dart';
import 'package:shared/shared.dart' show Coordinates, JsonObject;

JsonObject locationToJson(Coordinates location) => {
      "lat": location.latitude,
      "lng": location.longitude,
    };

Future<JsonObject> driverToDispatcherData(Driver driver) async => {
      "id": driver.account.id,
      "gnr": driver.account.genre,
      "crT": await driver.car,
    };
