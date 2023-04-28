import 'package:surrealdb_dart/surrealdb_dart.dart';

class Repository {
  late Surreal _db;
  bool _isInitialized = false;

  Future<void> signIn({
    required String connectionUri,
    required String user,
    required String pass,
    required String ns,
    required String db,
  }) async {
    _db = Surreal(url: connectionUri);
    _db.connect();
    await _db.wait();
    await _db.signIn(SignInStrategy.credentials(user: user, pass: pass));
    await _db.use(ns: ns, db: db);
    _isInitialized = true;
  }

  Future<List<OkResult>> query(
    String sql, [
    Map<String, dynamic>? vars,
  ]) {
    if (!_isInitialized) {
      throw AssertionError('DB is not initialized to perform this action');
    }
    return _db.query(sql, vars);
  }
}