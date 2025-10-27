import 'user_service_exception.dart';

/// Exception thrown when user document creation fails.
///
/// This error indicates that the user document could not be created in the backend system, typically due to network
/// issues, server errors, or data validation failures on the server side.
///
/// Recovery: User should retry the operation or check their network connection.
class UserDocumentCreationException extends UserServiceException {
  /// Creates a user document creation exception.
  ///
  /// Parameters:
  /// * [message] - Optional custom error message
  /// * [cause] - Optional underlying exception that caused this error
  /// * [context] - Additional debugging information
  const UserDocumentCreationException({
    String message = 'Failed to create user document. Please try again.',
    Object? cause,
    Map<String, dynamic> context = const <String, dynamic>{},
  }) : super(
          message,
          'USER_DOCUMENT_CREATION_FAILED',
          cause: cause,
          context: context,
        );
}
