import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:staccato_api_server/services/firestore_client.dart';
import 'package:test/test.dart';

/// Integration tests for FirestoreClient.
///
/// These tests require actual Google Cloud credentials and will make real API calls to Firestore. Make sure you have a
/// valid .env file with proper credentials before running these tests.
///
/// To run these tests:
/// 1. Set up Google Cloud project with Firestore enabled
/// 2. Create service account with Firestore permissions
/// 3. Add credentials to .env file
/// 4. Run: dart test test/services/firestore_client_test.dart
// ignore_for_file: avoid_print
void main() {
  group(
    'FirestoreClient Integration Tests',
    () {
      late FirestoreClient client;
      late String testCollection;

      setUpAll(() {
        // Load environment variables
        final DotEnv env = DotEnv()..load(['.env']);

        String? projectId = env['GOOGLE_CLOUD_PROJECT_ID'];
        String? serviceAccountEmail = env['GOOGLE_SERVICE_ACCOUNT_EMAIL'];
        String? privateKey = env['GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY'];
        final String? keyFilePath = env['GOOGLE_SERVICE_ACCOUNT_KEY_FILE'];

        // Try to load from JSON file if individual variables are not available
        if ((projectId == null || serviceAccountEmail == null || privateKey == null) && keyFilePath != null) {
          final File keyFile = File(keyFilePath);
          if (keyFile.existsSync()) {
            final String keyFileContent = keyFile.readAsStringSync();
            final Map<String, dynamic> keyData = jsonDecode(keyFileContent) as Map<String, dynamic>;

            projectId = keyData['project_id'] as String?;
            serviceAccountEmail = keyData['client_email'] as String?;
            privateKey = keyData['private_key'] as String?;
          }
        }

        if (projectId == null || serviceAccountEmail == null || privateKey == null) {
          throw StateError(
            'Missing required credentials. Please check your .env file.\n'
            'Required: Either individual env vars or GOOGLE_SERVICE_ACCOUNT_KEY_FILE',
          );
        }

        client = FirestoreClient(
          projectId: projectId,
          serviceAccountEmail: serviceAccountEmail,
          privateKey: privateKey,
        );

        // Use a unique collection name for testing
        testCollection = 'test_users_${DateTime.now().millisecondsSinceEpoch}';
      });

      tearDownAll(() {
        client.dispose();
      });

      group('Document Operations', () {
        test('should create a document with auto-generated ID', () async {
          // Arrange
          final Map<String, dynamic> testData = <String, dynamic>{
            'displayName': 'Test User',
            'familyId': 'family_123',
            'permissionLevel': 'adult',
            'createdAt': DateTime.now().toIso8601String(),
          };

          // Act
          final Map<String, dynamic> result = await client.createDocument(testCollection, testData);

          // Assert
          expect(result['id'], isNotNull);
          expect(result['displayName'], equals('Test User'));
          expect(result['familyId'], equals('family_123'));
          expect(result['permissionLevel'], equals('adult'));
          expect(result['createdAt'], isNotNull);

          print('✅ Created document with ID: ${result['id']}');
        });

        test('should create a document with specified ID', () async {
          // Arrange
          const String documentId = 'user_test_123';
          final Map<String, dynamic> testData = <String, dynamic>{
            'displayName': 'Test User with ID',
            'familyId': 'family_456',
            'permissionLevel': 'primary',
            'createdAt': DateTime.now().toIso8601String(),
          };

          // Act
          final Map<String, dynamic> result = await client.createDocument(
            testCollection,
            testData,
            documentId: documentId,
          );

          // Assert
          expect(result['id'], equals(documentId));
          expect(result['displayName'], equals('Test User with ID'));
          expect(result['familyId'], equals('family_456'));
          expect(result['permissionLevel'], equals('primary'));

          print('✅ Created document with specified ID: $documentId');
        });

        test('should retrieve a document by ID', () async {
          // Arrange - First create a document
          const String documentId = 'user_retrieve_test';
          final Map<String, dynamic> testData = <String, dynamic>{
            'displayName': 'Retrieve Test User',
            'familyId': 'family_789',
            'permissionLevel': 'child',
            'profileImageUrl': 'https://example.com/profile.jpg',
          };

          await client.createDocument(
            testCollection,
            testData,
            documentId: documentId,
          );

          // Act
          final Map<String, dynamic>? result = await client.getDocument(testCollection, documentId);

          // Assert
          expect(result, isNotNull);
          expect(result!['id'], equals(documentId));
          expect(result['displayName'], equals('Retrieve Test User'));
          expect(result['familyId'], equals('family_789'));
          expect(result['permissionLevel'], equals('child'));
          expect(
            result['profileImageUrl'],
            equals('https://example.com/profile.jpg'),
          );

          print('✅ Retrieved document: $documentId');
        });

        test('should return null for non-existent document', () async {
          // Act
          final Map<String, dynamic>? result = await client.getDocument(testCollection, 'non_existent_id');

          // Assert
          expect(result, isNull);

          print('✅ Correctly returned null for non-existent document');
        });

        test('should update a document', () async {
          // Arrange - First create a document
          const String documentId = 'user_update_test';
          final Map<String, dynamic> originalData = <String, dynamic>{
            'displayName': 'Original Name',
            'familyId': 'family_update',
            'permissionLevel': 'adult',
          };

          await client.createDocument(
            testCollection,
            originalData,
            documentId: documentId,
          );

          // Act - Update the document
          final Map<String, dynamic> updatedData = <String, dynamic>{
            'displayName': 'Updated Name',
            'familyId': 'family_update',
            'permissionLevel': 'primary',
            'updatedAt': DateTime.now().toIso8601String(),
          };

          final Map<String, dynamic> result = await client.updateDocument(
            testCollection,
            documentId,
            updatedData,
          );

          // Assert
          expect(result['id'], equals(documentId));
          expect(result['displayName'], equals('Updated Name'));
          expect(result['permissionLevel'], equals('primary'));
          expect(result['updatedAt'], isNotNull);

          print('✅ Updated document: $documentId');
        });

        test('should delete a document', () async {
          // Arrange - First create a document
          const String documentId = 'user_delete_test';
          final Map<String, dynamic> testData = <String, dynamic>{
            'displayName': 'Delete Test User',
            'familyId': 'family_delete',
            'permissionLevel': 'adult',
          };

          await client.createDocument(
            testCollection,
            testData,
            documentId: documentId,
          );

          // Verify it exists
          final Map<String, dynamic>? beforeDelete = await client.getDocument(testCollection, documentId);
          expect(beforeDelete, isNotNull);

          // Act - Delete the document
          await client.deleteDocument(testCollection, documentId);

          // Assert - Verify it's gone
          final Map<String, dynamic>? afterDelete = await client.getDocument(testCollection, documentId);
          expect(afterDelete, isNull);

          print('✅ Deleted document: $documentId');
        });

        test('should check document existence', () async {
          // Arrange - Create a document
          const String documentId = 'user_exists_test';
          final Map<String, dynamic> testData = <String, dynamic>{
            'displayName': 'Exists Test User',
            'familyId': 'family_exists',
            'permissionLevel': 'adult',
          };

          await client.createDocument(
            testCollection,
            testData,
            documentId: documentId,
          );

          // Act & Assert - Check existing document
          final bool exists = await client.documentExists(testCollection, documentId);
          expect(exists, isTrue);

          // Act & Assert - Check non-existent document
          final bool notExists = await client.documentExists(testCollection, 'non_existent');
          expect(notExists, isFalse);

          print('✅ Document existence checks work correctly');
        });
      });

      group('Query Operations', () {
        setUpAll(() async {
          // Create test documents for querying
          final List<Map<String, dynamic>> testUsers = <Map<String, dynamic>>[
            <String, dynamic>{
              'displayName': 'Alice Johnson',
              'familyId': 'family_query_test',
              'permissionLevel': 'primary',
              'age': 35,
            },
            <String, dynamic>{
              'displayName': 'Bob Johnson',
              'familyId': 'family_query_test',
              'permissionLevel': 'adult',
              'age': 33,
            },
            <String, dynamic>{
              'displayName': 'Charlie Johnson',
              'familyId': 'family_query_test',
              'permissionLevel': 'child',
              'age': 8,
            },
            <String, dynamic>{
              'displayName': 'Diana Smith',
              'familyId': 'family_other',
              'permissionLevel': 'primary',
              'age': 42,
            },
          ];

          for (int i = 0; i < testUsers.length; i++) {
            await client.createDocument(
              testCollection,
              testUsers[i],
              documentId: 'query_user_$i',
            );
          }

          // Wait a moment for eventual consistency
          await Future<void>.delayed(const Duration(seconds: 2));
        });

        test('should query all documents in collection', () async {
          // Act
          final List<Map<String, dynamic>> results = await client.queryDocuments(testCollection);

          // Assert
          expect(
            results.length,
            greaterThanOrEqualTo(4),
          ); // At least our test documents
          print('✅ Queried all documents: ${results.length} found');
        });

        test('should query documents with where filter', () async {
          // Act
          final List<Map<String, dynamic>> results = await client.queryDocuments(
            testCollection,
            where: <String, dynamic>{'familyId': 'family_query_test'},
          );

          // Assert
          expect(results.length, equals(3));
          for (final Map<String, dynamic> result in results) {
            expect(result['familyId'], equals('family_query_test'));
          }

          print('✅ Filtered query returned ${results.length} documents');
        });

        test('should query documents with multiple filters', () async {
          // Act
          final List<Map<String, dynamic>> results = await client.queryDocuments(
            testCollection,
            where: <String, dynamic>{
              'familyId': 'family_query_test',
              'permissionLevel': 'adult',
            },
          );

          // Assert
          expect(results.length, equals(1));
          expect(results.first['displayName'], equals('Bob Johnson'));
          expect(results.first['familyId'], equals('family_query_test'));
          expect(results.first['permissionLevel'], equals('adult'));

          print('✅ Multi-filter query returned correct document');
        });

        test('should query documents with limit', () async {
          // Act
          final List<Map<String, dynamic>> results = await client.queryDocuments(
            testCollection,
            where: <String, dynamic>{'familyId': 'family_query_test'},
            limit: 2,
          );

          // Assert
          expect(results.length, equals(2));
          for (final Map<String, dynamic> result in results) {
            expect(result['familyId'], equals('family_query_test'));
          }

          print('✅ Limited query returned ${results.length} documents');
        });

        test('should query documents with offset', () async {
          // Act - Get first 2 documents
          final List<Map<String, dynamic>> firstBatch = await client.queryDocuments(
            testCollection,
            where: <String, dynamic>{'familyId': 'family_query_test'},
            limit: 2,
          );

          // Act - Get next document with offset
          final List<Map<String, dynamic>> secondBatch = await client.queryDocuments(
            testCollection,
            where: <String, dynamic>{'familyId': 'family_query_test'},
            limit: 1,
            offset: 2,
          );

          // Assert
          expect(firstBatch.length, equals(2));
          expect(secondBatch.length, equals(1));

          // Ensure we got different documents
          final Set<String> firstIds = firstBatch.map((Map<String, dynamic> doc) => doc['id'] as String).toSet();
          final Set<String> secondIds = secondBatch.map((Map<String, dynamic> doc) => doc['id'] as String).toSet();
          expect(firstIds.intersection(secondIds), isEmpty);

          print('✅ Offset query returned different documents');
        });
      });

      group('Data Type Handling', () {
        test('should handle various data types correctly', () async {
          // Arrange
          const String documentId = 'data_types_test';
          final DateTime testDate = DateTime.now();
          final Map<String, dynamic> testData = <String, dynamic>{
            'stringField': 'Hello World',
            'intField': 42,
            'doubleField': 3.14159,
            'boolField': true,
            'nullField': null,
            'dateField': testDate,
            'arrayField': <dynamic>['item1', 'item2', 123],
            'mapField': <String, dynamic>{
              'nestedString': 'nested value',
              'nestedInt': 100,
              'nestedBool': false,
            },
          };

          // Act
          await client.createDocument(
            testCollection,
            testData,
            documentId: documentId,
          );
          final Map<String, dynamic>? result = await client.getDocument(testCollection, documentId);

          // Assert
          expect(result, isNotNull);
          expect(result!['stringField'], equals('Hello World'));
          expect(result['intField'], equals(42));
          expect(result['doubleField'], equals(3.14159));
          expect(result['boolField'], equals(true));
          expect(result['nullField'], isNull);
          expect(result['dateField'], isA<DateTime>());
          expect(result['arrayField'], isA<List<dynamic>>());
          expect(result['arrayField'], hasLength(3));
          expect(result['mapField'], isA<Map<String, dynamic>>());
          // ignore: avoid_dynamic_calls
          expect(result['mapField']['nestedString'], equals('nested value'));
          // ignore: avoid_dynamic_calls
          expect(result['mapField']['nestedInt'], equals(100));
          // ignore: avoid_dynamic_calls
          expect(result['mapField']['nestedBool'], equals(false));

          print('✅ All data types handled correctly');
        });
      });
    },
    skip: _shouldSkipIntegrationTests(),
  );
}

