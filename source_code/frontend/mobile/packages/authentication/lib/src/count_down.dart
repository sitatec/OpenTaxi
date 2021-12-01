import 'dart:async';

class CountDown {
  int currentValue;
  late Stream<int> currentValueStream;

  CountDown(this.currentValue) {
    currentValueStream =
        Stream.periodic(const Duration(seconds: 1), (_) => currentValue--);
  }
}
