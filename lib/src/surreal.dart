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

  /// An interval pinger used to keep
  /// connection alive through
  /// load-balancers and proxies.
  final Pinger _pinger;

  /// Generates unique ids which can used to send
  /// in the rpc requests as a identifier.
  late final Uuid _uuid;

  /// An custom websocket which is used as run RPCs
  /// on the database
  WebSocket? _webSocket;

  Surreal._internal(
    this._url,
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
    Pinger? pinger,
  }) =>
      _instances.putIfAbsent(
        url,
        () => Surreal._internal(
          url,
          pinger ?? Pinger(),
        ),
      );

  /// Connects to a local or remote database endpoint.
  void connect() {
    if (_webSocket != null) {
      throw AssertionError(
        'WebSocket is already initiated, this should occur basically if connect method is called multiple times',
      );
    }
    // Next we setup the websocket connection
    // and listen for events on the socket,
    // specifying whether logging is enabled.
    _webSocket = WebSocket(url);

    // When we receive a socket message
    // we process it as a query response.
    _webSocket!.addListener(EventNames.message, (response) {
      if (response == null) {
        throw 'Something went wrong';
      }
      emit(response.id, response);
    });

    // Open the websocket for the first
    // time. This will automatically
    // attempt to reconnect on failure.
    _webSocket!.open();
  }

  /// SignIn the user into database with the provided [user] & [pass]
  Future<String> signIn({
    required String user,
    required String pass,
  }) async {
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
    return response.result!.toString();
  }

  /// Sends the data to the websocket by encoding to string
  Future<void> _send({
    required String id,
    required String method,
    required List<Object> params,
  }) {
    return _webSocket!.send(jsonEncode({
      'id': id,
      'method': method,
      'params': params,
    }));
  }

  String get url => _url;

  Pinger get pinger => _pinger;
}
