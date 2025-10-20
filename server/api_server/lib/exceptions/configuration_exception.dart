/// Configuration exception thrown when required environment variables are missing or invalid.
///
/// This exception is thrown during application startup when critical configuration values cannot be loaded or
/// validated.
class ConfigurationException implements Exception {
  /// Creates a configuration exception with the specified message.
  ///
  /// The [message] should describe what configuration is missing or invalid.
  const ConfigurationException(this.message);

  /// Human-readable error message describing the configuration problem.
  final String message;

  @override
  String toString() => 'ConfigurationException: $message';
}
