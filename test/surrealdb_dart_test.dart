import 'package:surrealdb_dart/src/classes/pinger.dart';
import 'package:surrealdb_dart/src/surreal.dart';
import 'package:test/test.dart';

void main() {
  String dbUrl = 'http://127.0.0.1:8000/rpc';
  final pingerDuration = Duration(seconds: 30);
  group('DB initiation tests', () {
    test('DB should be initialized with default pinger', () {
      final db = Surreal(url: dbUrl);
      expect(db.url, dbUrl);
      expect(db.pinger.duration, pingerDuration);
    });

    test('CustomDB should be initialized with custom pinger', () {
      String customDBUrl = 'http://127.0.0.1:8001/rpc';
      final customerPingerDuration = Duration(minutes: 1);
      final db = Surreal(
        url: customDBUrl,
        pinger: Pinger(customerPingerDuration),
      );
      expect(db.url, customDBUrl);
      expect(db.pinger.duration, customerPingerDuration);
    });

    test('DB should not be initialized with custom pinger', () {
      final customerPingerDuration = Duration(minutes: 1);
      final db = Surreal(
        url: dbUrl,
        pinger: Pinger(customerPingerDuration),
      );
      expect(db.url, dbUrl);
      expect(db.pinger.duration, isNot(customerPingerDuration));
    });
  });

  group('DB connection test', () {
    test('Should able to connect to db', () async {
      final db = Surreal(url: dbUrl);
      db.connect();
    });

    test('Should able to signIn to db', () async {
      final db = Surreal(url: dbUrl);
      db.connect();
      await db.signIn(user: 'user', pass: 'user');
    });
  });
}
