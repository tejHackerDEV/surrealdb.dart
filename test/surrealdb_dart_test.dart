import 'package:surrealdb_dart/surrealdb_dart.dart';
import 'package:test/test.dart';

void main() {
  late Surreal db;
  final dbUrl = 'http://127.0.0.1:8000/rpc';
  final user = 'root';
  final password = 'root';
  final namespace = 'test';
  final databaseName = 'test';
  final pingerDuration = Duration(seconds: 30);

  // Close the db connection everytime a test has completed
  tearDown(() => db.close());

  group('DB initiation tests', () {
    test('DB should be initialized with default pinger', () {
      db = Surreal(url: dbUrl);
      expect(db.url, dbUrl);
      expect(db.pinger.duration, pingerDuration);
    });

    test('CustomDB should be initialized with custom pinger', () {
      String customDBUrl = 'http://127.0.0.1:8001/rpc';
      final customerPingerDuration = Duration(minutes: 1);
      db = Surreal(
        url: customDBUrl,
        pinger: Pinger(customerPingerDuration),
      );
      expect(db.url, customDBUrl);
      expect(db.pinger.duration, customerPingerDuration);
    });

    test('DB should not be initialized with custom pinger', () {
      final customerPingerDuration = Duration(minutes: 1);
      db = Surreal(
        url: dbUrl,
        pinger: Pinger(customerPingerDuration),
      );
      expect(db.url, dbUrl);
      expect(db.pinger.duration, isNot(customerPingerDuration));
    });
  });

  group('DB connection test', () {
    test('Should able to connect to db', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
    });
  });

  group('DB use method test', () {
    test('Should able to switch the namespace & database', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(user: user, pass: password);
      await db.use(ns: namespace, db: databaseName);
    });
  });

  group('DB signup method test', () {
    test('Should able to signup to db', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signup(
        Authentication.credentials(user: 'dummy', pass: 'dummy'),
      );
    });
  });

  group('DB signIn method test', () {
    test('Should able to signIn to db', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(user: user, pass: password);
    });
  });
}
