class Authentication {
  final String? user;
  final String? pass;
  final String? ns;
  final String? db;
  final String? sc;
  final Map<String, dynamic>? extras;

  Authentication.credentials({
    required String this.user,
    required String this.pass,
  })  : ns = null,
        db = null,
        sc = null,
        extras = null;

  Authentication.namespace({
    required String this.user,
    required String this.pass,
    required String this.ns,
  })  : db = null,
        sc = null,
        extras = null;

  Authentication.database({
    required String this.user,
    required String this.pass,
    required String this.ns,
    required String this.db,
  })  : sc = null,
        extras = null;

  Authentication.scope({
    required String this.ns,
    required String this.db,
    required String this.sc,
    this.extras,
  })  : user = null,
        pass = null;

  Map<String, dynamic> toJson() => {
        if (user != null) 'user': user,
        if (pass != null) 'pass': pass,
        if (ns != null) 'NS': ns,
        if (db != null) 'DB': db,
        if (sc != null) ...{
          'SC': sc,
          ...?extras,
        }
      };
}
