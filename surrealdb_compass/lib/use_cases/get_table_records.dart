import '../data/repository.dart';

class GetTableRecordsUseCase {
  final Repository _repository;

  GetTableRecordsUseCase(this._repository);

  Future<Iterable<Map<String, dynamic>>> call(
    String tableName, {
    String? whereClause,
  }) async {
    final stringBuffer = StringBuffer(
      'SELECT * FROM type::table(\$table_name)',
    );
    if (whereClause != null) {
      stringBuffer.write(' WHERE $whereClause');
    }
    final result = await _repository.query(stringBuffer.toString(), {
      'table_name': tableName,
    });
    return result.first.result.cast<Map<String, dynamic>>();
  }
}
