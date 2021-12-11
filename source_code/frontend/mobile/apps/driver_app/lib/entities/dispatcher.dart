import 'dart:async';

import 'package:shared/shared.dart';
import 'package:web_socket_channel/status.dart' as close_reason;

const dispatcherServerUrl = "wss://dispatcher-dot-hamba-project.uc.r.appspot.com/driver";

class Dispatcher {
  WebSocketChannel? _webSocketChannel;
  final _connectionStreamController = StreamController<bool>();
  bool _isConnected = false;
  Stream<bool> get isConnected => _connectionStreamController.stream;

  Dispatcher([this._webSocketChannel]);

  Future<void> connect() async {
    if(_isConnected) return;
    _webSocketChannel = WebSocketChannel.connect(Uri.parse(dispatcherServerUrl));
    _connectionStreamController.add(true);
    _isConnected = true;
  }

  Future<void> disconnect() async {
    if(!_isConnected) return;
    await _webSocketChannel?.sink.close(close_reason.goingAway);
    _connectionStreamController.add(false);
    _isConnected = false;
  }
}
