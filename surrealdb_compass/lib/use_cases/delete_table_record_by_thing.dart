import '../data/repository.dart';

class DeleteTableRecordByThingUseCase {
  final Repository _repository;

  DeleteTableRecordByThingUseCase(this._repository);

  Future<void> call(String thing) async {
    await _repository.query('DELETE type::thing(\$thing)', {
      'thing': thing,
    });
  }
}
