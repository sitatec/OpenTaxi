import 'package:rider_app/entities/address.dart';
import 'package:shared/shared.dart';

class DispatchRequestData {
  final Address originAddress;
  final Address destinationAddress;
  final List<Address> stopAddresses;
  final data = <String, dynamic>{};

  DispatchRequestData(
    this.originAddress,
    this.destinationAddress,
    this.stopAddresses,
  ) {
    data["loc"] = originAddress.toMap();
    data["des"] = destinationAddress.toMap();
    data["stp"] = stopAddresses.map((address) => address.toMap()).toList();
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