/// Determines whether to skip integration tests.
///
/// Integration tests are skipped if:
/// 1. Running in CI environment
/// 2. .env file doesn't exist
/// 3. Required environment variables are missing
bool _shouldSkipIntegrationTests() {
  // Skip in CI environments
  if (Platform.environment['CI'] == 'true') {
    return true;
  }

  // Check if .env file exists
  final File envFile = File('.env');
  if (!envFile.existsSync()) {
    print('⚠️  Skipping integration tests: .env file not found');
    return true;
  }

  // Try to load environment variables
  try {
    final DotEnv env = DotEnv()..load(['.env']);

    String? projectId = env['GOOGLE_CLOUD_PROJECT_ID'];
    String? serviceAccountEmail = env['GOOGLE_SERVICE_ACCOUNT_EMAIL'];
    String? privateKey = env['GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY'];
    final String? keyFilePath = env['GOOGLE_SERVICE_ACCOUNT_KEY_FILE'];

    // Try to load from JSON file if individual variables are not available
    if ((projectId == null || serviceAccountEmail == null || privateKey == null) && keyFilePath != null) {
      final File keyFile = File(keyFilePath);
      if (keyFile.existsSync()) {
        final String keyFileContent = keyFile.readAsStringSync();
        final Map<String, dynamic> keyData = jsonDecode(keyFileContent) as Map<String, dynamic>;

        projectId = keyData['project_id'] as String?;
        serviceAccountEmail = keyData['client_email'] as String?;
        privateKey = keyData['private_key'] as String?;
      }
    }

    if (projectId == null || serviceAccountEmail == null || privateKey == null) {
      print('⚠️  Skipping integration tests: Missing required credentials');
      return true;
    }

    return false;
  } catch (e) {
    print('⚠️  Skipping integration tests: Error loading .env file: $e');
    return true;
  }
}
