import 'package:rider_app/entities/address.dart';
import 'package:shared/shared.dart';

class DispatchRequestData {
  final Address originAddress;
  final Address destinationAddress;
  final List<Address> stopAddresses;
  final _data = <String, dynamic>{};

  Future<Map<String, dynamic>> get data async {
    await originAddress.completeAddress();
    await destinationAddress.completeAddress();
    for (var stopAddress in stopAddresses) {
      await stopAddress.completeAddress();
    }
    return _data;
  }

  DispatchRequestData(
    this.originAddress,
    this.destinationAddress,
    this.stopAddresses,
  ) {
    _data["loc"] = originAddress.toMap();
    _data["des"] = destinationAddress.toMap();
    _data["stp"] = stopAddresses.map((address) => address.toMap()).toList();
  }

  void setRiderInfo(Account riderAccount) {
    _data["id"] = riderAccount.id;
    _data["nam"] = riderAccount.displayName;
  }

  void setPaymentMethod(String paymentMethod) {
    _data["pym"] = paymentMethod;
  }

  void setGenderPreference(Gender gender) {
    _data["gnr"] = enumToString(gender);
  }

  void setVehicleCategory(VehicleCategory vehicleCategory) {
    _data["crT"] = enumToString(vehicleCategory);
  }
}
