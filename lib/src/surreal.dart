import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'classes/emitter.dart';
import 'classes/pinger.dart';
import 'classes/web_socket.dart';
import 'errors/index.dart';
import 'utils/constants.dart';

class Surreal extends Emitter {
  static final Map<String, Surreal> _instances = {};

  /// The url of the database endpoint to connect to
  final String _url;

  /// The authorization token
  String? _token;

  /// An interval pinger used to keep
  /// connection alive through
  /// load-balancers and proxies.
  final Pinger _pinger;

  /// Generates unique ids which can used to send
  /// in the rpc requests as a identifier.
  late final Uuid _uuid;

  /// An custom websocket which is used as run RPCs
  /// on the database
  late WebSocket _webSocket;

  /// Indicates whether [_webSocket] is initialized or not,
  /// so before accessing [_webSocket], we need to make sure this value is
  /// set to true.
  bool _isWebSocketInitialized = false;

  Surreal._internal(
    this._url,
    this._token,
    this._pinger,
  ) {
    _uuid = Uuid();
  }

  /// Returns an singleton instance for every unique [url]
  /// passed, which means only one connection to the database
  /// is instantiated for one particular [url],
  /// and the database connection does not have to be shared
  /// across components or controllers.
  factory Surreal({
    required String url,
    String? token,
    Pinger? pinger,
  }) =>
      _instances.putIfAbsent(
        url,
        () => Surreal._internal(
          url,
          token,
          pinger ?? Pinger(),
        ),
      );

  /// Used to check whether the instance is ready to be used or not
  late Completer<void> _readyCompleter;

  void _init() {
    if (_readyCompleter.isCompleted) {
      _readyCompleter = Completer<void>();
    }
    if (_token == null) {
      _readyCompleter.complete();
      return;
    }
    authenticate(_token!)
        .then((_) => _readyCompleter.complete())
        .catchError((error) => _readyCompleter.completeError(error));
  }

  /// Connects to a local or remote database endpoint.
  void connect() {
    if (_isWebSocketInitialized) {
      return;
    }
    _isWebSocketInitialized = true;
    _readyCompleter = Completer<void>();

    // Next we setup the websocket connection
    // and listen for events on the socket,
    // specifying whether logging is enabled.
    _webSocket = WebSocket(url);

    // When the connection is opened we
    // need to attempt authentication if
    // a token has already been applied.
    _webSocket.addListener(EventNames.open, (_) {
      _init();
    });

    // When we receive a socket message
    // we process it as a query response.
    _webSocket.addListener(EventNames.message, (response) {
      if (response == null) {
        throw 'Something went wrong';
      }
      emit(response.id, response);
    });

    // Open the websocket for the first
    // time. This will automatically
    // attempt to reconnect on failure.
    _webSocket.open();
  }

  /// Waits for the connection to the database to succeed.
  Future<void> wait() {
    assert(
      _isWebSocketInitialized,
      'This will happen if we forgot to call connect method',
    );
    return _webSocket.ready.then((value) => _readyCompleter.future);
  }

  /// Closes the persistent connection to the database.
  void close({
    int? code,
    String? reason,
  }) {
    if (!_isWebSocketInitialized) {
      return;
    }
    _isWebSocketInitialized = false;
    _webSocket.forceClose(code: code, reason: reason);
  }

  /// Switch to a specific namespace and database.
  Future<void> use({
    required String ns,
    required String db,
  }) async {
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kUse,
      params: [
        ns,
        db,
      ],
    );

    final response = await futureOnce(id);

    if (response.error == null) {
      return;
    }
    throw SurrealError(
      code: response.error!.code,
      message: response.error!.message,
    );
  }

  /// SignIn the user into database with the provided [user] & [pass]
  Future<void> signIn({
    required String user,
    required String pass,
  }) async {
    assert(
      _isWebSocketInitialized,
      'This will happen if we forgot to call connect method',
    );
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kSignIn,
      params: [
        {
          'user': user,
          'pass': pass,
        },
      ],
    );
    final response = await futureOnce(id);
    if (response.error != null) {
      throw AuthenticationError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }
  }

  /// Authenticates the current connection with a JWT token.
  Future<void> authenticate(String token) async {
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kAuthenticate,
      params: [
        token,
      ],
    );

    final response = await futureOnce(id);
    if (response.error != null) {
      throw AuthenticationError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }
    _token = token;
  }

  /// Sends the data to the websocket by encoding to string
  Future<void> _send({
    required String id,
    required String method,
    required List<Object> params,
  }) {
    assert(
      _isWebSocketInitialized,
      'This will happen if we forgot to call connect method',
    );
    return _webSocket.send(jsonEncode({
      'id': id,
      'method': method,
      'params': params,
    }));
  }

  String get url => _url;

  String? get token => _token;

  Pinger get pinger => _pinger;
}
