enum ResultStatus {
  err,
  ok,
  unknown,
}

class Result {
  final ResultStatus status;

  Result(this.status);

  factory Result.fromJson(Map<String, dynamic> json) {
    if (json['status'] == 'ERR') {
      return ErrResult.fromJson(json);
    }
    if (json['status'] == 'OK') {
      return OkResult.fromJson(json);
    }
    return UnknownResult.fromJson(json);
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

class UnknownResult extends Result {
  final dynamic value;
  UnknownResult._internal(super.status, this.value);

  factory UnknownResult.fromJson(Map<String, dynamic> json) {
    return UnknownResult._internal(
      ResultStatus.unknown,
      json,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is UnknownResult &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => super.hashCode ^ value.hashCode;

  @override
  String toString() {
    return 'UnknownResult{value: $value}';
  }
}
