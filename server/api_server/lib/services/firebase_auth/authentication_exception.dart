part of 'firebase_auth_service.dart';

/// Exception thrown when Firebase authentication fails.
///
/// This exception is thrown when ID token verification fails due to invalid tokens, expired tokens, or other
/// authentication-related errors.
class AuthenticationException implements Exception {
  /// Creates a new authentication exception with the specified message.
  ///
  /// The [message] should describe the specific authentication failure that occurred, such as "Invalid ID token" or
  /// "Token expired".
  const AuthenticationException(this.message);

  /// A human-readable description of the authentication failure.
  ///
  /// This message can be logged for debugging purposes but should not be directly exposed to end users as it may
  /// contain sensitive information.
  final String message;

  @override
  String toString() => 'AuthenticationException: $message';
}
