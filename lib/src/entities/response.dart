import 'result.dart';

class Response {
  final String id;
  final Object? result;
  final Error? error;

  Response(this.id, this.result, this.error);

  factory Response.fromJson(Map<String, dynamic> json) {
    final resultJson = json['result'];
    final errorJson = json['error'];
    return Response(
      json['id'],
      (resultJson is! Iterable)
          ? resultJson
          : resultJson.map((json) => Result.fromJson(json)),
      errorJson == null ? null : Error.fromJson(errorJson),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Response &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          result == other.result &&
          error == other.error;

  @override
  int get hashCode => id.hashCode ^ result.hashCode ^ error.hashCode;

  @override
  String toString() {
    return 'Response{id: $id, result: $result, error: $error}';
  }
}

class Error {
  final int code;
  final String message;

  Error(this.code, this.message);

  factory Error.fromJson(Map<String, dynamic> json) {
    return Error(json['code'], json['message']);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Error &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => code.hashCode ^ message.hashCode;

  @override
  String toString() {
    return 'Error{code: $code, message: $message}';
  }
}
