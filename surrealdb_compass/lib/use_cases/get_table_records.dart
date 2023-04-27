import '../data/repository.dart';

class GetTableRecordsUseCase {
  final Repository _repository;

  GetTableRecordsUseCase(this._repository);

  Future<Iterable<Map<String, dynamic>>> call(String tableName) async {
    final result =
        await _repository.query('SELECT * FROM type::table(\$table_name)', {
      'table_name': tableName,
    });
    return result.first.result.cast<Map<String, dynamic>>();
  }
}
