import 'dart:convert';

import '../data/repository.dart';

class UpdateRecordContentUseCase {
  final Repository _repository;

  UpdateRecordContentUseCase(this._repository);

  Future<Map<String, dynamic>> call(
    String thing,
    Map<String, dynamic> content,
  ) async {
    final result = await _repository.query(
      'UPDATE type::thing(\$thing) CONTENT ${jsonEncode(content)}',
      {
        'thing': thing,
      },
    );
    return result.first.result.first;
  }
}
