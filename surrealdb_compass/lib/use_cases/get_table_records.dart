import '../data/repository.dart';
import 'utils.dart';

class GetTableRecordsUseCase {
  final Repository _repository;

  GetTableRecordsUseCase(this._repository);

  Future<Iterable<Map<String, dynamic>>> call(
    String tableName, {
    String? whereClause,
  }) async {
    final generatedQuery = Utils.generateQuery(
      tableName,
      whereClause: whereClause,
    );
    final result = await _repository.query(
      generatedQuery.first,
      generatedQuery.last,
    );
    return result.first.result.cast<Map<String, dynamic>>();
  }
}
