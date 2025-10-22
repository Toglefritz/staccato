part of 'firebase_auth_service.dart';

/// Exception thrown when network communication with Firebase fails.
///
/// This exception indicates that the request to Firebase's authentication API could not be completed due to network
/// issues, timeouts, or service unavailability.
class NetworkException implements Exception {
  /// Creates a new network exception with the specified message.
  ///
  /// The [message] should describe the specific network failure that occurred, such as connection timeouts or DNS
  /// resolution failures.
  const NetworkException(this.message);

  /// A human-readable description of the network failure.
  ///
  /// This message can be used for logging and error reporting to help diagnose connectivity issues with Firebase
  /// services.
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}
