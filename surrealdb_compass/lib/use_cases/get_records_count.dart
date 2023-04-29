import '../data/repository.dart';
import 'utils.dart';

class GetRecordsCountUseCase {
  final Repository _repository;

  GetRecordsCountUseCase(this._repository);

  Future<int> call(
    String tableName, {
    String? whereClause,
  }) async {
    final generatedQuery = Utils.generateQuery(
      tableName,
      whereClause: whereClause,
    );
    final result = await _repository.query(
      'SELECT * FROM count((${generatedQuery.first}))',
      generatedQuery.last,
    );
    return result.first.result.first;
  }
}
