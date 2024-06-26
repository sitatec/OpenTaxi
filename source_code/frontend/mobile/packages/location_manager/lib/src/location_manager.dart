import 'package:location/location.dart';

import 'location_manager_exception.dart';

/// The Device location manager.
///
/// This class provides some methods which will help you to use the device location.
class LocationManager {
  Location _location;
  bool _locationServiceInitialized = false;

  static final _singleton = LocationManager._internal();

  factory LocationManager() => _singleton;

  LocationManager._internal() : _location = Location();

  LocationManager.forTest(Location location) : _location = location;

  Future<bool> get hasPermission async =>
      (await _location.hasPermission()) == PermissionStatus.granted;

  Future<bool> get backgroundEnabled => _location.isBackgroundModeEnabled();

  // TODO: check if the device os version is android 11+ to decide weither to
  // todo: explan to the user how to always allow location permission or not.

  Future<void> initialize({bool requireBackground = false}) async {
    await _requireLocationPermission();
    await _location.enableBackgroundMode(enable: requireBackground);
    if (!(await _location.serviceEnabled()) &&
        !(await _location.requestService())) {
      throw LocationManagerException.locationServiceDisabled();
    }
    _locationServiceInitialized = true;
  }

  Future<void> _requireLocationPermission() async {
    final locationPermissionStatus = await _location.hasPermission();
    if (locationPermissionStatus != PermissionStatus.granted) {
      if (locationPermissionStatus == PermissionStatus.deniedForever) {
        throw LocationManagerException.permissionPermanentlyDenied();
      } else if (locationPermissionStatus == PermissionStatus.grantedLimited) {
        throw LocationManagerException.insufficientPermission();
      }
      await _requestLocationPermission();
    }
  }

  Future<void> _requestLocationPermission() async {
    switch (await _location.requestPermission()) {
      case PermissionStatus.denied:
        throw LocationManagerException.permissionDenied();
      case PermissionStatus.deniedForever:
        throw LocationManagerException.permissionPermanentlyDenied();
      case PermissionStatus.grantedLimited:
        throw LocationManagerException.insufficientPermission();
      default:
    }
  }

  Future<Coordinates> getCurrentCoordinates() async {
    if (!_locationServiceInitialized) {
      throw LocationManagerException.locationServiceUninitialized();
    }
    final locationData = await _location.getLocation();
    return Coordinates(
      latitude: locationData.latitude!,
      longitude: locationData.longitude!,
      orientation: locationData.heading!,
    );
  }

  Stream<Coordinates> getCoordinatesStream(
      {double distanceFilterInMeter = 30, int timeInterval = 10000}) {
    if (!_locationServiceInitialized) {
      throw LocationManagerException.locationServiceUninitialized();
    }
    _location.changeSettings(
      distanceFilter: distanceFilterInMeter,
      interval: timeInterval,
    );
    return _location.onLocationChanged.map<Coordinates>(
      (locationData) => Coordinates(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        orientation: locationData.heading ?? 0,
        speed: locationData.speed ?? 0,
      ),
    );
  }

  Future<bool> setDistanceFilter(double distanceFilterInMeter) =>
      _location.changeSettings(distanceFilter: distanceFilterInMeter);
}

class Coordinates {
  late double latitude;
  late double longitude;
  double orientation = 0;

  /// Meter/Second
  double speed = 0;
  Coordinates({
    required this.latitude,
    required this.longitude,
    this.orientation = 0,
    this.speed = 0,
  });

  Coordinates.fromMap(Map<String, double> map) {
    latitude = map['latitude']!;
    longitude = map['longitude']!;
    orientation = map['orientation'] ?? 0;
    speed = map['speed'] ?? 0;
  }

  @override
  bool operator ==(Object other) {
    return other is Coordinates &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.orientation == orientation &&
        other.speed == speed;
  }

  @override
  int get hashCode =>
      latitude.hashCode +
      longitude.hashCode +
      orientation.hashCode +
      speed.hashCode;

  Map<String, double> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
        'orientation': orientation,
        'speed': speed,
      };
}
