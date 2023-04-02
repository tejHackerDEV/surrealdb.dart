import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../entities/response.dart';
import '../utils/constants.dart';
import 'emitter.dart';

enum ConnectionStatus {
  opened,
  closed,
}

class WebSocket extends Emitter {
  final Uri _uri;

  WebSocket._internal(this._uri) {
    _init();
  }

  factory WebSocket(String url) {
    return WebSocket._internal(
      Uri.parse(
        url.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://'),
      ),
    );
  }

  late final WebSocketChannel _webSocketChannel;
  late final Completer<void> _readyCompleter;

  /// Holds the current connection status of the websocket
  ConnectionStatus _connectionStatus = ConnectionStatus.closed;

  Timer? _timer;

  /// If this value is true, then websocket won't be
  /// connected upon connection close.
  bool _isForcedClosed = false;

  void _init() {
    _readyCompleter = Completer<void>();
  }

  /// Open an WebSocket connection, based on the [uri]
  void open() {
    _webSocketChannel = WebSocketChannel.connect(uri);

    // Setup event listeners so that the
    // Surreal instance can listen to the
    // necessary event types.
    _webSocketChannel.stream.listen((message) {
      final response = Response.fromJson(jsonDecode(message));
      emit(EventNames.message, response);
    }, onError: (error) {
      final response = Response.fromJson(jsonDecode(error));
      emit(EventNames.error, response);
    }, onDone: () {
      emit(EventNames.close, null);
      // If the WebSocket connection with the
      // database was closed, then we need
      // to reset the ready completer.
      if (_connectionStatus == ConnectionStatus.closed) {
        _init();
      }

      // If the connection is closed, then we
      // need to attempt to reconnect on a
      // regular basis until we are successful.
      if (!_isForcedClosed) {
        _timer = Timer(Duration(milliseconds: 2500), () {
          _timer?.cancel();
          open();
        });
      }

      // When the WebSocket is closed
      // then we need to store the connection
      // status within the status property.
      _connectionStatus = ConnectionStatus.closed;
    });

    _webSocketChannel.ready.then((_) {
      emit(EventNames.open, null);
      // When the WebSocket is opened
      // then we need to store the connection
      // status within the status property.
      _connectionStatus = ConnectionStatus.opened;

      // When the WebSocket successfully opens
      // then let's resolve the ready future so
      // that future based code can continue.
      _readyCompleter.complete();
    });
  }

  /// Sends the [data] to run as a RPC on the database
  Future<void> send(String data) async {
    await ready;
    _webSocketChannel.sink.add(data);
  }

  /// Force close the connection to the websocket.
  ///
  /// <br>
  /// Invoking this function will make the websocket completely
  /// & stop reconnecting
  void forceClose({
    int code = 1000,
    String reason = 'Some reason',
  }) {
    _isForcedClosed = true;
    _webSocketChannel.sink.close(code, reason);
  }

  /// This will be resolved only, if the [websocket]
  /// is ready to use. So because performing or accessing
  /// anything on this class await on this one
  Future<void> get ready => _readyCompleter.future;

  /// Returns an uri, which is used to connect to the database
  /// by the websocket
  Uri get uri => _uri;
}
