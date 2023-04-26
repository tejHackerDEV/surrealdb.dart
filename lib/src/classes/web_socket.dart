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

  /// Used to track whether socket connection is established or not
  /// after an error occurred. If the connection is not re-established
  /// even after [_connectionTimeout] then this will throw
  /// the error which invoked this tracker to get triggered
  Timer? _connectionTracker;
  final Duration _connectionTimeout;

  WebSocket._internal(this._uri, this._connectionTimeout) {
    _init();
  }

  factory WebSocket(
    String url, {
    Duration? timeout,
  }) {
    return WebSocket._internal(
      Uri.parse(
        url.replaceFirst('http://', 'ws://').replaceFirst('https://', 'wss://'),
      ),
      timeout ?? Duration(minutes: 1),
    );
  }

  late WebSocketChannel _webSocketChannel;
  late Completer<void> _readyCompleter;

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
      if (error is WebSocketChannelException) {
        if (_connectionTracker?.isActive != true) {
          _connectionTracker = Timer(_connectionTimeout, () {
            forceClose();
            throw error;
          });
        }
        return;
      }
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
      } else {
        // Stop the tracker as the connection is force-closed
        _connectionTracker?.cancel();
      }

      // When the WebSocket is closed
      // then we need to store the connection
      // status within the status property.
      _connectionStatus = ConnectionStatus.closed;
    });

    _webSocketChannel.ready.then((_) {
      emit(EventNames.open, null);
      // Stop the tracker as the connection is established
      _connectionTracker?.cancel();

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
    int? code,
    String? reason,
  }) {
    _isForcedClosed = true;
    _webSocketChannel.sink.close(
      code ?? 1000,
      reason ?? 'Some reason',
    );
  }

  /// This will be resolved only, if the [websocket]
  /// is ready to use. So because performing or accessing
  /// anything on this class await on this one
  Future<void> get ready => _readyCompleter.future;

  /// Returns an uri, which is used to connect to the database
  /// by the websocket
  Uri get uri => _uri;
}
