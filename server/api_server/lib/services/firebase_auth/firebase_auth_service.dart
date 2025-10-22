/// Firebase Authentication Service Library
///
/// This library provides Firebase ID token verification and user authentication services for the Dart Frog API server.
/// It includes the main service class and related models and exceptions for comprehensive authentication handling.
///
/// Key Components:
/// * [FirebaseAuthService] - Main service for token verification
/// * [FirebaseUser] - User information model
/// * [AuthenticationException] - Authentication failure exceptions
/// * [NetworkException] - Network communication failures
/// * [ConfigurationException] - Configuration-related errors
library firebase_auth_service;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'firebase_user.dart';
part 'authentication_exception.dart';
part 'network_exception.dart';
part 'configuration_exception.dart';

/// Service for verifying Firebase ID tokens and managing authentication.
///
/// This service communicates with Firebase's REST API to verify ID tokens and extract user information. It handles both
/// regular and anonymous authentication flows with proper error handling and emulator support.
class FirebaseAuthService {
  /// Creates a new Firebase Auth service instance.
  FirebaseAuthService({
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// HTTP client for making requests to Firebase APIs.
  final http.Client _httpClient;

  /// Base URL for Firebase Auth REST API endpoints.
  String get _baseUrl => 'https://identitytoolkit.googleapis.com/v1';

  /// Verifies a Firebase ID token and returns the decoded user information.
  ///
  /// This method validates the provided [idToken] by making a request to Firebase's token verification endpoint. If the
  /// token is valid, it returns a [FirebaseUser] object containing the user's information.
  ///
  /// Parameters:
  /// * [idToken] - The Firebase ID token to verify
  ///
  /// Returns a [Future<FirebaseUser>] containing the verified user information.
  ///
  /// Throws:
  /// * [AuthenticationException] if the token is invalid or expired
  /// * [NetworkException] if the Firebase API request fails
  /// * [FormatException] if the API response is malformed
  Future<FirebaseUser> verifyIdToken(String idToken) async {
    try {
      final Uri url = Uri.parse('$_baseUrl/accounts:lookup?key=$_getApiKey');

      final Map<String, dynamic> requestBody = {
        'idToken': idToken,
      };

      final http.Response response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> errorData = json.decode(response.body) as Map<String, dynamic>;
        // ignore: avoid_dynamic_calls
        final String errorMessage = errorData['error']?['message'] as String? ?? 'Token verification failed';
        throw AuthenticationException('Invalid ID token: $errorMessage');
      }

      final Map<String, dynamic> responseData = json.decode(response.body) as Map<String, dynamic>;
      final List<dynamic> users = responseData['users'] as List<dynamic>? ?? [];

      if (users.isEmpty) {
        throw AuthenticationException('No user found for the provided token');
      }

      final Map<String, dynamic> userData = users.first as Map<String, dynamic>;

      return FirebaseUser.fromJson(userData);
    } on http.ClientException catch (e) {
      throw NetworkException('Failed to connect to Firebase Auth API: ${e.message}');
    } on FormatException catch (e) {
      throw FormatException('Invalid response from Firebase Auth API: ${e.message}');
    }
  }

  /// Checks if the application is running in the Firebase emulator environment.
  ///
  /// This is used by middleware to determine whether to apply relaxed authentication rules for development and testing
  /// purposes.
  ///
  /// Returns true if the FUNCTIONS_EMULATOR environment variable is set to 'true'.
  bool get isEmulatorEnvironment {
    return Platform.environment['FUNCTIONS_EMULATOR'] == 'true';
  }

  /// Gets the Firebase API key from environment variables.
  ///
  /// The API key is required for making requests to Firebase REST APIs. It should be set in the FIREBASE_API_KEY
  /// environment variable.
  ///
  /// Throws [ConfigurationException] if the API key is not configured.
  String get _getApiKey {
    final String? apiKey = Platform.environment['FIREBASE_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw ConfigurationException('FIREBASE_API_KEY environment variable is required');
    }

    return apiKey;
  }
}
