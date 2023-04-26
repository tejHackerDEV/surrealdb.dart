import '../data/repository.dart';

class SignInUseCase {
  final Repository _repository;

  SignInUseCase(this._repository);

  Future<void> call({
    required String connectionUri,
    required String user,
    required String pass,
    required String ns,
    required String db,
  }) =>
      _repository.signIn(
        connectionUri: connectionUri,
        user: user,
        pass: pass,
        ns: ns,
        db: db,
      );
}
