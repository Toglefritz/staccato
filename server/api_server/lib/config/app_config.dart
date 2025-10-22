/// Application configuration management for the Staccato API server.
///
/// This class handles loading and validating environment variables required for the application to run properly. It
/// provides type-safe access to configuration values and validates required settings on startup.
library;

import 'dart:io';

import 'package:staccato_api_server/exceptions/configuration_exception.dart';

/// Application configuration loaded from environment variables.
///
/// This class provides type-safe access to all configuration values required by the Staccato API server. It validates
/// required settings during construction and throws [ConfigurationException] for missing or invalid values.
class AppConfig {
  /// Creates an application configuration with the specified values.
  ///
  /// This constructor is private to enforce using `fromEnvironment` factory constructor for proper validation.
  const AppConfig._({
    required this.firebaseProjectId,
    required this.firebasePrivateKeyId,
    required this.firebasePrivateKey,
    required this.firebaseClientEmail,
    required this.firebaseClientId,
    required this.firebaseAuthUri,
    required this.firebaseTokenUri,
    required this.port,
    required this.logLevel,
    required this.environment,
    required this.useFirebaseEmulator,
    this.firestoreEmulatorHost,
    this.authEmulatorHost,
  });

  /// Firebase project ID for authentication and database access.
  final String firebaseProjectId;

  /// Firebase service account private key ID.
  final String firebasePrivateKeyId;

  /// Firebase service account private key in PEM format.
  final String firebasePrivateKey;

  /// Firebase service account client email address.
  final String firebaseClientEmail;

  /// Firebase service account client ID.
  final String firebaseClientId;

  /// Firebase OAuth2 authorization URI.
  final String firebaseAuthUri;

  /// Firebase OAuth2 token URI.
  final String firebaseTokenUri;

  /// HTTP server port number.
  final int port;

  /// Logging level (DEBUG, INFO, WARNING, ERROR).
  final String logLevel;

  /// Application environment (development, staging, production).
  final String environment;

  /// Whether to use Firebase emulator for local development.
  final bool useFirebaseEmulator;

  /// Firestore emulator host (only used when [useFirebaseEmulator] is true).
  final String? firestoreEmulatorHost;

  /// Authentication emulator host (only used when [useFirebaseEmulator] is true).
  final String? authEmulatorHost;

  /// Whether the application is running in development mode.
  bool get isDevelopment => environment == 'development';

  /// Whether the application is running in production mode.
  bool get isProduction => environment == 'production';

