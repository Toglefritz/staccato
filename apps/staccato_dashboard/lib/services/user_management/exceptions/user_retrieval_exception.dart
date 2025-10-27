import 'user_service_exception.dart';

/// Exception thrown when user retrieval fails.
///
/// This error indicates that user data could not be retrieved from the backend system, typically due to network
/// issues, server errors, or the user not existing.
///
/// Recovery: User should retry the operation or verify that the user exists.
class UserRetrievalException extends UserServiceException {
  /// Creates a user retrieval exception.
  ///
  /// Parameters:
  /// * [message] - Optional custom error message
  /// * [cause] - Optional underlying exception that caused this error
  /// * [context] - Additional debugging information
  const UserRetrievalException({
    String message = 'Failed to retrieve user data. Please try again.',
    Object? cause,
    Map<String, dynamic> context = const <String, dynamic>{},
  }) : super(
         message,
         'USER_RETRIEVAL_FAILED',
         cause: cause,
         context: context,
       );
}
