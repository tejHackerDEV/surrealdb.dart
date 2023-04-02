abstract class Authentication {
  final String? ns;
  final String? db;
  final String? sc;
  final Map<String, dynamic>? extras;

  Authentication({
    required this.ns,
    required this.db,
    required this.sc,
    required this.extras,
  });

  Map<String, dynamic> toJson() => {
        if (ns != null) 'NS': ns,
        if (db != null) 'DB': db,
        if (sc != null) ...{
          'SC': sc,
          ...?extras,
        }
      };
}

class SignupAuthentication extends Authentication {
  SignupAuthentication({
    required super.ns,
    required super.db,
    required super.sc,
    super.extras,
  });
}

class SignInAuthentication extends Authentication {
  final String? user;
  final String? pass;

  SignInAuthentication.credentials({
    required String this.user,
    required String this.pass,
  }) : super(ns: null, db: null, sc: null, extras: null);

  SignInAuthentication.namespace({
    required String this.user,
    required String this.pass,
    required String ns,
  }) : super(ns: ns, db: null, sc: null, extras: null);

  SignInAuthentication.database({
    required String this.user,
    required String this.pass,
    required String ns,
    required String db,
  }) : super(ns: ns, db: db, sc: null, extras: null);

  SignInAuthentication.scope({
    required String ns,
    required String db,
    required String sc,
    Map<String, dynamic>? extras,
  })  : user = null,
        pass = null,
        super(ns: ns, db: db, sc: sc, extras: extras);

  @override
  Map<String, dynamic> toJson() => {
        if (user != null) 'user': user,
        if (pass != null) 'pass': pass,
        ...super.toJson(),
      };
}
