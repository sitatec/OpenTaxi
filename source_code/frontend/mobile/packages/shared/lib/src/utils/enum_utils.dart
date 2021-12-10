T stringToEnum<T>(String str, Iterable<T> values) {
  return values.firstWhere(
    (value) => enumToString(value).toLowerCase() == str.toLowerCase(),
  );
}

String enumToString<T>(T enumValue) => enumValue.toString().split('.')[1];
