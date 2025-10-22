part of 'firebase_auth_service.dart';

/// Exception thrown when required configuration is missing or invalid.
///
/// This exception indicates that the Firebase Auth service cannot function properly due to missing environment
/// variables or invalid configuration.
class ConfigurationException implements Exception {
  /// Creates a new configuration exception with the specified message.
  ///
  /// The [message] should describe the specific configuration problem, such as missing environment variables or invalid
  /// settings.
  const ConfigurationException(this.message);

  /// A human-readable description of the configuration problem.
  ///
  /// This message should guide developers toward resolving the configuration issue, such as setting required
  /// environment variables.
  final String message;

  @override
  String toString() => 'ConfigurationException: $message';
}