  /// Creates application configuration from environment variables.
  ///
  /// This factory constructor loads configuration from environment variables and validates that all required values are
  /// present and valid.
  ///
  /// Throws [ConfigurationException] if any required environment variable is missing or has an invalid value.
  ///
  /// Required environment variables:
  /// - FIREBASE_PROJECT_ID
  /// - FIREBASE_PRIVATE_KEY_ID
  /// - FIREBASE_PRIVATE_KEY
  /// - FIREBASE_CLIENT_EMAIL
  /// - FIREBASE_CLIENT_ID
  /// - FIREBASE_AUTH_URI
  /// - FIREBASE_TOKEN_URI
  ///
  /// Optional environment variables with defaults:
  /// - PORT (default: 8080)
  /// - LOG_LEVEL (default: INFO)
  /// - ENVIRONMENT (default: development)
  /// - USE_FIREBASE_EMULATOR (default: false)
  /// - FIRESTORE_EMULATOR_HOST (required if USE_FIREBASE_EMULATOR is true)
  /// - AUTH_EMULATOR_HOST (required if USE_FIREBASE_EMULATOR is true)
  factory AppConfig.fromEnvironment() {
    // Load required Firebase configuration
    final String? firebaseProjectId = Platform.environment['FIREBASE_PROJECT_ID'];
    if (firebaseProjectId == null || firebaseProjectId.isEmpty) {
      throw const ConfigurationException(
        'FIREBASE_PROJECT_ID environment variable is required',
      );
    }

    final String? firebasePrivateKeyId = Platform.environment['FIREBASE_PRIVATE_KEY_ID'];
    if (firebasePrivateKeyId == null || firebasePrivateKeyId.isEmpty) {
      throw const ConfigurationException(
        'FIREBASE_PRIVATE_KEY_ID environment variable is required',
      );
    }

    final String? firebasePrivateKey = Platform.environment['FIREBASE_PRIVATE_KEY'];
    if (firebasePrivateKey == null || firebasePrivateKey.isEmpty) {
      throw const ConfigurationException(
        'FIREBASE_PRIVATE_KEY environment variable is required',
      );
    }

    final String? firebaseClientEmail = Platform.environment['FIREBASE_CLIENT_EMAIL'];
    if (firebaseClientEmail == null || firebaseClientEmail.isEmpty) {
      throw const ConfigurationException(
        'FIREBASE_CLIENT_EMAIL environment variable is required',
      );
    }

    final String? firebaseClientId = Platform.environment['FIREBASE_CLIENT_ID'];
    if (firebaseClientId == null || firebaseClientId.isEmpty) {
      throw const ConfigurationException(
        'FIREBASE_CLIENT_ID environment variable is required',
      );
    }

    final String? firebaseAuthUri = Platform.environment['FIREBASE_AUTH_URI'];
    if (firebaseAuthUri == null || firebaseAuthUri.isEmpty) {
      throw const ConfigurationException(
        'FIREBASE_AUTH_URI environment variable is required',
      );
    }

    final String? firebaseTokenUri = Platform.environment['FIREBASE_TOKEN_URI'];
    if (firebaseTokenUri == null || firebaseTokenUri.isEmpty) {
      throw const ConfigurationException(
        'FIREBASE_TOKEN_URI environment variable is required',
      );
    }

    // Load server configuration with defaults
    final String portString = Platform.environment['PORT'] ?? '8080';
    final int? port = int.tryParse(portString);
    if (port == null || port <= 0 || port > 65535) {
      throw ConfigurationException(
        'PORT must be a valid integer between 1 and 65535, got: $portString',
      );
    }

    final String logLevel = Platform.environment['LOG_LEVEL'] ?? 'INFO';
    final List<String> validLogLevels = ['DEBUG', 'INFO', 'WARNING', 'ERROR'];
    if (!validLogLevels.contains(logLevel.toUpperCase())) {
      throw ConfigurationException(
        'LOG_LEVEL must be one of ${validLogLevels.join(', ')}, got: $logLevel',
      );
    }

    final String environment = Platform.environment['ENVIRONMENT'] ?? 'development';
    final List<String> validEnvironments = [
      'development',
      'staging',
      'production',
    ];
    if (!validEnvironments.contains(environment)) {
      throw ConfigurationException(
        'ENVIRONMENT must be one of ${validEnvironments.join(', ')}, got: $environment',
      );
    }

    // Load emulator configuration
    final String useEmulatorString = Platform.environment['USE_FIREBASE_EMULATOR'] ?? 'false';
    final bool useFirebaseEmulator = useEmulatorString.toLowerCase() == 'true';

    String? firestoreEmulatorHost;
    String? authEmulatorHost;

    if (useFirebaseEmulator) {
      firestoreEmulatorHost = Platform.environment['FIRESTORE_EMULATOR_HOST'];
      if (firestoreEmulatorHost == null || firestoreEmulatorHost.isEmpty) {
        throw const ConfigurationException(
          'FIRESTORE_EMULATOR_HOST is required when USE_FIREBASE_EMULATOR is true',
        );
      }

      authEmulatorHost = Platform.environment['AUTH_EMULATOR_HOST'];
      if (authEmulatorHost == null || authEmulatorHost.isEmpty) {
        throw const ConfigurationException(
          'AUTH_EMULATOR_HOST is required when USE_FIREBASE_EMULATOR is true',
        );
      }
    }

    return AppConfig._(
      firebaseProjectId: firebaseProjectId,
      firebasePrivateKeyId: firebasePrivateKeyId,
      firebasePrivateKey: firebasePrivateKey,
      firebaseClientEmail: firebaseClientEmail,
      firebaseClientId: firebaseClientId,
      firebaseAuthUri: firebaseAuthUri,
      firebaseTokenUri: firebaseTokenUri,
      port: port,
      logLevel: logLevel.toUpperCase(),
      environment: environment,
      useFirebaseEmulator: useFirebaseEmulator,
      firestoreEmulatorHost: firestoreEmulatorHost,
      authEmulatorHost: authEmulatorHost,
    );
  }
}
