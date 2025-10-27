import 'user_service_exception.dart';

/// Exception thrown when user document deletion fails.
///
/// This error indicates that the user document could not be deleted from the backend system, typically due to network
/// issues, server errors, or permission problems.
///
/// Recovery: User should retry the operation or contact support if the problem persists.
class UserDocumentDeletionException extends UserServiceException {
  /// Creates a user document deletion exception.
  ///
  /// Parameters:
  /// * [message] - Optional custom error message
  /// * [cause] - Optional underlying exception that caused this error
  /// * [context] - Additional debugging information
  const UserDocumentDeletionException({
    String message = 'Failed to delete user document. Please try again.',
    Object? cause,
    Map<String, dynamic> context = const <String, dynamic>{},
  }) : super(
         message,
         'USER_DOCUMENT_DELETION_FAILED',
         cause: cause,
         context: context,
       );
}
