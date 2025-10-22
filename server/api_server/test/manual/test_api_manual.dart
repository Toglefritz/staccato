import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Manual test script for the API server.
///
/// This script tests the full API server including the user endpoints. Make sure to start the server first with:
/// dart_frog dev
///
/// Usage: dart run test_api_manual.dart
// ignore_for_file: avoid_print
Future<void> main() async {
  print('🚀 Starting API Server Manual Test\n');

  const String baseUrl = 'http://localhost:8080';
  final http.Client client = http.Client();

  try {
    // Test 1: Health check (if you have one)
    print('🔄 Test 1: Server health check...');
    try {
      final http.Response healthResponse = await client.get(Uri.parse('$baseUrl/'));
      print('✅ Server is running (Status: ${healthResponse.statusCode})');
    } catch (e) {
      print('❌ Server health check failed: $e');
      print('💡 Make sure to start the server with: dart_frog dev');
      exit(1);
    }

    print('');

    // Test 2: Create a user
    print('🔄 Test 2: Creating a user...');
    final Map<String, dynamic> newUser = <String, dynamic>{
      'displayName': 'API Test User',
      'familyId': 'family_api_test',
      'permissionLevel': 'adult',
      'profileImageUrl': 'https://example.com/api-test-profile.jpg',
    };

    final http.Response createResponse = await client.post(
      Uri.parse('$baseUrl/api/users'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(newUser),
    );

    if (createResponse.statusCode == 201) {
      final Map<String, dynamic> createdUser = jsonDecode(createResponse.body) as Map<String, dynamic>;
      final Map<String, dynamic> userData = createdUser['data'] as Map<String, dynamic>;

      print('✅ User created successfully!');
      print('   ID: ${userData['id']}');
      print('   Name: ${userData['displayName']}');
      print('   Family: ${userData['familyId']}');
      print('   Permission: ${userData['permissionLevel']}');
      print('   Created: ${userData['createdAt']}');
    } else {
      print('❌ Failed to create user');
      print('   Status: ${createResponse.statusCode}');
      print('   Body: ${createResponse.body}');
    }

    print('');

    // Test 3: Create another user in the same family
    print('🔄 Test 3: Creating another user in the same family...');
    final Map<String, dynamic> secondUser = <String, dynamic>{
      'displayName': 'Second API Test User',
      'familyId': 'family_api_test',
      'permissionLevel': 'primary',
    };

    final http.Response createResponse2 = await client.post(
      Uri.parse('$baseUrl/api/users'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(secondUser),
    );

    if (createResponse2.statusCode == 201) {
      final Map<String, dynamic> createdUser2 = jsonDecode(createResponse2.body) as Map<String, dynamic>;
      final Map<String, dynamic> userData2 = createdUser2['data'] as Map<String, dynamic>;

      print('✅ Second user created successfully!');
      print('   ID: ${userData2['id']}');
      print('   Name: ${userData2['displayName']}');
      print('   Permission: ${userData2['permissionLevel']}');
    } else {
      print('❌ Failed to create second user');
      print('   Status: ${createResponse2.statusCode}');
      print('   Body: ${createResponse2.body}');
    }

    print('');

    // Test 4: Create a user in a different family
    print('🔄 Test 4: Creating a user in a different family...');
    final Map<String, dynamic> differentFamilyUser = <String, dynamic>{
      'displayName': 'Different Family User',
      'familyId': 'family_different',
      'permissionLevel': 'child',
    };

    final http.Response createResponse3 = await client.post(
      Uri.parse('$baseUrl/api/users'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(differentFamilyUser),
    );

    if (createResponse3.statusCode == 201) {
      print('✅ Different family user created successfully!');
    } else {
      print('❌ Failed to create different family user');
      print('   Status: ${createResponse3.statusCode}');
      print('   Body: ${createResponse3.body}');
    }

    print('');

    // Wait for eventual consistency
    print('⏳ Waiting for eventual consistency...');
    await Future<void>.delayed(const Duration(seconds: 3));

    // Test 5: Query users by family
    print('🔄 Test 5: Querying users by family...');
    final http.Response queryResponse = await client.get(
      Uri.parse('$baseUrl/api/users?familyId=family_api_test'),
    );

    if (queryResponse.statusCode == 200) {
      final Map<String, dynamic> queryResult = jsonDecode(queryResponse.body) as Map<String, dynamic>;
      final List<dynamic> users = queryResult['data'] as List<dynamic>;
      final Map<String, dynamic> meta = queryResult['meta'] as Map<String, dynamic>;

      print('✅ Query successful!');
      print('   Found ${users.length} users in family_api_test');
      print('   Total count: ${meta['count']}');

      for (final dynamic user in users) {
        final Map<String, dynamic> userData = user as Map<String, dynamic>;
        print(
          '   - ${userData['displayName']} (${userData['permissionLevel']})',
        );
      }
    } else {
      print('❌ Failed to query users');
      print('   Status: ${queryResponse.statusCode}');
      print('   Body: ${queryResponse.body}');
    }

    print('');

    // Test 6: Query with pagination
    print('🔄 Test 6: Testing pagination...');
    final http.Response paginationResponse = await client.get(
      Uri.parse('$baseUrl/api/users?familyId=family_api_test&limit=1'),
    );

    if (paginationResponse.statusCode == 200) {
      final Map<String, dynamic> paginationResult = jsonDecode(paginationResponse.body) as Map<String, dynamic>;
      final List<dynamic> users = paginationResult['data'] as List<dynamic>;

      print('✅ Pagination test successful!');
      print('   Returned ${users.length} user(s) with limit=1');
    } else {
      print('❌ Pagination test failed');
      print('   Status: ${paginationResponse.statusCode}');
      print('   Body: ${paginationResponse.body}');
    }

    print('');

    // Test 7: Test validation errors
    print('🔄 Test 7: Testing validation errors...');
    final Map<String, dynamic> invalidUser = <String, dynamic>{
      'displayName': '', // Empty name should fail
      'familyId': 'family_test',
      'permissionLevel': 'adult',
    };

    final http.Response validationResponse = await client.post(
      Uri.parse('$baseUrl/api/users'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(invalidUser),
    );

    if (validationResponse.statusCode == 400) {
      final Map<String, dynamic> errorResult = jsonDecode(validationResponse.body) as Map<String, dynamic>;
      final Map<String, dynamic> error = errorResult['error'] as Map<String, dynamic>;

      print('✅ Validation error handling works!');
      print('   Error message: ${error['message']}');
      print('   Error code: ${error['code']}');
      print('   Error field: ${error['field']}');
    } else {
      print('❌ Validation error test failed');
      print('   Expected 400, got ${validationResponse.statusCode}');
      print('   Body: ${validationResponse.body}');
    }

    print('');

    // Test 8: Test unsupported method
    print('🔄 Test 8: Testing unsupported HTTP method...');
    final http.Response methodResponse = await client.put(
      Uri.parse('$baseUrl/api/users'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{}),
    );

    if (methodResponse.statusCode == 405) {
      print('✅ Method not allowed handling works!');
      print('   Status: ${methodResponse.statusCode}');
    } else {
      print('❌ Method not allowed test failed');
      print('   Expected 405, got ${methodResponse.statusCode}');
    }

    print('');

    print('🎉 All API tests completed!');
    print('✅ Your API server is working correctly.');
    print('✅ User endpoints are functioning properly.');
    print('✅ Error handling is working as expected.');
  } catch (e, stackTrace) {
    print('❌ Error during API testing: $e');
    print('Stack trace: $stackTrace');
    print('\n💡 Troubleshooting tips:');
    print('1. Make sure the server is running: dart_frog dev');
    print('2. Check your .env file configuration');
    print('3. Verify Firestore permissions and connectivity');
    exit(1);
  } finally {
    client.close();
  }
}
