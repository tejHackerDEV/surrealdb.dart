import 'dart:async';
import 'dart:convert';

import 'package:uuid/uuid.dart';

import 'classes/emitter.dart';
import 'classes/pinger.dart';
import 'classes/web_socket.dart';
import 'entities/authentication.dart';
import 'entities/json_patch.dart';
import 'entities/result.dart';
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
    // a token has already been applied
    // and emit the status change.
    _webSocket.addListener(EventNames.open, (_) {
      emit(EventNames.open, null);

      _init();

      _pinger.start(ping);
    });

    // When the connection is closed we
    // change the relevant properties
    // and emit the status change
    _webSocket.addListener(EventNames.close, (_) {
      emit(EventNames.close, null);

      _pinger.stop();
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

  /// Ping SurrealDB instance
  Future<void> ping() async {
    final id = _uuid.v4();
    return _send(
      id: id,
      method: RPCMethodNames.kPing,
      params: [],
    );
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

  /// Signup to a specific [authentication] scope.
  Future<void> signup(SignupAuthentication authentication) async {
    assert(
      _isWebSocketInitialized,
      'This will happen if we forgot to call connect method',
    );
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kSignup,
      params: [
        authentication.toJson(),
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

  /// SignIn using the [authentication] strategy applied
  Future<void> signIn(SignInAuthentication authentication) async {
    assert(
      _isWebSocketInitialized,
      'This will happen if we forgot to call connect method',
    );
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kSignIn,
      params: [
        authentication.toJson(),
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

  /// Invalidates the authentication for the current connection.
  Future<void> invalidate() async {
    assert(
      _isWebSocketInitialized,
      'This will happen if we forgot to call connect method',
    );
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kInvalidate,
      params: [],
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

  /// Assigns a [value] as a parameter with [key] as identifier
  /// for this connection.
  Future<void> let({
    required String key,
    required dynamic value,
  }) async {
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kLet,
      params: [
        key,
        value,
      ],
    );

    final response = await futureOnce(id);
    if (response.error != null) {
      throw SurrealError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }
  }

  /// Runs a set of [sql] (SurrealQL) statements against the database.
  /// & returns a [Iterable<OkResult>]
  ///
  /// <br>
  /// [vars] is used to pass any dynamic variables which will be
  /// later on inserted into the [sql] statements automatically
  /// if any matching key found in the [sql] statements
  Future<Iterable<OkResult>> query(
    String sql, [
    Map<String, dynamic>? vars,
  ]) async {
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kQuery,
      params: [
        sql,
        if (vars != null) vars,
      ],
    );

    final response = await futureOnce(id);
    if (response.error != null) {
      throw SurrealError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }
    final result = response.result;
    if (result is! Iterable) {
      if (result is! OkResult) {
        return Iterable.empty();
      }
      return [result];
    }

    final results = result.map((result) {
      if (result is! OkResult) {
        throw SurrealError(code: -1, message: (result as ErrResult).detail);
      }
      return result;
    });
    return results;
  }

  /// Selects all records in a table if [thing] is table name
  /// or a specific record, if [thing] is record id from the database.
  Future<Iterable<DynamicResult>> select(String thing) async {
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kSelect,
      params: [thing],
    );

    final response = await futureOnce(id);
    if (response.error != null) {
      throw SurrealError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }

    final result = response.result;
    if (result is! Iterable) {
      if (result is! DynamicResult) {
        return Iterable.empty();
      }
      return [result];
    }
    return result.map((result) {
      if (result is! DynamicResult) {
        throw SurrealError(code: -1, message: (result as ErrResult).detail);
      }
      return result;
    });
  }

  /// Creates a record in the database with any [data] if provided.
  ///
  /// <br>
  /// If [thing] is a table name then random id will be given to the
  /// record ie., created in the database.
  ///
  /// <br>
  /// If [thing] is a table name along with some id, then the provided
  /// id will be used as the record id for the record ie.,
  /// created in the database.
  Future<Iterable<DynamicResult>> create(
    String thing, [
    Map<String, dynamic>? data,
  ]) async {
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kCreate,
      params: [
        thing,
        if (data != null) data,
      ],
    );

    final response = await futureOnce(id);
    if (response.error != null) {
      throw SurrealError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }

    final result = response.result;
    if (result is! Iterable) {
      if (result is! DynamicResult) {
        return Iterable.empty();
      }
      return [result];
    }
    return result.map((result) {
      if (result is! DynamicResult) {
        throw SurrealError(code: -1, message: (result as ErrResult).detail);
      }
      return result;
    });
  }

  /// Update a single or multiple records in the database
  /// with the [data] provided.
  ///
  /// <br>
  /// If [thing] is only table name then all records in the table
  /// will be updated
  ///
  /// <br>
  /// If [thing] is a table name along with some id then, only the
  /// matching record with the id will be updated.
  Future<Iterable<DynamicResult>> update(
    String thing,
    Map<String, dynamic> data,
  ) async {
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kUpdate,
      params: [
        thing,
        data,
      ],
    );

    final response = await futureOnce(id);
    if (response.error != null) {
      throw SurrealError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }

    final result = response.result;
    if (result is! Iterable) {
      if (result is! DynamicResult) {
        return Iterable.empty();
      }
      return [result];
    }
    return result.map((result) {
      if (result is! DynamicResult) {
        throw SurrealError(code: -1, message: (result as ErrResult).detail);
      }
      return result;
    });
  }

  /// Merges  the [data] provided with single or multiple
  /// records in the database
  ///
  /// <br>
  /// If [thing] is only table name then [data] gets
  /// merged with all records in the table
  ///
  /// <br>
  /// If [thing] is a table name along with some id then,
  /// then [data] gets merged only with the matching record with the id.
  Future<Iterable<DynamicResult>> merge(
    String thing,
    Map<String, dynamic> data,
  ) async {
    assert(
      data.isNotEmpty,
      'Merging empty data with the record/records won\'t do anything',
    );
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kChange,
      params: [
        thing,
        data,
      ],
    );

    final response = await futureOnce(id);
    if (response.error != null) {
      throw SurrealError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }

    final result = response.result;
    if (result is! Iterable) {
      if (result is! DynamicResult) {
        return Iterable.empty();
      }
      return [result];
    }
    return result.map((result) {
      if (result is! DynamicResult) {
        throw SurrealError(code: -1, message: (result as ErrResult).detail);
      }
      return result;
    });
  }

  /// Applies [JSON Patch](https://jsonpatch.com/) changes to all records,
  /// or a specific record, in the database.
  ///
  /// <br>
  /// If [thing] is only table name then [patches] gets
  /// applied to all records in the table
  ///
  /// <br>
  /// If [thing] is a table name along with some id then,
  /// then [patches] gets applied only with the matching record with the id.
  Future<Iterable<Iterable<PatchResult>>> patch(
    String thing,
    Iterable<JsonPatch> patches,
  ) async {
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kModify,
      params: [
        thing,
        List.generate(
          patches.length,
          (index) => patches.elementAt(index).toJson(),
        ),
      ],
    );

    final response = await futureOnce(id);
    if (response.error != null) {
      throw SurrealError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }

    final result = response.result;
    if (result is! Iterable) {
      if (result is! Iterable) {
        return Iterable.empty();
      }
      return [result.cast<PatchResult>()];
    }
    return result.map((result) {
      if (result is! Iterable) {
        throw SurrealError(code: -1, message: (result as ErrResult).detail);
      }
      return result.cast<PatchResult>();
    });
  }

  /// Deletes all records in a table if [thing] is table name
  /// or a specific record, if [thing] is record id from the database.
  ///
  /// <br>
  /// Finally returns the deleted records
  Future<Iterable<DynamicResult>> delete(String thing) async {
    final id = _uuid.v4();
    _send(
      id: id,
      method: RPCMethodNames.kDelete,
      params: [thing],
    );

    final response = await futureOnce(id);
    if (response.error != null) {
      throw SurrealError(
        code: response.error!.code,
        message: response.error!.message,
      );
    }

    final result = response.result;
    if (result is! Iterable) {
      if (result is! DynamicResult) {
        return Iterable.empty();
      }
      return [result];
    }
    return result.map((result) {
      if (result is! DynamicResult) {
        throw SurrealError(code: -1, message: (result as ErrResult).detail);
      }
      return result;
    });
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
