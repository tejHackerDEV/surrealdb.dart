import '../../surrealdb_dart.dart';

enum ResultStatus {
  err,
  ok,
  dynamic,
  patch,
}

class Result {
  final ResultStatus status;

  Result(this.status);

  factory Result.fromJson(
    Map<String, dynamic> json, {
    bool isPatchResult = false,
  }) {
    if (isPatchResult) {
      return PatchResult.fromJson(json);
    }
    if (json['status'] == 'ERR') {
      return ErrResult.fromJson(json);
    }
    if (json['status'] == 'OK') {
      return OkResult.fromJson(json);
    }
    return DynamicResult.fromJson(json);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Result &&
          runtimeType == other.runtimeType &&
          status == other.status;

  @override
  int get hashCode => status.hashCode;

  @override
  String toString() {
    return 'Result{status: $status}';
  }
}

class OkResult extends Result {
  final String time;
  final List<dynamic> result;

  OkResult._internal(super.status, this.time, this.result);

  factory OkResult.fromJson(Map<String, dynamic> json) {
    return OkResult._internal(
      ResultStatus.ok,
      json['time'],
      json['result'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is OkResult &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          result == other.result;

  @override
  int get hashCode => super.hashCode ^ time.hashCode ^ result.hashCode;

  @override
  String toString() {
    return 'OkResult{time: $time, result: $result}';
  }
}

class ErrResult extends Result {
  final String time;
  final String detail;

  ErrResult._internal(super.status, this.time, this.detail);

  factory ErrResult.fromJson(Map<String, dynamic> json) {
    return ErrResult._internal(
      ResultStatus.err,
      json['time'],
      json['detail'],
    );
  }
}

class DynamicResult extends Result {
  final dynamic value;
  DynamicResult._internal(super.status, this.value);

  factory DynamicResult.fromJson(Map<String, dynamic> json) {
    return DynamicResult._internal(
      ResultStatus.dynamic,
      json,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is DynamicResult &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => super.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'UnknownResult{value: $value}';
  }
}

class PatchResult extends Result {
  final PatchOp op;
  final String path;
  final String? value;

  PatchResult._internal(super.status, this.op, this.path, this.value);

  factory PatchResult.fromJson(Map<String, dynamic> json) {
    return PatchResult._internal(
      ResultStatus.patch,
      PatchOp.values.firstWhere(
        (patchOp) => patchOp.name.toLowerCase() == json['op'].toLowerCase(),
      ),
      json['path'],
      json['value']?.toString(),
    );
  }

  @override
  String toString() {
    return 'PatchResult{op: $op, path: $path, value: $value}';
  }
}
