class SurrealError extends Error {
  final int code;
  final String name;
  final Object? message;

  SurrealError({
    required this.code,
    this.name = 'SurrealError',
    this.message,
  });

  @override
  String toString() {
    return 'SurrealError{code: $code, name: $name, message: $message}';
  }
}

class AuthenticationError extends SurrealError {
  AuthenticationError({required int code, Object? message})
      : super(
          code: code,
          name: 'AuthenticationError',
          message: message,
        );
}
