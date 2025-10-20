/// Exception thrown when a resource conflict occurs.
///
/// This exception is thrown when attempting to create or modify a resource that would violate uniqueness constraints or
/// other business rules that prevent the operation.
///
/// Common scenarios:
/// * Attempting to create a user with an ID that already exists
/// * Trying to assign a role that conflicts with existing assignments
/// * Violating unique constraints in the database
class ConflictException implements Exception {
  /// Creates a conflict exception with the specified message.
  ///
  /// Parameters:
  /// * [message] - Human-readable error description
  /// * [code] - Unique error code for programmatic handling
  const ConflictException(
    this.message, {
    this.code = 'RESOURCE_CONFLICT',
  });

  /// Human-readable error message describing the conflict.
  final String message;

  /// Unique error code for programmatic error handling.
  final String code;

  @override
  String toString() => 'ConflictException($code): $message';
}
