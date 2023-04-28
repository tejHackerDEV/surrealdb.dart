import 'package:freezed_annotation/freezed_annotation.dart';

part 'table.freezed.dart';

@unfreezed
class Table with _$Table {
  factory Table({
    required String name,
    required String query,

    /// Store the date at which the table is opened by the user
    /// Don't remove this because it ever servers as a unique
    /// identifier & used to define as a key for the [Widget].
    DateTime? openedAt,
  }) = _Table;
}
