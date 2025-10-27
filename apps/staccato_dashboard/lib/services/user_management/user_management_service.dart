/// Service class for managing user accounts and documents in the Staccato system.
///
/// This service provides methods for creating, retrieving, and deleting user documents through the backend API. It
/// handles authentication, error handling, and provides a clean interface for user management operations.
///
/// The service is designed to work with the Staccato API server and handles all HTTP communication, JSON
/// serialization, and error handling internally.
library;

import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../firebase/dev_machine_ip.dart';
import 'exceptions/user_document_creation_exception.dart';
import 'exceptions/user_document_deletion_exception.dart';
import 'exceptions/user_not_authenticated_exception.dart';
import 'exceptions/user_retrieval_exception.dart';
import 'exceptions/user_service_exception.dart';
import 'exceptions/user_service_network_exception.dart';
import 'models/user.dart';
import 'models/user_create_request.dart';

/// Service class for managing user accounts and documents in the Staccato system.
///
/// This service provides a comprehensive interface for user management operations including creating user documents,
/// retrieving user data, and deleting user accounts. It handles all communication with the backend API and provides
/// proper error handling and authentication.
///
/// All methods in this service require the user to be authenticated with Firebase Auth. The service automatically
/// includes the user's ID token in API requests for authentication and authorization.
class UserManagementService {
  /// Creates a new instance of the UserManagementService.
  ///
  /// The service automatically configures itself based on the current environment (debug vs production) and sets up
  /// the appropriate API endpoints.
  UserManagementService();

  /// The host for the API server base URL.
  static final String _apiHost = kDebugMode
      ? devMachineIP
      : ''; // TODO(Toglefritz): update prod host

  /// The base URL for all API endpoints used by this service.
  static String get _baseUrl => kDebugMode
      ? 'http://$_apiHost:5001/brine-3b212/us-central1'
      : ''; // TODO(Toglefritz): update prod endpoint

  /// HTTP client used for API requests.
  ///
  /// This client is configured with appropriate timeouts and headers for communicating with the Staccato API server.
  static final http.Client _httpClient = http.Client();

  /// Default timeout duration for HTTP requests.
  ///
  /// Requests that take longer than this duration will be cancelled and result in a timeout error.
  static const Duration _requestTimeout = Duration(seconds: 30);

