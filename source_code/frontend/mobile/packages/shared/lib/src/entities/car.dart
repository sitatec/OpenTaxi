import 'package:data_access/data_access.dart' show JsonObject;
import 'package:shared/shared.dart';

class Car {
  final int id;
  final String brand;
  final String model;
  final int numberOfSeats;
  final String additionalInfo;
  final String registrationNumber;
  final String color;
  final String driverId;
  final CarType type;

  Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.numberOfSeats,
    required this.additionalInfo,
    required this.registrationNumber,
    required this.color,
    required this.driverId,
    required this.type,
  });

  Car.fromJson(JsonObject jsonObject)
      : this(
          id: jsonObject["id"],
          brand: jsonObject["brand"],
          model: jsonObject["model"],
          numberOfSeats: jsonObject["number_of_seats"],
          additionalInfo: jsonObject["additional_info"],
          registrationNumber: jsonObject["registration_number"],
          color: jsonObject["color"],
          driverId: jsonObject["driver_id"],
          type: stringToEnum(jsonObject["type"], CarType.values),
        );

  JsonObject toJson() => {
        "id": id,
        "brand": brand,
        "model": model,
        "number_of_seats": numberOfSeats,
        "additional_info": additionalInfo,
        "registration_number": registrationNumber,
        "color": color,
        "driver_id": driverId,
        "type": enumToString(type),
      };
}

enum CarType {
  STANDARD,
  PREMIUM,
  VAN,
  SPECIALIST,
  LITE,
}
