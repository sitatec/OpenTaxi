class LocationManagerException {
  final String message;
  final LocationManagerExceptionType exceptionType;

  const LocationManagerException({
    required this.message,
    required this.exceptionType,
  });

  @override
  String toString() =>
      '$runtimeType :\nmessage => $message \ntype => $exceptionType';

  @override
  bool operator ==(Object other) {
    return other is LocationManagerException &&
        other.message == message &&
        other.exceptionType == exceptionType;
  }

  @override
  int get hashCode => message.hashCode + exceptionType.hashCode;

  LocationManagerException.permissionDenied()
      : this(
          message: 'Location access permission denied',
          exceptionType: LocationManagerExceptionType.permissionDenied,
        );

  LocationManagerException.permissionPermanentlyDenied()
      : this(
            message: 'Location access permission is permanently denied',
            exceptionType:
                LocationManagerExceptionType.permissionPermanentlyDenied);

  LocationManagerException.insufficientPermission()
      : this(
          message:
              'The granted permission is insufficient for the requested service.',
          exceptionType: LocationManagerExceptionType.insufficientPermission,
        );

  LocationManagerException.locationServiceDisabled()
      : this(
          message: 'The location service is desabled',
          exceptionType: LocationManagerExceptionType.locationServiceDisabled,
        );

  LocationManagerException.locationServiceUninitialized()
      : this(
          message:
              'The location service is not initialized you must initialize it before using it.',
          exceptionType:
              LocationManagerExceptionType.locationServiceUninitialized,
        );
}

enum LocationManagerExceptionType {
  permissionDenied,
  permissionPermanentlyDenied,
  insufficientPermission,
  locationServiceDisabled,
  locationServiceUninitialized
}
