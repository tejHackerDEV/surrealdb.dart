import 'package:freezed_annotation/freezed_annotation.dart';

part 'table.freezed.dart';

@freezed
class Table with _$Table {
  const factory Table({
    required String name,
    required String query,
  }) = _Table;
}
