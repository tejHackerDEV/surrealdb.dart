import '../data/repository.dart';
import '../domain/entities/info/db_info.dart';

class GetDBInfoUseCase {
  final Repository _repository;

  GetDBInfoUseCase(this._repository);
  Future<DBInfo> call() async {
    final result = await _repository.query('INFO FOR DB');
    return DBInfo.fromJson(result.first.result.first);
  }
}
