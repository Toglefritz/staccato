import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jose/jose.dart';
import 'package:logging/logging.dart';

import 'package:staccato_api_server/exceptions/service_exception.dart';

/// Custom Firestore client using the REST API.
///
/// This client provides a direct interface to Google Cloud Firestore using HTTP requests to the REST API. It handles
/// authentication using Google Service Account credentials and provides methods for document operations and queries.
///
/// The client supports:
/// - Document CRUD operations (create, read, update, delete)
/// - Collection queries with filtering and pagination
/// - Automatic authentication token management
/// - Error handling and retry logic
class FirestoreClient {
  /// Creates a new Firestore client with the specified configuration.
  ///
  /// Parameters:
  /// * [projectId] - Google Cloud project ID
  /// * [serviceAccountEmail] - Service account email address
  /// * [privateKey] - Service account private key (PEM format)
  FirestoreClient({
    required String projectId,
    required String serviceAccountEmail,
    required String privateKey,
  })  : _projectId = projectId,
        _serviceAccountEmail = serviceAccountEmail,
        _privateKey = privateKey,
        _httpClient = http.Client();

  /// Google Cloud project ID.
  final String _projectId;

  /// Service account email address.
  final String _serviceAccountEmail;

  /// Service account private key in PEM format.
  final String _privateKey;

  /// HTTP client for making requests.
  final http.Client _httpClient;

  /// Logger instance for this client.
  static final Logger _logger = Logger('FirestoreClient');

  /// Base URL for Firestore REST API.
  String get _baseUrl => 'https://firestore.googleapis.com/v1/projects/$_projectId/databases/(default)/documents';

  /// Current access token for authentication.
  String? _accessToken;

  /// Expiration time of the current access token.
  DateTime? _tokenExpiration;

  /// Creates a new document in the specified collection.
  ///
  /// Parameters:
  /// * [collection] - Collection name
  /// * [documentId] - Document ID (optional, will be auto-generated if not provided)
  /// * [data] - Document data as a Map
  ///
  /// Returns the created document data.
  ///
  /// Throws [ServiceException] if the operation fails.
  Future<Map<String, dynamic>> createDocument(
    String collection,
    Map<String, dynamic> data, {
    String? documentId,
  }) async {
    try {
      _logger.fine('Creating document in collection: $collection', {
        'collection': collection,
        'documentId': documentId,
      });

      await _ensureValidToken();

      final String url = documentId != null ? '$_baseUrl/$collection?documentId=$documentId' : '$_baseUrl/$collection';

      final Map<String, dynamic> firestoreDocument = _convertToFirestoreDocument(data);

      final http.Response response = await _httpClient.post(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(firestoreDocument),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> convertedData = _convertFromFirestoreDocument(responseData);

        _logger.fine('Document created successfully', {
          'collection': collection,
          'documentId': documentId,
        });

        return convertedData;
      } else {
        _logger.severe('Failed to create document', {
          'collection': collection,
          'statusCode': response.statusCode,
          'body': response.body,
        });
        throw ServiceException(
          'Failed to create document: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _logger.severe('Error creating document', {
        'collection': collection,
        'error': e.toString(),
      });
      throw ServiceException('Failed to create document: $e', cause: e);
    }
  }

  /// Retrieves a document by its ID.
  ///
  /// Parameters:
  /// * [collection] - Collection name
  /// * [documentId] - Document ID
  ///
  /// Returns the document data, or null if not found.
  ///
  /// Throws [ServiceException] if the operation fails.
  Future<Map<String, dynamic>?> getDocument(
    String collection,
    String documentId,
  ) async {
    try {
      _logger.fine('Getting document', {
        'collection': collection,
        'documentId': documentId,
      });

      await _ensureValidToken();

      final String url = '$_baseUrl/$collection/$documentId';

      final http.Response response = await _httpClient.get(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> convertedData = _convertFromFirestoreDocument(responseData);

        _logger.fine('Document retrieved successfully', {
          'collection': collection,
          'documentId': documentId,
        });

        return convertedData;
      } else if (response.statusCode == 404) {
        _logger.fine('Document not found', {
          'collection': collection,
          'documentId': documentId,
        });
        return null;
      } else {
        _logger.severe('Failed to get document', {
          'collection': collection,
          'documentId': documentId,
          'statusCode': response.statusCode,
          'body': response.body,
        });
        throw ServiceException(
          'Failed to get document: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _logger.severe('Error getting document', {
        'collection': collection,
        'documentId': documentId,
        'error': e.toString(),
      });
      throw ServiceException('Failed to get document: $e', cause: e);
    }
  }

