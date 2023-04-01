import 'classes/pinger.dart';

class Surreal {
  static final Map<String, Surreal> _instances = {};

  /// The url of the database endpoint to connect to
  final String _url;

  /// An interval pinger used to keep
  /// connection alive through
  /// load-balancers and proxies.
  final Pinger _pinger;

  Surreal._internal(
    this._url,
    this._pinger,
  );

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

  String get url => _url;

  Pinger get pinger => _pinger;
}
