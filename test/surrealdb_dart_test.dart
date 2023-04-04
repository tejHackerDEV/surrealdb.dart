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
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
    });
  });

  group('DB signup method test', () {
    test('Should able to signup to db', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signup(
        SignupAuthentication(ns: 'dummy', db: 'dummy', sc: 'dummy'),
      );
    });
  });

  group('DB signIn method test', () {
    test('Should able to signIn to db', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
    });
  });

  group('DB invalidate method test', () {
    test('Should invalidate the current session', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.invalidate();
    });
  });

  group('DB let method test', () {
    test('Should assign value as a parameter', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.let(key: 'name', value: {
        'first': 'tejHacker',
        'last': 'Dev',
      });
    });
  });

  group('DB query method test', () {
    test('Should able to create data into db', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results =
          await db.query('CREATE person; SELECT * FROM type::table(\$tb);', {
        'tb': 'person',
      });
      expect(results.length, 2);
    });
  });

  group('DB select method test', () {
    test('Should able to select all from db', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      await db.select('person');
    });

    test('Should return empty records from the database', () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.select('person:someRandomId');
      expect(results, isEmpty);
    });
  });

  final thing = 'person';
  final data = {
    'name': 'tejHackerDev',
    'settings': {
      'active': true,
      'marketing': true,
    },
  };

  group('DB create method test', () {
    test('Should able to create record with randomId & no data in the database',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.create(thing);
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        expect(element.value['id'], startsWith('$thing:'));
      }
    });

    test(
        'Should able to create record with specificId & no data in the database',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final someStaticId = DateTime.now().millisecondsSinceEpoch;
      final results = await db.create('$thing:$someStaticId');
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        expect(element.value['id'], '$thing:$someStaticId');
      }
    });

    test('Should able to create record with randomId & data in the database',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.create(thing, data);
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        final recordId = (element.value as Map).remove('id');
        expect(recordId, startsWith('$thing:'));
        expect(element.value, data);
      }
    });

    test('Should able to create record with specificId & data in the database',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final someStaticId = DateTime.now().millisecondsSinceEpoch;
      final results = await db.create('$thing:$someStaticId', data);
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        expect(element.value, {
          'id': '$thing:$someStaticId',
          ...data,
        });
      }
    });
  });

  group('DB update method test', () {
    String? recordId;

    test('Should able to update all records in the database with empty data',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.update(thing, {});
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        expect(element.value.length, 1);
        recordId = element.value['id'];
        expect(recordId, startsWith('$thing:'));
      }
    });

    test(
        'Should able to update a specific record in the database with some data',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.update(recordId!, data);
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        expect(recordId, startsWith('$thing:'));
        expect(element.value, {
          'id': recordId,
          ...data,
        });
      }
    });

    test('Should able to update all records in the database with some data',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.update(thing, data);
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        recordId = element.value['id'];
        expect(recordId, startsWith('$thing:'));
        expect(element.value, {
          'id': recordId,
          ...data,
        });
      }
    });

    test(
        'Should able to update a specific record in the database with empty data',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.update(thing, {});
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        expect(element.value.length, 1);
        recordId = element.value['id'];
        expect(recordId, startsWith('$thing:'));
      }
    });
  });

  group('DB merge method test', () {
    String? recordId;

    final dataWithCreatedAt = {
      'created_at': DateTime.now().toIso8601String(),
    };

    test(
        'Should able to merge `created_at` field to all records in the database ',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.merge(thing, dataWithCreatedAt);
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        recordId = element.value['id'];
        expect(recordId, startsWith('$thing:'));
        for (final entry in dataWithCreatedAt.entries) {
          expect(element.value.containsKey(entry.key), isTrue);
        }
      }
    });

    test(
        'Should able to merge `created_at` field to specific record in the database ',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.merge(recordId!, dataWithCreatedAt);
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        expect(element.value['id'], recordId);
        for (final entry in dataWithCreatedAt.entries) {
          expect(element.value.containsKey(entry.key), isTrue);
        }
      }
    });

    final complexData = {
      'updated_at': DateTime.now().toIso8601String(),
      'settings': {
        'active': false,
      }
    };

    test(
        'Should able to merge complex data fields to all records in the database',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.merge(thing, complexData);
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        recordId = element.value['id'];
        expect(recordId, startsWith('$thing:'));
        for (final entry in dataWithCreatedAt.entries) {
          expect(element.value.containsKey(entry.key), isTrue);
        }
      }
    });

    test(
        'Should able to merge complex data fields to specific record in the database ',
        () async {
      db = Surreal(url: dbUrl);
      db.connect();
      await db.wait();
      await db.signIn(
        SignInAuthentication.credentials(user: user, pass: password),
      );
      await db.use(ns: namespace, db: databaseName);
      final results = await db.merge(recordId!, complexData);
      expect(results, isNotEmpty);
      for (final element in results) {
        expect(element.value, isMap);
        expect(element.value['id'], recordId);
        for (final entry in dataWithCreatedAt.entries) {
          expect(element.value.containsKey(entry.key), isTrue);
        }
      }
    });
  });
}
