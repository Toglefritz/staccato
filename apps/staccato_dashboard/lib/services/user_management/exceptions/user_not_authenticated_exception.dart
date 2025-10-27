import 'user_service_exception.dart';

/// Exception thrown when the user is not authenticated.
///
/// This error indicates that the user must be signed in to perform the requested operation.
///
/// Recovery: User should sign in and retry the operation.
class UserNotAuthenticatedException extends UserServiceException {
  /// Creates a user not authenticated exception.
  ///
  /// Parameters:
  /// * [message] - Optional custom error message
  /// * [cause] - Optional underlying exception that caused this error
  /// * [context] - Additional debugging information
  const UserNotAuthenticatedException({
    String message = 'You must be signed in to perform this action.',
    Object? cause,
    Map<String, dynamic> context = const <String, dynamic>{},
  }) : super(
         message,
         'USER_NOT_AUTHENTICATED',
         cause: cause,
         context: context,
       );
}
