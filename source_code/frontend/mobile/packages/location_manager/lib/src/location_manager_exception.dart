class DeviceLocationHandlerException {
  final String message;
  final DeviceLocationHandlerExceptionType exceptionType;

  const DeviceLocationHandlerException({
    required this.message,
    required this.exceptionType,
  });

  @override
  String toString() =>
      '$runtimeType :\nmessage => $message \ntype => $exceptionType';

  @override
  bool operator ==(Object other) {
    return other is DeviceLocationHandlerException &&
        other.message == message &&
        other.exceptionType == exceptionType;
  }

  @override
  int get hashCode => message.hashCode + exceptionType.hashCode;

  DeviceLocationHandlerException.permissionDenied()
      : this(
          message: 'Location access permission denied',
          exceptionType: DeviceLocationHandlerExceptionType.permissionDenied,
        );

  DeviceLocationHandlerException.permissionPermanentlyDenied()
      : this(
            message: 'Location access permission is permanently denied',
            exceptionType:
                DeviceLocationHandlerExceptionType.permissionPermanentlyDenied);

  DeviceLocationHandlerException.insufficientPermission()
      : this(
          message:
              'The granted permission is insufficient for the requested service.',
          exceptionType:
              DeviceLocationHandlerExceptionType.insufficientPermission,
        );

  DeviceLocationHandlerException.locationServiceDisabled()
      : this(
          message: 'The location service is desabled',
          exceptionType:
              DeviceLocationHandlerExceptionType.locationServiceDisabled,
        );

  DeviceLocationHandlerException.locationServiceUninitialized()
      : this(
          message:
              'The location service is not initialized you must initialize it before using it.',
          exceptionType:
              DeviceLocationHandlerExceptionType.locationServiceUninitialized,
        );
}

enum DeviceLocationHandlerExceptionType {
  permissionDenied,
  permissionPermanentlyDenied,
  insufficientPermission,
  locationServiceDisabled,
  locationServiceUninitialized
}
