import 'user_service_exception.dart';

/// Exception thrown when network communication fails.
///
/// This error indicates that the service could not communicate with the backend API, typically due to network
/// connectivity issues, server downtime, or timeout errors.
///
/// Recovery: User should check their internet connection and retry the operation.
class UserServiceNetworkException extends UserServiceException {
  /// Creates a network exception.
  ///
  /// Parameters:
  /// * [message] - Optional custom error message
  /// * [cause] - Optional underlying exception that caused this error
  /// * [context] - Additional debugging information
  const UserServiceNetworkException({
    String message =
        'Network error occurred. Please check your connection and try again.',
    Object? cause,
    Map<String, dynamic> context = const <String, dynamic>{},
  }) : super(
         message,
         'USER_SERVICE_NETWORK_ERROR',
         cause: cause,
         context: context,
       );
}
