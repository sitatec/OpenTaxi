import 'dart:async';
import 'dart:convert';

import 'package:shared/shared.dart';
import 'package:web_socket_channel/status.dart' as close_reason;

const dispatcherServerUrl =
    "wss://dispatcher-dot-hamba-project.uc.r.appspot.com/driver";

class Dispatcher {
  WebSocketChannel? _webSocketChannel;
  final _connectionStreamController = StreamController<bool>();
  bool _isConnected = false;
  Stream<bool> get isConnected => _connectionStreamController.stream;
  Stream<MapEntry<FramType, dynamic>>? get dataStream =>
      _webSocketChannel?.stream.map(_convertData);

  Dispatcher([this._webSocketChannel]);

  MapEntry<FramType, dynamic> _convertData(data) {
    data as String;
    final separatorIndex = data.indexOf(":");
    final code = int.parse(data.substring(0, separatorIndex));
    final message = data.substring(separatorIndex + 1);
    return MapEntry(FramType.values[code], message);
  }

  Future<void> connect() async {
    if (_isConnected) return;
    _webSocketChannel =
        WebSocketChannel.connect(Uri.parse(dispatcherServerUrl));
    _connectionStreamController.add(true);
    _isConnected = true;
  }

  Future<void> disconnect() async {
    if (!_isConnected) return;
    await _webSocketChannel?.sink.close(close_reason.goingAway);
    _connectionStreamController.add(false);
    _isConnected = false;
  }

  void sendData(MapEntry<FramType, dynamic> data) {
    _webSocketChannel?.sink.add(_dataToString(data));
  }

  String _dataToString(MapEntry<FramType, dynamic> data) {
    String dataValue = data.value is Map ? jsonEncode(data.value) : data.value;
    return "${data.key.index}:$dataValue";
  }
}

enum FramType {
// There are some values we don't use, but we keep them in order to preserve the
//correct index for each value..
  BOOKING_REQUEST,
  ADD_DRIVER_DATA,
  UPDATE_DRIVER_DATA,
  DELETE_DRIVER_DATA,
  ACCEPT_BOOKING,
  REFUSE_BOOKING,
  DISPATCH_REQUEST,
  CANCEL_BOOKING,
  INVALID_DISPATCH_ID,
  NO_MORE_DRIVER_AVAILABLE,
  PAIR_DISCONNECTED,
  BOOKING_REQUEST_TIMEOUT,
  BOOKING_SENT,
  TRIP_ROOM,
}
