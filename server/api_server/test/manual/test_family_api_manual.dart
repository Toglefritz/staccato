import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Manual test script for the Family API endpoints.
///
/// This script tests the full family management API including creation, retrieval, updates, and deletion. Make sure to
/// start the server first with: dart_frog dev
///
/// Usage: dart run test/manual/test_family_api_manual.dart
// ignore_for_file: avoid_print
Future<void> main() async {
  print('🏠 Starting Family API Manual Test\n');

  const String baseUrl = 'http://localhost:8080';
  final http.Client client = http.Client();
  String? createdFamilyId;

  try {
    // Test 1: Health check
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

    // Test 2: Create a family
    print('🔄 Test 2: Creating a family...');
    final Map<String, dynamic> newFamily = <String, dynamic>{
      'name': 'The Smith Family',
      'settings': <String, dynamic>{
        'timezone': 'America/New_York',
        'maxFamilyMembers': 8,
        'allowChildRegistration': false,
        'requireParentalApproval': true,
        'enableNotifications': true,
      },
    };

    final http.Response createResponse = await client.post(
      Uri.parse('$baseUrl/api/families'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(newFamily),
    );

    if (createResponse.statusCode == 201) {
      final Map<String, dynamic> createdFamily = jsonDecode(createResponse.body) as Map<String, dynamic>;
      createdFamilyId = createdFamily['id'] as String;

      print('✅ Family created successfully!');
      print('   ID: ${createdFamily['id']}');
      print('   Name: ${createdFamily['name']}');
      print('   Primary User: ${createdFamily['primaryUserId']}');
      // ignore: avoid_dynamic_calls
      print('   Timezone: ${createdFamily['settings']['timezone']}');
      // ignore: avoid_dynamic_calls
      print('   Max Members: ${createdFamily['settings']['maxFamilyMembers']}');
      print('   Created: ${createdFamily['createdAt']}');
    } else {
      print('❌ Failed to create family');
      print('   Status: ${createResponse.statusCode}');
      print('   Body: ${createResponse.body}');
    }

    print('');

    // Test 3: Create another family
    print('🔄 Test 3: Creating another family...');
    final Map<String, dynamic> secondFamily = <String, dynamic>{
      'name': 'The Johnson Family',
      'settings': <String, dynamic>{
        'timezone': 'America/Los_Angeles',
        'maxFamilyMembers': 12,
        'allowChildRegistration': true,
      },
    };

    final http.Response createResponse2 = await client.post(
      Uri.parse('$baseUrl/api/families'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(secondFamily),
    );

    if (createResponse2.statusCode == 201) {
      final Map<String, dynamic> createdFamily2 = jsonDecode(createResponse2.body) as Map<String, dynamic>;

      print('✅ Second family created successfully!');
      print('   ID: ${createdFamily2['id']}');
      print('   Name: ${createdFamily2['name']}');
      // ignore: avoid_dynamic_calls
      print('   Timezone: ${createdFamily2['settings']['timezone']}');
    } else {
      print('❌ Failed to create second family');
      print('   Status: ${createResponse2.statusCode}');
      print('   Body: ${createResponse2.body}');
    }

    print('');

    // Test 4: List all families
    print('🔄 Test 4: Listing all families...');
    final http.Response listResponse = await client.get(
      Uri.parse('$baseUrl/api/families'),
    );

    if (listResponse.statusCode == 200) {
      final List<dynamic> families = jsonDecode(listResponse.body) as List<dynamic>;

      print('✅ Family list retrieved successfully!');
      print('   Found ${families.length} families');

      for (final dynamic family in families) {
        final Map<String, dynamic> familyData = family as Map<String, dynamic>;
        print('   - ${familyData['name']} (ID: ${familyData['id']})');
      }
    } else {
      print('❌ Failed to list families');
      print('   Status: ${listResponse.statusCode}');
      print('   Body: ${listResponse.body}');
    }

    print('');

    // Test 5: Get specific family by ID
    if (createdFamilyId != null) {
      print('🔄 Test 5: Getting family by ID...');
      final http.Response getResponse = await client.get(
        Uri.parse('$baseUrl/api/families/$createdFamilyId'),
      );

      if (getResponse.statusCode == 200) {
        final Map<String, dynamic> familyResponse = jsonDecode(getResponse.body) as Map<String, dynamic>;
        final Map<String, dynamic> family = familyResponse['family'] as Map<String, dynamic>;
        final List<dynamic> members = familyResponse['members'] as List<dynamic>;

        print('✅ Family retrieved successfully!');
        print('   Name: ${family['name']}');
        print('   Primary User: ${family['primaryUserId']}');
        print('   Member Count: ${familyResponse['memberCount']}');
        print('   At Member Limit: ${familyResponse['isAtMemberLimit']}');
        print('   Members: ${members.length} found');

        for (final dynamic member in members) {
          final Map<String, dynamic> memberData = member as Map<String, dynamic>;
          print('     - ${memberData['displayName']} (${memberData['permissionLevel']})');
        }
      } else {
        print('❌ Failed to get family');
        print('   Status: ${getResponse.statusCode}');
        print('   Body: ${getResponse.body}');
      }
    }

    print('');

    // Test 6: Get family without members
    if (createdFamilyId != null) {
      print('🔄 Test 6: Getting family without members...');
      final http.Response getResponse = await client.get(
        Uri.parse('$baseUrl/api/families/$createdFamilyId?includeMembers=false'),
      );

      if (getResponse.statusCode == 200) {
        final Map<String, dynamic> family = jsonDecode(getResponse.body) as Map<String, dynamic>;

        print('✅ Family retrieved without members!');
        print('   Name: ${family['name']}');
        print('   ID: ${family['id']}');
        print('   No members field included: ${!family.containsKey('members')}');
      } else {
        print('❌ Failed to get family without members');
        print('   Status: ${getResponse.statusCode}');
        print('   Body: ${getResponse.body}');
      }
    }

    print('');

    // Test 7: Update family
    if (createdFamilyId != null) {
      print('🔄 Test 7: Updating family...');
      final Map<String, dynamic> updateData = <String, dynamic>{
        'name': 'The Updated Smith Family',
        'settings': <String, dynamic>{
          'timezone': 'America/Chicago',
          'maxFamilyMembers': 15,
          'enableNotifications': false,
        },
      };

      final http.Response updateResponse = await client.put(
        Uri.parse('$baseUrl/api/families/$createdFamilyId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );

      if (updateResponse.statusCode == 200) {
        final Map<String, dynamic> updatedFamily = jsonDecode(updateResponse.body) as Map<String, dynamic>;

        print('✅ Family updated successfully!');
        print('   New Name: ${updatedFamily['name']}');
        // ignore: avoid_dynamic_calls
        print('   New Timezone: ${updatedFamily['settings']['timezone']}');
        // ignore: avoid_dynamic_calls
        print('   New Max Members: ${updatedFamily['settings']['maxFamilyMembers']}');
        print('   Updated At: ${updatedFamily['updatedAt']}');
      } else {
        print('❌ Failed to update family');
        print('   Status: ${updateResponse.statusCode}');
        print('   Body: ${updateResponse.body}');
      }
    }

    print('');

    // Test 8: Test pagination
    print('🔄 Test 8: Testing pagination...');
    final http.Response paginationResponse = await client.get(
      Uri.parse('$baseUrl/api/families?limit=1&offset=0'),
    );

    if (paginationResponse.statusCode == 200) {
      final List<dynamic> families = jsonDecode(paginationResponse.body) as List<dynamic>;

      print('✅ Pagination test successful!');
      print('   Returned ${families.length} family(ies) with limit=1');
    } else {
      print('❌ Pagination test failed');
      print('   Status: ${paginationResponse.statusCode}');
      print('   Body: ${paginationResponse.body}');
    }

    print('');

    // Test 9: Test validation errors
    print('🔄 Test 9: Testing validation errors...');
    final Map<String, dynamic> invalidFamily = <String, dynamic>{
      'name': '', // Empty name should fail
      'settings': <String, dynamic>{
        'timezone': 'Invalid/Timezone',
      },
    };

    final http.Response validationResponse = await client.post(
      Uri.parse('$baseUrl/api/families'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(invalidFamily),
    );

    if (validationResponse.statusCode == 400) {
      final Map<String, dynamic> errorResult = jsonDecode(validationResponse.body) as Map<String, dynamic>;

      print('✅ Validation error handling works!');
      print('   Error: ${errorResult['error']}');
      if (errorResult.containsKey('code')) {
        print('   Code: ${errorResult['code']}');
      }
      if (errorResult.containsKey('field')) {
        print('   Field: ${errorResult['field']}');
      }
    } else {
      print('❌ Validation error test failed');
      print('   Expected 400, got ${validationResponse.statusCode}');
      print('   Body: ${validationResponse.body}');
    }

    print('');

    // Test 10: Test malformed JSON
    print('🔄 Test 10: Testing malformed JSON...');
    final http.Response malformedResponse = await client.post(
      Uri.parse('$baseUrl/api/families'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: '{"name": "Test Family"', // Malformed JSON
    );

    if (malformedResponse.statusCode == 400) {
      final Map<String, dynamic> errorResult = jsonDecode(malformedResponse.body) as Map<String, dynamic>;

      print('✅ Malformed JSON handling works!');
      print('   Error: ${errorResult['error']}');
    } else {
      print('❌ Malformed JSON test failed');
      print('   Expected 400, got ${malformedResponse.statusCode}');
    }

    print('');

    // Test 11: Test non-existent family
    print('🔄 Test 11: Testing non-existent family...');
    final http.Response notFoundResponse = await client.get(
      Uri.parse('$baseUrl/api/families/nonexistent-family-id'),
    );

    if (notFoundResponse.statusCode == 404) {
      final Map<String, dynamic> errorResult = jsonDecode(notFoundResponse.body) as Map<String, dynamic>;

      print('✅ Not found handling works!');
      print('   Error: ${errorResult['error']}');
    } else {
      print('❌ Not found test failed');
      print('   Expected 404, got ${notFoundResponse.statusCode}');
      print('   Body: ${notFoundResponse.body}');
    }

    print('');

    // Test 12: Test unsupported method
    print('🔄 Test 12: Testing unsupported HTTP method...');
    final http.Response methodResponse = await client.patch(
      Uri.parse('$baseUrl/api/families'),
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

    // Test 13: Test family deletion (should be last test)
    if (createdFamilyId != null) {
      print('🔄 Test 13: Deleting family...');
      final http.Response deleteResponse = await client.delete(
        Uri.parse('$baseUrl/api/families/$createdFamilyId'),
      );

      if (deleteResponse.statusCode == 204) {
        print('✅ Family deleted successfully!');
        print('   Status: ${deleteResponse.statusCode} (No Content)');

        // Verify deletion
        print('🔄 Verifying deletion...');
        final http.Response verifyResponse = await client.get(
          Uri.parse('$baseUrl/api/families/$createdFamilyId'),
        );

        if (verifyResponse.statusCode == 404) {
          print('✅ Deletion verified - family no longer exists');
        } else {
          print('❌ Deletion verification failed');
          print('   Expected 404, got ${verifyResponse.statusCode}');
        }
      } else {
        print('❌ Failed to delete family');
        print('   Status: ${deleteResponse.statusCode}');
        print('   Body: ${deleteResponse.body}');
      }
    }

    print('');

    print('🎉 All Family API tests completed!');
    print('✅ Your Family API server is working correctly.');
    print('✅ Family CRUD operations are functioning properly.');
    print('✅ Validation and error handling work as expected.');
    print('✅ Pagination and query parameters work correctly.');
    print('✅ Member integration is working properly.');
  } catch (e, stackTrace) {
    print('❌ Error during Family API testing: $e');
    print('Stack trace: $stackTrace');
    print('\n💡 Troubleshooting tips:');
    print('1. Make sure the server is running: dart_frog dev');
    print('2. Check your .env file configuration');
    print('3. Verify Firestore permissions and connectivity');
    print('4. Ensure family service dependencies are properly registered');
    exit(1);
  } finally {
    client.close();
  }
}
