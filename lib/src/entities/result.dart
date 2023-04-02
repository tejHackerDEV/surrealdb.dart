enum ResultStatus {
  err,
  ok,
}

class Result {
  final String time;
  final ResultStatus status;

  Result(this.time, this.status);

  factory Result.fromJson(Map<String, dynamic> json) {
    if (json['status'] == 'ERR') {
      return ErrResult.fromJson(json);
    }
    return OkResult.fromJson(json);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Result &&
          runtimeType == other.runtimeType &&
          time == other.time &&
          status == other.status;

  @override
  int get hashCode => time.hashCode ^ status.hashCode;

  @override
  String toString() {
    return 'Result{time: $time, status: $status}';
  }
}

class OkResult extends Result {
  final List<dynamic> result;

  OkResult._internal(super.time, super.status, this.result);

  factory OkResult.fromJson(Map<String, dynamic> json) {
    return OkResult._internal(
      json['time'],
      ResultStatus.ok,
      json['result'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is OkResult &&
          runtimeType == other.runtimeType &&
          result == other.result;

  @override
  int get hashCode => super.hashCode ^ result.hashCode;

  @override
  String toString() {
    return 'OkResult{result: $result}';
  }
}

class ErrResult extends Result {
  final String detail;

  ErrResult._internal(super.time, super.status, this.detail);

  factory ErrResult.fromJson(Map<String, dynamic> json) {
    return ErrResult._internal(
      json['time'],
      ResultStatus.err,
      json['detail'],
    );
  }
}
