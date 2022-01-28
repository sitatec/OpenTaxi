import 'package:rider_app/entities/address.dart';
import 'package:shared/shared.dart';

class DispatchRequestData {
  final Address originStreetAddress;
  final Address destinationStreetAddress;
  final List<Address> stopStreetAddresses;
  final data = <String, dynamic>{};

  DispatchRequestData(
    this.originStreetAddress,
    this.destinationStreetAddress,
    this.stopStreetAddresses,
  ) {
    data["loc"] = originStreetAddress.toMap();
    data["des"] = destinationStreetAddress.toMap();
    data["stp"] =
        stopStreetAddresses.map((address) => address.toMap()).toList();
  }

  void setRiderInfo(Account riderAccount) {
    data["id"] = riderAccount.id;
    data["nam"] = riderAccount.displayName;
  }

  void setPaymentMethod(String paymentMethod) {
    data["pym"] = paymentMethod;
  }

  void setGenderPreference(Gender gender) {
    data["gnr"] = enumToString(gender);
  }

  void setVehicleCategory(VehicleCategory vehicleCategory) {
    data["crT"] = enumToString(vehicleCategory);
  }
}
