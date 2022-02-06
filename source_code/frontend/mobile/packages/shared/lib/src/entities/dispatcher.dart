import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/status.dart' as close_reason;
import 'package:web_socket_channel/web_socket_channel.dart';

const dispatcherServerUrl =
    "wss://dispatcher-dot-hamba-project.uc.r.appspot.com/driver";

class Dispatcher {
  WebSocketChannel? _webSocketChannel;
  late final StreamController<bool> _connectionStreamController;
  late final StreamController<MapEntry<FramType, dynamic>>
      _dataStreamController;
  bool _isConnected = false;
  MapEntry<FramType, dynamic>? _pendingData;
  Stream<bool> get isConnected => _connectionStreamController.stream;
  Stream<MapEntry<FramType, dynamic>> get dataStream =>
      _dataStreamController.stream;

  Dispatcher([this._webSocketChannel]) {
    _connectionStreamController = StreamController<bool>.broadcast(
      onListen: () => _connectionStreamController.add(_isConnected),
    );

    _dataStreamController =
        StreamController<MapEntry<FramType, dynamic>>.broadcast(
      onListen: () {
        if (_pendingData != null) {
          _dataStreamController.add(_pendingData!);
        }
      },
    );
  }

  void _convertData(data) {
    data as String;
    final separatorIndex = data.indexOf(":");
    final code = int.parse(data.substring(0, separatorIndex));
    final message = data.substring(separatorIndex + 1);
    if (_dataStreamController.hasListener) {
      _dataStreamController.add(MapEntry(FramType.values[code], message));
    } else {
      // TODO if no listener show notification.
      _pendingData = MapEntry(FramType.values[code], message);
    }
  }

  Future<void> connect({
    void Function(String? socketCloseReason)? onServerDisconnect,
  }) async {
    if (_isConnected) return;
    _webSocketChannel =
        WebSocketChannel.connect(Uri.parse(dispatcherServerUrl));
    _toggleConnectStatus(true);
    _webSocketChannel!.stream.listen(
      _convertData,
      onDone: () {
        _toggleConnectStatus(false);
        onServerDisconnect?.call(_webSocketChannel!.closeReason);
        print(_webSocketChannel!.closeCode);
      },
      onError: (e) {
        // TODO handle
        print(e);
      },
    );
  }

  Future<void> disconnect() async {
    if (!_isConnected) return;
    await _webSocketChannel?.sink.close(close_reason.goingAway);
    _toggleConnectStatus(false);
  }

  void _toggleConnectStatus(bool isConnected) {
    _isConnected = isConnected;
    _connectionStreamController.add(isConnected);
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
  BOOKING_ID,
  START_FUTURE_BOOKING_TRIP,
  TRIP_INFO,
  INIT_DISPATCH_SESSION,
}
