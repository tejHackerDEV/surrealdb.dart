abstract class SurrealError extends Error {
  final int code;
  final String name;
  final Object? message;

  SurrealError(this.code, this.name, this.message);
}

class AuthenticationError extends SurrealError {
  AuthenticationError({required int code, Object? message})
      : super(
          code,
          'AuthenticationError',
          message,
        );
}
