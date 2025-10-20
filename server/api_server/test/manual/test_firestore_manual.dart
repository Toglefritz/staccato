import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';

import 'package:staccato_api_server/services/firestore_client.dart';

/// Manual test script for Firestore client.
///
/// This script demonstrates how to use the FirestoreClient and tests basic functionality. This test can be executed to
/// validate that the .env file is set up correctly and that everything works as expected.
///
/// Usage: dart run test_firestore_manual.dart
// ignore_for_file: avoid_print
Future<void> main() async {
  print('🚀 Starting Firestore Client Manual Test\n');

  try {
    // Load environment variables
    final DotEnv env = DotEnv()..load(['.env']);

    String? projectId = env['GOOGLE_CLOUD_PROJECT_ID'];
    String? serviceAccountEmail = env['GOOGLE_SERVICE_ACCOUNT_EMAIL'];
    String? privateKey = env['GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY'];
    final String? keyFilePath = env['GOOGLE_SERVICE_ACCOUNT_KEY_FILE'];

    // Try to load from JSON file if individual variables are not available
    if ((projectId == null || serviceAccountEmail == null || privateKey == null) && keyFilePath != null) {
      print('📄 Loading credentials from JSON file: $keyFilePath');

      final File keyFile = File(keyFilePath);
      if (!keyFile.existsSync()) {
        print('❌ Error: Service account key file not found: $keyFilePath');
        exit(1);
      }

      final String keyFileContent = keyFile.readAsStringSync();
      final Map<String, dynamic> keyData = jsonDecode(keyFileContent) as Map<String, dynamic>;

      projectId = keyData['project_id'] as String?;
      serviceAccountEmail = keyData['client_email'] as String?;
      privateKey = keyData['private_key'] as String?;
    }

    if (projectId == null || serviceAccountEmail == null || privateKey == null) {
      print('❌ Error: Missing required credentials');
      print('Either provide:');
      print(
        '  - GOOGLE_CLOUD_PROJECT_ID, GOOGLE_SERVICE_ACCOUNT_EMAIL, GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY',
      );
      print(
        '  - Or GOOGLE_SERVICE_ACCOUNT_KEY_FILE pointing to your service account JSON file',
      );
      exit(1);
    }

    print('✅ Credentials loaded');
    print('   Project ID: $projectId');
    print('   Service Account: $serviceAccountEmail');
    print('   Private Key Length: ${privateKey.length} characters\n');

    // Initialize Firestore client
    final FirestoreClient client = FirestoreClient(
      projectId: projectId,
      serviceAccountEmail: serviceAccountEmail,
      privateKey: privateKey,
    );

    print('✅ Firestore client initialized\n');

    // Test collection name
    final String testCollection = 'manual_test_${DateTime.now().millisecondsSinceEpoch}';
    print('📁 Using test collection: $testCollection\n');

    // Test 1: Create a document
    print('🔄 Test 1: Creating a document...');
    final Map<String, dynamic> testUser = <String, dynamic>{
      'displayName': 'Manual Test User',
      'familyId': 'family_manual_test',
      'permissionLevel': 'adult',
      'createdAt': DateTime.now().toIso8601String(),
      'profileImageUrl': 'https://example.com/profile.jpg',
      'metadata': <String, dynamic>{
        'testRun': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };

    final Map<String, dynamic> createdDoc = await client.createDocument(
      testCollection,
      testUser,
      documentId: 'manual_test_user',
    );

    print('✅ Document created successfully!');
    print('   ID: ${createdDoc['id']}');
    print('   Name: ${createdDoc['displayName']}');
    print('   Family: ${createdDoc['familyId']}\n');

    // Test 2: Retrieve the document
    print('🔄 Test 2: Retrieving the document...');
    final Map<String, dynamic>? retrievedDoc = await client.getDocument(testCollection, 'manual_test_user');

    if (retrievedDoc != null) {
      print('✅ Document retrieved successfully!');
      print('   ID: ${retrievedDoc['id']}');
      print('   Name: ${retrievedDoc['displayName']}');
      print('   Created: ${retrievedDoc['createdAt']}');
      print('   Metadata: ${retrievedDoc['metadata']}\n');
    } else {
      print('❌ Failed to retrieve document\n');
    }

    // Test 3: Update the document
    print('🔄 Test 3: Updating the document...');
    final Map<String, dynamic> updatedData = <String, dynamic>{
      'displayName': 'Updated Manual Test User',
      'familyId': 'family_manual_test',
      'permissionLevel': 'primary',
      'createdAt': testUser['createdAt'],
      'updatedAt': DateTime.now().toIso8601String(),
      'profileImageUrl': 'https://example.com/updated-profile.jpg',
      'metadata': <String, dynamic>{
        'testRun': true,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'updated': true,
      },
    };

    final Map<String, dynamic> updatedDoc = await client.updateDocument(
      testCollection,
      'manual_test_user',
      updatedData,
    );

    print('✅ Document updated successfully!');
    print('   Name: ${updatedDoc['displayName']}');
    print('   Permission: ${updatedDoc['permissionLevel']}');
    print('   Updated: ${updatedDoc['updatedAt']}\n');

    // Test 4: Create multiple documents for querying
    print('🔄 Test 4: Creating multiple documents for query testing...');
    final List<Map<String, dynamic>> familyMembers = <Map<String, dynamic>>[
      <String, dynamic>{
        'displayName': 'Alice Johnson',
        'familyId': 'family_johnson',
        'permissionLevel': 'primary',
        'age': 35,
      },
      <String, dynamic>{
        'displayName': 'Bob Johnson',
        'familyId': 'family_johnson',
        'permissionLevel': 'adult',
        'age': 33,
      },
      <String, dynamic>{
        'displayName': 'Charlie Johnson',
        'familyId': 'family_johnson',
        'permissionLevel': 'child',
        'age': 8,
      },
      <String, dynamic>{
        'displayName': 'Diana Smith',
        'familyId': 'family_smith',
        'permissionLevel': 'primary',
        'age': 42,
      },
    ];

    for (int i = 0; i < familyMembers.length; i++) {
      await client.createDocument(
        testCollection,
        familyMembers[i],
        documentId: 'family_member_$i',
      );
    }

    print('✅ Created ${familyMembers.length} family member documents\n');

    // Wait a moment for eventual consistency
    print('⏳ Waiting for eventual consistency...');
    await Future<void>.delayed(const Duration(seconds: 3));

    // Test 5: Query documents
    print('🔄 Test 5: Querying documents...');

    // Query all documents
    final List<Map<String, dynamic>> allDocs = await client.queryDocuments(testCollection);
    print('✅ Found ${allDocs.length} total documents');

    // Query by family
    final List<Map<String, dynamic>> johnsonFamily = await client.queryDocuments(
      testCollection,
      where: <String, dynamic>{'familyId': 'family_johnson'},
    );
    print('✅ Found ${johnsonFamily.length} Johnson family members');

    // Query with multiple filters
    final List<Map<String, dynamic>> johnsonAdults = await client.queryDocuments(
      testCollection,
      where: <String, dynamic>{
        'familyId': 'family_johnson',
        'permissionLevel': 'adult',
      },
    );
    print('✅ Found ${johnsonAdults.length} Johnson family adults');

    // Query with limit
    final List<Map<String, dynamic>> limitedResults = await client.queryDocuments(
      testCollection,
      limit: 2,
    );
    print('✅ Limited query returned ${limitedResults.length} documents\n');

    // Test 6: Check document existence
    print('🔄 Test 6: Checking document existence...');
    final bool exists = await client.documentExists(testCollection, 'manual_test_user');
    final bool notExists = await client.documentExists(testCollection, 'non_existent_doc');
    print('✅ Existing document check: $exists');
    print('✅ Non-existent document check: $notExists\n');

    // Test 7: Delete documents (cleanup)
    print('🔄 Test 7: Cleaning up test documents...');

    // Delete the main test document
    await client.deleteDocument(testCollection, 'manual_test_user');
    print('✅ Deleted main test document');

    // Delete family member documents
    for (int i = 0; i < familyMembers.length; i++) {
      await client.deleteDocument(testCollection, 'family_member_$i');
    }
    print('✅ Deleted ${familyMembers.length} family member documents');

    // Verify deletion
    final bool deletedExists = await client.documentExists(testCollection, 'manual_test_user');
    print('✅ Deletion verified: document exists = $deletedExists\n');

    // Clean up
    client.dispose();

    print('🎉 All tests completed successfully!');
    print('✅ Your Firestore client is working correctly.');
    print('✅ You can now use the API server with confidence.');
  } catch (e, stackTrace) {
    print('❌ Error during testing: $e');
    print('Stack trace: $stackTrace');
    print('\n💡 Troubleshooting tips:');
    print('1. Check your .env file has all required variables');
    print('2. Verify your Google Cloud project has Firestore enabled');
    print('3. Ensure your service account has proper permissions');
    print('4. Check your internet connection');
    exit(1);
  }
}
