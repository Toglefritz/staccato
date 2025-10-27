/// Base exception class for user management service errors.
///
/// This class provides a foundation for all user service-related exceptions, offering structured error handling with
/// consistent error codes, user-friendly messages, and debugging information.
abstract class UserServiceException implements Exception {
  /// Human-readable error message suitable for display to users.
  ///
  /// This message should be clear, actionable, and free of technical jargon. It should guide users toward resolution
  /// when possible.
  final String message;

  /// Unique error code for programmatic error handling.
  ///
  /// Format: "USER_CATEGORY_SPECIFIC" (e.g., "USER_VALIDATION_MISSING_NAME")
  /// Used by error tracking systems and automated recovery logic.
  final String code;

  /// Optional underlying cause of this error.
  ///
  /// When this error wraps another exception, the original exception is preserved here for debugging and logging
  /// purposes.
  final Object? cause;

  /// Additional context information for debugging.
  ///
  /// May include request IDs, user IDs, timestamps, or other relevant data that helps with troubleshooting and error
  /// analysis.
  final Map<String, dynamic> context;

  /// Creates a new user service exception with required information.
  ///
  /// Parameters:
  /// * [message] - User-friendly error description
  /// * [code] - Unique error identifier for programmatic handling
  /// * [cause] - Optional underlying exception that caused this error
  /// * [context] - Additional debugging information
  const UserServiceException(
    this.message,
    this.code, {
    this.cause,
    this.context = const <String, dynamic>{},
  });

  @override
  String toString() => 'UserServiceException($code): $message';
}
