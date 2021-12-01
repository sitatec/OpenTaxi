import 'dart:async';

class CountDown {
  int currentValue;
  final currentValueStreamController = StreamController<int>();
  late Stream<int> currentValueStream;

  CountDown(this.currentValue) {
    currentValueStream = currentValueStreamController.stream;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      currentValueStreamController.add(currentValue--);
      if(currentValue < 0){
        timer.cancel();
      }
    });
  }
}
