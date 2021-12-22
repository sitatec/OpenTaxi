import 'package:driver_app/entities/driver.dart';
import 'package:shared/shared.dart' show Coordinates, JsonObject, enumToString;

JsonObject locationToJson(Coordinates location) => {
      "lat": location.latitude,
      "lng": location.longitude,
    };

Future<JsonObject> driverToDispatcherData(Driver driver) async => {
      "id": driver.account.id,
      "gnr": enumToString(driver.account.genre),
      "crT": enumToString((await driver.car).type),
    };

String idToProfilePicture(String accountId) =>
    "https://news.cornell.edu/sites/default/files/styles/breakout/public/2020-05/0521_abebegates.jpg?itok=OdW8otpB";