  /// Queries documents in a collection with optional filtering and pagination.
  ///
  /// Parameters:
  /// * [collection] - Collection name
  /// * [where] - Optional field equality filters (field -> value)
  /// * [limit] - Maximum number of documents to return
  /// * [offset] - Number of documents to skip
  ///
  /// Returns a list of document data.
  ///
  /// Throws [ServiceException] if the operation fails.
  Future<List<Map<String, dynamic>>> queryDocuments(
    String collection, {
    Map<String, dynamic>? where,
    int? limit,
    int? offset,
  }) async {
    try {
      _logger.fine('Querying documents', {
        'collection': collection,
        'where': where,
        'limit': limit,
        'offset': offset,
      });

      await _ensureValidToken();

      // Build structured query
      final Map<String, dynamic> structuredQuery = <String, dynamic>{
        'from': <Map<String, dynamic>>[
          <String, dynamic>{'collectionId': collection},
        ],
      };

      // Add where clauses
      if (where != null && where.isNotEmpty) {
        final List<Map<String, dynamic>> filters = <Map<String, dynamic>>[];

        for (final MapEntry<String, dynamic> entry in where.entries) {
          filters.add(<String, dynamic>{
            'fieldFilter': <String, dynamic>{
              'field': <String, dynamic>{'fieldPath': entry.key},
              'op': 'EQUAL',
              'value': _convertValueToFirestore(entry.value),
            },
          });
        }

        if (filters.length == 1) {
          structuredQuery['where'] = filters.first;
        } else {
          structuredQuery['where'] = <String, dynamic>{
            'compositeFilter': <String, dynamic>{
              'op': 'AND',
              'filters': filters,
            },
          };
        }
      }

      // Add limit
      if (limit != null) {
        structuredQuery['limit'] = limit;
      }

      // Add offset
      if (offset != null) {
        structuredQuery['offset'] = offset;
      }

      final String url = '$_baseUrl:runQuery';
      final Map<String, dynamic> requestBody = <String, dynamic>{
        'structuredQuery': structuredQuery,
      };

      final http.Response response = await _httpClient.post(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body) as List<dynamic>;
        final List<Map<String, dynamic>> documents = <Map<String, dynamic>>[];

        for (final dynamic item in responseData) {
          final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
          if (itemMap.containsKey('document')) {
            final Map<String, dynamic> document = itemMap['document'] as Map<String, dynamic>;
            final Map<String, dynamic> convertedData = _convertFromFirestoreDocument(document);
            documents.add(convertedData);
          }
        }

        _logger.fine('Documents queried successfully', {
          'collection': collection,
          'count': documents.length,
        });

        return documents;
      } else {
        _logger.severe('Failed to query documents', {
          'collection': collection,
          'statusCode': response.statusCode,
          'body': response.body,
        });
        throw ServiceException(
          'Failed to query documents: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _logger.severe('Error querying documents', {
        'collection': collection,
        'error': e.toString(),
      });
      throw ServiceException('Failed to query documents: $e', cause: e);
    }
  }

  /// Updates a document with the specified data.
  ///
  /// Parameters:
  /// * [collection] - Collection name
  /// * [documentId] - Document ID
  /// * [data] - Updated document data
  ///
  /// Returns the updated document data.
  ///
  /// Throws [ServiceException] if the operation fails.
  Future<Map<String, dynamic>> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      _logger.fine('Updating document', {
        'collection': collection,
        'documentId': documentId,
      });

      await _ensureValidToken();

      final String url = '$_baseUrl/$collection/$documentId';
      final Map<String, dynamic> firestoreDocument = _convertToFirestoreDocument(data);

      final http.Response response = await _httpClient.patch(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(firestoreDocument),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body) as Map<String, dynamic>;
        final Map<String, dynamic> convertedData = _convertFromFirestoreDocument(responseData);

        _logger.fine('Document updated successfully', {
          'collection': collection,
          'documentId': documentId,
        });

        return convertedData;
      } else {
        _logger.severe('Failed to update document', {
          'collection': collection,
          'documentId': documentId,
          'statusCode': response.statusCode,
          'body': response.body,
        });
        throw ServiceException(
          'Failed to update document: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _logger.severe('Error updating document', {
        'collection': collection,
        'documentId': documentId,
        'error': e.toString(),
      });
      throw ServiceException('Failed to update document: $e', cause: e);
    }
  }

  /// Deletes a document by its ID.
  ///
  /// Parameters:
  /// * [collection] - Collection name
  /// * [documentId] - Document ID
  ///
  /// Throws [ServiceException] if the operation fails.
  Future<void> deleteDocument(String collection, String documentId) async {
    try {
      _logger.fine('Deleting document', {
        'collection': collection,
        'documentId': documentId,
      });

      await _ensureValidToken();

      final String url = '$_baseUrl/$collection/$documentId';

      final http.Response response = await _httpClient.delete(
        Uri.parse(url),
        headers: <String, String>{
          'Authorization': 'Bearer $_accessToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _logger.fine('Document deleted successfully', {
          'collection': collection,
          'documentId': documentId,
        });
      } else {
        _logger.severe('Failed to delete document', {
          'collection': collection,
          'documentId': documentId,
          'statusCode': response.statusCode,
          'body': response.body,
        });
        throw ServiceException(
          'Failed to delete document: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _logger.severe('Error deleting document', {
        'collection': collection,
        'documentId': documentId,
        'error': e.toString(),
      });
      throw ServiceException('Failed to delete document: $e', cause: e);
    }
  }

  /// Checks if a document exists.
  ///
  /// Parameters:
  /// * [collection] - Collection name
  /// * [documentId] - Document ID
  ///
  /// Returns true if the document exists, false otherwise.
  ///
  /// Throws [ServiceException] if the operation fails.
  Future<bool> documentExists(String collection, String documentId) async {
    final Map<String, dynamic>? document = await getDocument(collection, documentId);
    return document != null;
  }

  /// Ensures that we have a valid access token for authentication.
  ///
  /// If the current token is expired or doesn't exist, generates a new one using the service account credentials.
  Future<void> _ensureValidToken() async {
    if (_accessToken == null || _tokenExpiration == null || DateTime.now().isAfter(_tokenExpiration!)) {
      await _generateAccessToken();
    }
  }

  /// Generates a new access token using service account credentials.
  ///
  /// Uses JWT (JSON Web Token) to authenticate with Google's OAuth 2.0 service and obtain an access token for Firestore
  /// API access.
  Future<void> _generateAccessToken() async {
    try {
      _logger.fine('Generating new access token');

      // Create JWT claims
      final DateTime now = DateTime.now();
      final DateTime expiration = now.add(const Duration(hours: 1));

      final Map<String, dynamic> claims = <String, dynamic>{
        'iss': _serviceAccountEmail,
        'scope': 'https://www.googleapis.com/auth/datastore',
        'aud': 'https://oauth2.googleapis.com/token',
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': expiration.millisecondsSinceEpoch ~/ 1000,
      };

      // Create and sign JWT - handle escaped newlines in private key
      final String normalizedPrivateKey = _privateKey.replaceAll(r'\n', '\n');
      final JsonWebKey jwk = JsonWebKey.fromPem(normalizedPrivateKey);
      final JsonWebSignatureBuilder builder = JsonWebSignatureBuilder()
        ..jsonContent = claims
        ..addRecipient(jwk, algorithm: 'RS256');

      final JsonWebSignature jws = builder.build();
      final String jwt = jws.toCompactSerialization();

      // Exchange JWT for access token
      final http.Response response = await _httpClient.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: <String, String>{
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=$jwt',
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenData = jsonDecode(response.body) as Map<String, dynamic>;
        _accessToken = tokenData['access_token'] as String;
        final int expiresIn = tokenData['expires_in'] as int;
        _tokenExpiration = DateTime.now().add(Duration(seconds: expiresIn - 60)); // 60 second buffer

        _logger.fine('Access token generated successfully');
      } else {
        _logger.severe('Failed to generate access token', {
          'statusCode': response.statusCode,
          'body': response.body,
        });
        throw ServiceException(
          'Failed to generate access token: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      _logger.severe('Error generating access token', {
        'error': e.toString(),
      });
      throw ServiceException('Failed to generate access token: $e', cause: e);
    }
  }

  /// Converts a regular Dart Map to Firestore document format.
  ///
  /// Firestore REST API requires values to be wrapped in type-specific objects.
  Map<String, dynamic> _convertToFirestoreDocument(Map<String, dynamic> data) {
    final Map<String, dynamic> fields = <String, dynamic>{};

    for (final MapEntry<String, dynamic> entry in data.entries) {
      fields[entry.key] = _convertValueToFirestore(entry.value);
    }

    return <String, dynamic>{'fields': fields};
  }

  /// Converts a Firestore document to a regular Dart Map.
  ///
  /// Extracts values from Firestore's type-specific wrapper objects.
  Map<String, dynamic> _convertFromFirestoreDocument(
    Map<String, dynamic> firestoreDoc,
  ) {
    final Map<String, dynamic> result = <String, dynamic>{};

    // Extract document ID from name field
    if (firestoreDoc.containsKey('name')) {
      final String name = firestoreDoc['name'] as String;
      final List<String> parts = name.split('/');
      if (parts.isNotEmpty) {
        result['id'] = parts.last;
      }
    }

    // Extract field values
    if (firestoreDoc.containsKey('fields')) {
      final Map<String, dynamic> fields = firestoreDoc['fields'] as Map<String, dynamic>;
      for (final MapEntry<String, dynamic> entry in fields.entries) {
        result[entry.key] = _convertValueFromFirestore(entry.value as Map<String, dynamic>);
      }
    }

    return result;
  }

  /// Converts a Dart value to Firestore value format.
  Map<String, dynamic> _convertValueToFirestore(dynamic value) {
    if (value == null) {
      return <String, dynamic>{'nullValue': null};
    } else if (value is bool) {
      return <String, dynamic>{'booleanValue': value};
    } else if (value is int) {
      return <String, dynamic>{'integerValue': value.toString()};
    } else if (value is double) {
      return <String, dynamic>{'doubleValue': value};
    } else if (value is String) {
      return <String, dynamic>{'stringValue': value};
    } else if (value is DateTime) {
      // Ensure the timestamp ends with 'Z' for UTC or has a timezone offset
      String timestamp = value.toIso8601String();
      if (!timestamp.endsWith('Z') && !timestamp.contains('+') && !timestamp.contains('-', timestamp.length - 6)) {
        timestamp = '${timestamp}Z';
      }
      return <String, dynamic>{'timestampValue': timestamp};
    } else if (value is List) {
      return <String, dynamic>{
        'arrayValue': <String, dynamic>{
          'values': value.map(_convertValueToFirestore).toList(),
        },
      };
    } else if (value is Map<String, dynamic>) {
      final Map<String, dynamic> fields = <String, dynamic>{};
      for (final MapEntry<String, dynamic> entry in value.entries) {
        fields[entry.key] = _convertValueToFirestore(entry.value);
      }
      return <String, dynamic>{
        'mapValue': <String, dynamic>{'fields': fields},
      };
    } else {
      // Fallback to string representation
      return <String, dynamic>{'stringValue': value.toString()};
    }
  }

  /// Converts a Firestore value to Dart value.
  dynamic _convertValueFromFirestore(Map<String, dynamic> firestoreValue) {
    if (firestoreValue.containsKey('nullValue')) {
      return null;
    } else if (firestoreValue.containsKey('booleanValue')) {
      return firestoreValue['booleanValue'] as bool;
    } else if (firestoreValue.containsKey('integerValue')) {
      return int.parse(firestoreValue['integerValue'] as String);
    } else if (firestoreValue.containsKey('doubleValue')) {
      return firestoreValue['doubleValue'] as double;
    } else if (firestoreValue.containsKey('stringValue')) {
      return firestoreValue['stringValue'] as String;
    } else if (firestoreValue.containsKey('timestampValue')) {
      return DateTime.parse(firestoreValue['timestampValue'] as String);
    } else if (firestoreValue.containsKey('arrayValue')) {
      final Map<String, dynamic> arrayValue = firestoreValue['arrayValue'] as Map<String, dynamic>;
      if (arrayValue.containsKey('values')) {
        final List<dynamic> values = arrayValue['values'] as List<dynamic>;
        return values
            .map(
              (dynamic item) => _convertValueFromFirestore(item as Map<String, dynamic>),
            )
            .toList();
      }
      return <dynamic>[];
    } else if (firestoreValue.containsKey('mapValue')) {
      final Map<String, dynamic> mapValue = firestoreValue['mapValue'] as Map<String, dynamic>;
      if (mapValue.containsKey('fields')) {
        final Map<String, dynamic> fields = mapValue['fields'] as Map<String, dynamic>;
        final Map<String, dynamic> result = <String, dynamic>{};
        for (final MapEntry<String, dynamic> entry in fields.entries) {
          result[entry.key] = _convertValueFromFirestore(entry.value as Map<String, dynamic>);
        }
        return result;
      }
      return <String, dynamic>{};
    } else {
      // Unknown type, return as-is
      return firestoreValue;
    }
  }

  /// Disposes of the client and cleans up resources.
  void dispose() {
    _httpClient.close();
  }
}
