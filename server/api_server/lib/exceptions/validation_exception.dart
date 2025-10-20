/// Exception thrown when user input fails validation requirements.
///
/// This exception indicates that the user's request cannot be processed due to missing, invalid, or malformed input
/// data. The error message should guide the user toward providing correct input.
///
/// Common scenarios:
/// * Missing required fields in user requests
/// * Invalid format for user input (e.g., malformed email)
/// * Input that violates business rules or constraints
///
/// Recovery: User should correct the input and retry the operation.
class ValidationException implements Exception {
  /// Creates a validation exception with the specified message and optional field information.
  ///
  /// Parameters:
  /// * [message] - Human-readable error description
  /// * [field] - Name of the field that failed validation (optional)
  /// * [code] - Unique error code for programmatic handling (optional)
  const ValidationException(
    this.message, {
    this.field,
    this.code = 'VALIDATION_FAILED',
  });

  /// Human-readable error message suitable for display to users.
  ///
  /// This message should be clear, actionable, and free of technical jargon. It should guide users toward resolution
  /// when possible.
  final String message;

  /// The specific field or input that failed validation.
  ///
  /// Used by UI components to highlight problematic fields and provide targeted error feedback to users.
  final String? field;

  /// Unique error code for programmatic error handling.
  ///
  /// Format: "VALIDATION_CATEGORY_SPECIFIC" (e.g., "VALIDATION_MISSING_FIELD") Used by error tracking systems and
  /// automated recovery logic.
  final String code;

  /// Creates a validation exception for a missing required field.
  ///
  /// Parameters:
  /// * [field] - Name of the missing field
  ///
  /// Returns [ValidationException] with appropriate message and code.
  factory ValidationException.missingField(String field) {
    return ValidationException(
      'The $field field is required but was not provided.',
      field: field,
      code: 'VALIDATION_MISSING_FIELD',
    );
  }

  /// Creates a validation exception for an invalid field format.
  ///
  /// Parameters:
  /// * [field] - Name of the field with invalid format
  /// * [expectedFormat] - Description of the expected format
  ///
  /// Returns [ValidationException] with format-specific message.
  factory ValidationException.invalidFormat(
    String field,
    String expectedFormat,
  ) {
    return ValidationException(
      'The $field field must be in $expectedFormat format.',
      field: field,
      code: 'VALIDATION_INVALID_FORMAT',
    );
  }

  @override
  String toString() => 'ValidationException($code): $message';
}
