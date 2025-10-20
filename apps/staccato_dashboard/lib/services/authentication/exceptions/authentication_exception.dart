/// An exception that is thrown when an authentication error occurs during a REST API request.
///
/// This exception is typically thrown when a request to the backend results in a `401 Unauthorized` response,
/// indicating that the user is either not authenticated or their authentication token has expired.
///
/// Callers can catch this exception and implement custom logic, such as redirecting the user to the login screen or
/// prompting them to refresh their authentication token.
class AuthenticationException implements Exception {
  /// A message describing the authentication error.
  final String message;

  /// Creates an [AuthenticationException] with an optional [message].
  ///
  /// The [message] provides additional details about the authentication failure.
  AuthenticationException([this.message = 'Authentication failed']);

  @override
  String toString() => 'AuthenticationException: $message';
}
