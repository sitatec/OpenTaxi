import 'package:data_access/data_access.dart' show JsonObject;
import 'package:shared/shared.dart';

class Vehicle {
  final int id;
  final String make;
  final String model;
  final String registrationNumber;
  final String color;
  final String driverId;
  final VehicleCategory category;

  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.registrationNumber,
    required this.color,
    required this.driverId,
    required this.category,
  });

  Vehicle.fromJson(JsonObject jsonObject)
      : this(
          id: jsonObject["id"],
          make: jsonObject["make"],
          model: jsonObject["model"],
          registrationNumber: jsonObject["registration_number"],
          color: jsonObject["color"],
          driverId: jsonObject["driver_id"],
          category:
              stringToEnum(jsonObject["category"], VehicleCategory.values),
        );

  JsonObject toJson() => {
        "id": id,
        "make": make,
        "model": model,
        "registration_number": registrationNumber,
        "color": color,
        "driver_id": driverId,
        "category": enumToString(category),
      };
}

enum VehicleCategory {
  STANDARD,
  LITE,
  PREMIUM,
  CREW,
  UBUNTU,
}
