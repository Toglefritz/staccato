/// Exception thrown when a service operation fails.
///
/// This exception wraps errors that occur during business logic execution, external service communication, or other
/// service-level operations.
class ServiceException implements Exception {
  /// Creates a service exception with the specified message and optional cause.
  ///
  /// Parameters:
  /// * [message] - Human-readable error description
  /// * [cause] - Optional underlying exception that caused this error
  /// * [code] - Unique error code for programmatic handling
  const ServiceException(
    this.message, {
    this.cause,
    this.code = 'SERVICE_ERROR',
  });

  /// Human-readable error message describing the service failure.
  final String message;

  /// Optional underlying cause of this error.
  ///
  /// When this error wraps another exception, the original exception is preserved here for debugging and logging
  /// purposes.
  final Object? cause;

  /// Unique error code for programmatic error handling.
  final String code;

  @override
  String toString() =>
      'ServiceException($code): $message${cause != null ? ' (caused by: $cause)' : ''}';
}
