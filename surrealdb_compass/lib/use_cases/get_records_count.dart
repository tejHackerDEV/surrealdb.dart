import '../data/repository.dart';

class GetRecordsCountUseCase {
  final Repository _repository;

  GetRecordsCountUseCase(this._repository);

  Future<int> call(String tableName) async {
    final result = await _repository.query(
        'SELECT * FROM count((SELECT * FROM type::table(\$table_name)))', {
      'table_name': tableName,
    });
    return result.first.result.first;
  }
}
