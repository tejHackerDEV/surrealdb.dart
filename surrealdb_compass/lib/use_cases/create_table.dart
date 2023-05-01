import '../data/repository.dart';

class CreateTableUseCase {
  final Repository _repository;

  CreateTableUseCase(this._repository);

  Future<void> call(String tableName) async {
    await _repository.query('DEFINE TABLE $tableName SCHEMALESS');
  }
}
