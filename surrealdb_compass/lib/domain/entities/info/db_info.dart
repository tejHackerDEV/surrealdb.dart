import 'package:freezed_annotation/freezed_annotation.dart';

part 'db_info.freezed.dart';
part 'db_info.g.dart';

@freezed
class DBInfo with _$DBInfo {
  const factory DBInfo({
    @JsonKey(name: 'tb') required Map<String, String> tables,
  }) = _DBInfo;

  factory DBInfo.fromJson(Map<String, Object?> json) => _$DBInfoFromJson(json);
}
