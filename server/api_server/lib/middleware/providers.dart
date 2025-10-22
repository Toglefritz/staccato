/// Provider Middleware for Dependency Injection
///
/// This module sets up dependency injection for the Dart Frog application, registering services and repositories that
/// can be accessed throughout the request lifecycle. It follows the layered architecture pattern with proper dependency
/// ordering.
library providers;

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:staccato_api_server/services/firebase_auth.dart';

/// Middleware function that registers all application dependencies.
///
/// This middleware sets up the dependency injection container with all required services and repositories. Dependencies
/// are registered in order of their relationships, with lower-level dependencies first.
///
/// The middleware reads configuration from environment variables and creates service instances that can be accessed by
/// route handlers and other middleware using `context.read<ServiceType>()`.
///
/// Usage:
/// ```dart
/// Handler middleware(Handler handler) {
/// return handler.use(providers());
/// }
/// ```
///
/// Environment Variables Required:
/// * FIREBASE_PROJECT_ID - The Firebase project identifier
/// * FIREBASE_API_KEY - API key for Firebase REST API access
///
/// Returns a middleware function that provides dependency injection.
Middleware providers() {
  return (Handler handler) {
    return handler.use(_firebaseAuthServiceProvider()).use(_configurationProvider());
  };
}

/// Provider for Firebase Authentication Service.
///
/// This provider creates and registers a FirebaseAuthService instance that can be used by authentication middleware and
/// route handlers to verify Firebase ID tokens and manage user authentication.
///
/// The service is configured with the Firebase project ID from environment variables and includes proper error handling
/// for missing configuration.
Middleware _firebaseAuthServiceProvider() {
  return provider<FirebaseAuthService>((RequestContext context) {
    return FirebaseAuthService();
  });
}

/// Provider for application configuration.
///
/// This provider reads configuration values from environment variables and creates an AppConfig instance that can be
/// accessed throughout the application. It validates that all required configuration is present and provides meaningful
/// error messages for missing values.
Middleware _configurationProvider() {
  return provider<AppConfig>((RequestContext context) {
    return AppConfig.fromEnvironment();
  });
}

/// Application configuration container.
///
/// This class holds all configuration values needed by the application, reading them from environment variables with
/// proper validation and default values where appropriate.
class AppConfig {
  /// Creates a new application configuration with the specified values.
  ///
  /// All parameters are required and should be validated before creating an instance. Use [AppConfig.fromEnvironment]
  /// to create an instance from environment variables with proper validation.
  const AppConfig._({
    required this.port,
    required this.firebaseProjectId,
    required this.firebaseApiKey,
    required this.logLevel,
  });

  /// The port number on which the server should listen.
  ///
  /// This is typically set by the hosting environment (like Cloud Run) or defaults to 8080 for local development.
  final int port;

  /// The Firebase project ID for authentication and database access.
  ///
  /// This ID is used to construct Firebase API URLs and should match the project ID configured in your Firebase
  /// console.
  final String firebaseProjectId;

  /// The Firebase API key for REST API access.
  ///
  /// This key is required for making requests to Firebase authentication and other Firebase services via their REST
  /// APIs.
  final String firebaseApiKey;

  /// The logging level for the application.
  ///
  /// Valid values are 'DEBUG', 'INFO', 'WARNING', 'ERROR', and 'SEVERE'. Defaults to 'INFO' if not specified in
  /// environment variables.
  final String logLevel;

  /// Creates an application configuration from environment variables.
  ///
  /// This factory constructor reads all required configuration from environment variables and validates that required
  /// values are present. It provides sensible defaults for optional configuration values.
  ///
  /// Environment Variables:
  /// * PORT - Server port (optional, defaults to 8080)
  /// * FIREBASE_PROJECT_ID - Firebase project ID (required)
  /// * FIREBASE_API_KEY - Firebase API key (required)
  /// * LOG_LEVEL - Logging level (optional, defaults to 'INFO')
  ///
  /// Returns a new [AppConfig] instance with validated configuration.
  ///
  /// Throws [ConfigurationException] if required environment variables are missing or have invalid values.
  factory AppConfig.fromEnvironment() {
    // Parse and validate port number
    final String portString = Platform.environment['PORT'] ?? '8080';
    final int? port = int.tryParse(portString);
    if (port == null || port <= 0 || port > 65535) {
      throw ConfigurationException(
        'PORT must be a valid integer between 1 and 65535, got: $portString',
      );
    }

    // Validate Firebase project ID
    final String? firebaseProjectId = Platform.environment['FIREBASE_PROJECT_ID'];
    if (firebaseProjectId == null || firebaseProjectId.isEmpty) {
      throw ConfigurationException(
        'FIREBASE_PROJECT_ID environment variable is required',
      );
    }

    // Validate Firebase API key
    final String? firebaseApiKey = Platform.environment['FIREBASE_API_KEY'];
    if (firebaseApiKey == null || firebaseApiKey.isEmpty) {
      throw ConfigurationException(
        'FIREBASE_API_KEY environment variable is required',
      );
    }

    // Get log level with default
    final String logLevel = Platform.environment['LOG_LEVEL'] ?? 'INFO';
    final List<String> validLogLevels = ['DEBUG', 'INFO', 'WARNING', 'ERROR', 'SEVERE'];
    if (!validLogLevels.contains(logLevel.toUpperCase())) {
      throw ConfigurationException(
        'LOG_LEVEL must be one of: ${validLogLevels.join(', ')}, got: $logLevel',
      );
    }

    return AppConfig._(
      port: port,
      firebaseProjectId: firebaseProjectId,
      firebaseApiKey: firebaseApiKey,
      logLevel: logLevel.toUpperCase(),
    );
  }

  /// Converts this configuration to a JSON representation.
  ///
  /// This method is useful for logging configuration at startup (excluding sensitive values like API keys) and for
  /// debugging configuration issues.
  ///
  /// Sensitive values like API keys are masked in the output.
  Map<String, dynamic> toJson() {
    return {
      'port': port,
      'firebaseProjectId': firebaseProjectId,
      'firebaseApiKey': '***masked***',
      'logLevel': logLevel,
    };
  }

  @override
  String toString() => 'AppConfig(${toJson()})';
}

/// Exception thrown when application configuration is invalid or missing.
///
/// This exception indicates that required environment variables are not set or have invalid values that prevent the
/// application from starting properly.
class ConfigurationException implements Exception {
  /// Creates a new configuration exception with the specified message.
  ///
  /// The [message] should clearly describe what configuration is missing or invalid, and provide guidance on how to fix
  /// the issue.
  const ConfigurationException(this.message);

  /// A human-readable description of the configuration problem.
  ///
  /// This message should guide developers toward resolving the configuration issue, such as setting required
  /// environment variables or correcting invalid values.
  final String message;

  @override
  String toString() => 'ConfigurationException: $message';
}