  /// Creates a user document in the backend system.
  ///
  /// This method creates a new user document in the Firestore database through the backend API. It requires the user
  /// to be authenticated with Firebase Auth and automatically includes the user's ID token for authentication.
  ///
  /// The method handles the complete user creation workflow including validation, API communication, and error
  /// handling.
  ///
  /// Parameters:
  /// * [request] - User creation request containing all required user data
  ///
  /// Returns a [Future<StaccatoUser>] that completes with the created user data when successful.
  ///
  /// Throws:
  /// * [UserNotAuthenticatedException] - When the user is not signed in
  /// * [UserDocumentCreationException] - When user document creation fails
  /// * [UserServiceNetworkException] - When network communication fails
  Future<StaccatoUser> createUserDocument(UserCreateRequest request) async {
    try {
      // Get the current authenticated user
      final firebase_auth.User? currentUser =
          firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw const UserNotAuthenticatedException();
      }

      // Get the user's ID token for authentication
      final String? idToken = await currentUser.getIdToken();
      if (idToken == null) {
        throw const UserNotAuthenticatedException(
          message: 'Failed to get authentication token. Please sign in again.',
        );
      }

      // Prepare the API request
      final Uri url = Uri.parse('$_baseUrl/api/users');
      final Map<String, String> headers = <String, String>{
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      };

      debugPrint('Creating user document via API: $url');

      // Make the HTTP request
      final http.Response response = await _httpClient
          .post(
            url,
            headers: headers,
            body: jsonEncode(request.toJson()),
          )
          .timeout(_requestTimeout);

      debugPrint('User creation API response: ${response.statusCode}');

      // Handle the response
      if (response.statusCode == HttpStatus.created) {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> userData =
            responseData['data'] as Map<String, dynamic>;

        final StaccatoUser user = StaccatoUser.fromJson(userData);
        debugPrint('User document created successfully: ${user.id}');

        return user;
      } else {
        // Parse error response if possible
        String errorMessage = 'Failed to create user document';
        try {
          final Map<String, dynamic> errorData =
              jsonDecode(response.body) as Map<String, dynamic>;
          final Map<String, dynamic> error =
              errorData['error'] as Map<String, dynamic>;
          errorMessage = error['message'] as String? ?? errorMessage;
        } catch (e) {
          debugPrint('Failed to parse error response: $e');
        }

        throw UserDocumentCreationException(
          message: errorMessage,
          context: <String, dynamic>{
            'statusCode': response.statusCode,
            'responseBody': response.body,
          },
        );
      }
    } on UserServiceException {
      // Re-throw user service exceptions as-is
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('Network error during user creation: $e');
      throw UserServiceNetworkException(
        cause: e,
        context: <String, dynamic>{'operation': 'createUserDocument'},
      );
    } on FormatException catch (e) {
      debugPrint('JSON parsing error during user creation: $e');
      throw const UserDocumentCreationException(
        message: 'Invalid response from server. Please try again.',
      );
    } catch (e) {
      debugPrint('Unexpected error during user creation: $e');
      throw UserDocumentCreationException(
        message: 'An unexpected error occurred. Please try again.',
        cause: e,
      );
    }
  }

  /// Retrieves users by family ID from the backend system.
  ///
  /// This method fetches a list of users belonging to the specified family group. It supports pagination through
  /// optional limit and offset parameters.
  ///
  /// Parameters:
  /// * [familyId] - ID of the family to retrieve users for
  /// * [limit] - Maximum number of users to return (optional)
  /// * [offset] - Number of users to skip for pagination (optional)
  ///
  /// Returns a [Future<List<StaccatoUser>>] that completes with the list of users when successful.
  ///
  /// Throws:
  /// * [UserNotAuthenticatedException] - When the user is not signed in
  /// * [UserRetrievalException] - When user retrieval fails
  /// * [UserServiceNetworkException] - When network communication fails
  Future<List<StaccatoUser>> getUsersByFamilyId(
    String familyId, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Get the current authenticated user
      final firebase_auth.User? currentUser =
          firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw const UserNotAuthenticatedException();
      }

      // Get the user's ID token for authentication
      final String? idToken = await currentUser.getIdToken();
      if (idToken == null) {
        throw const UserNotAuthenticatedException(
          message: 'Failed to get authentication token. Please sign in again.',
        );
      }

      // Build query parameters
      final Map<String, String> queryParams = <String, String>{
        'familyId': familyId,
      };
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }
      if (offset != null) {
        queryParams['offset'] = offset.toString();
      }

      // Prepare the API request
      final Uri url = Uri.parse(
        '$_baseUrl/api/users',
      ).replace(queryParameters: queryParams);
      final Map<String, String> headers = <String, String>{
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      };

      debugPrint('Retrieving users via API: $url');

      // Make the HTTP request
      final http.Response response = await _httpClient
          .get(url, headers: headers)
          .timeout(_requestTimeout);

      debugPrint('User retrieval API response: ${response.statusCode}');

      // Handle the response
      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> responseData =
            jsonDecode(response.body) as Map<String, dynamic>;
        final List<dynamic> usersData = responseData['data'] as List<dynamic>;

        final List<StaccatoUser> users = usersData
            .cast<Map<String, dynamic>>()
            .map(StaccatoUser.fromJson)
            .toList();

        debugPrint('Retrieved ${users.length} users successfully');
        return users;
      } else {
        // Parse error response if possible
        String errorMessage = 'Failed to retrieve users';
        try {
          final Map<String, dynamic> errorData =
              jsonDecode(response.body) as Map<String, dynamic>;
          final Map<String, dynamic> error =
              errorData['error'] as Map<String, dynamic>;
          errorMessage = error['message'] as String? ?? errorMessage;
        } catch (e) {
          debugPrint('Failed to parse error response: $e');
        }

        throw UserRetrievalException(
          message: errorMessage,
          context: <String, dynamic>{
            'statusCode': response.statusCode,
            'responseBody': response.body,
            'familyId': familyId,
          },
        );
      }
    } on UserServiceException {
      // Re-throw user service exceptions as-is
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('Network error during user retrieval: $e');
      throw UserServiceNetworkException(
        cause: e,
        context: <String, dynamic>{
          'operation': 'getUsersByFamilyId',
          'familyId': familyId,
        },
      );
    } on FormatException catch (e) {
      debugPrint('JSON parsing error during user retrieval: $e');
      throw const UserRetrievalException(
        message: 'Invalid response from server. Please try again.',
      );
    } catch (e) {
      debugPrint('Unexpected error during user retrieval: $e');
      throw UserRetrievalException(
        message: 'An unexpected error occurred. Please try again.',
        cause: e,
        context: <String, dynamic>{'familyId': familyId},
      );
    }
  }

  /// Deletes the current user's document from the backend system.
  ///
  /// This method deletes the authenticated user's document from the Firestore database through the backend API. It
  /// requires the user to be authenticated and will only delete the document for the currently signed-in user.
  ///
  /// Returns a [Future<void>] that completes when the deletion is successful.
  ///
  /// Throws:
  /// * [UserNotAuthenticatedException] - When the user is not signed in
  /// * [UserDocumentDeletionException] - When user document deletion fails
  /// * [UserServiceNetworkException] - When network communication fails
  Future<void> deleteCurrentUserDocument() async {
    try {
      // Get the current authenticated user
      final firebase_auth.User? currentUser =
          firebase_auth.FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw const UserNotAuthenticatedException();
      }

      // Get the user's ID token for authentication
      final String? idToken = await currentUser.getIdToken();
      if (idToken == null) {
        throw const UserNotAuthenticatedException(
          message: 'Failed to get authentication token. Please sign in again.',
        );
      }

      // Prepare the API request
      final Uri url = Uri.parse('$_baseUrl/deleteUser'); // Legacy endpoint
      final Map<String, String> headers = <String, String>{
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      };

      debugPrint('Deleting user document via API: $url');

      // Make the HTTP request
      final http.Response response = await _httpClient
          .delete(url, headers: headers)
          .timeout(_requestTimeout);

      debugPrint('User deletion API response: ${response.statusCode}');

      // Handle the response
      if (response.statusCode == HttpStatus.ok) {
        debugPrint(
          'User document deleted successfully for UID: ${currentUser.uid}',
        );
      } else {
        // Parse error response if possible
        String errorMessage = 'Failed to delete user document';
        try {
          final Map<String, dynamic> errorData =
              jsonDecode(response.body) as Map<String, dynamic>;
          final Map<String, dynamic> error =
              errorData['error'] as Map<String, dynamic>;
          errorMessage = error['message'] as String? ?? errorMessage;
        } catch (e) {
          debugPrint('Failed to parse error response: $e');
        }

        throw UserDocumentDeletionException(
          message: errorMessage,
          context: <String, dynamic>{
            'statusCode': response.statusCode,
            'responseBody': response.body,
            'userId': currentUser.uid,
          },
        );
      }
    } on UserServiceException {
      // Re-throw user service exceptions as-is
      rethrow;
    } on http.ClientException catch (e) {
      debugPrint('Network error during user deletion: $e');
      throw UserServiceNetworkException(
        cause: e,
        context: <String, dynamic>{'operation': 'deleteCurrentUserDocument'},
      );
    } on FormatException catch (e) {
      debugPrint('JSON parsing error during user deletion: $e');
      throw const UserDocumentDeletionException(
        message: 'Invalid response from server. Please try again.',
      );
    } catch (e) {
      debugPrint('Unexpected error during user deletion: $e');
      throw UserDocumentDeletionException(
        message: 'An unexpected error occurred. Please try again.',
        cause: e,
      );
    }
  }

  /// Disposes of resources used by this service.
  ///
  /// This method should be called when the service is no longer needed to clean up HTTP connections and other
  /// resources.
  void dispose() {
    _httpClient.close();
  }
}
