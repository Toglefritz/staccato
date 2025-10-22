import 'package:staccato_api_server/models/family.dart';
import 'package:staccato_api_server/models/family_member_summary.dart';
import 'package:staccato_api_server/models/family_with_members_response.dart';
import 'package:staccato_api_server/models/user.dart';
import 'package:test/test.dart';

void main() {
  group('FamilyWithMembersResponse', () {
    /// Sample valid family with members response data for testing successful operations.
    ///
    /// This data represents a typical response with family information and member summaries. Used as a baseline for
    /// most tests.
    late Map<String, dynamic> validResponseJson;

    /// Sample FamilyWithMembersResponse instance created from valid data.
    ///
    /// This instance is used for testing methods that operate on existing FamilyWithMembersResponse objects, such as
    /// computed properties and toJson.
    late FamilyWithMembersResponse validResponse;

    /// Sample Family instance for testing.
    ///
    /// This instance represents the family information part of the response.
    late Family sampleFamily;

    /// Sample list of FamilyMemberSummary instances for testing.
    ///
    /// This list represents the members part of the response with different permission levels.
    late List<FamilyMemberSummary> sampleMembers;

    /// Set up test data before each test.
    ///
    /// Creates fresh instances of test data to ensure test isolation and prevent interference between tests. All test
    /// data represents valid response information unless specifically testing error conditions.
    setUp(() {
      sampleFamily = Family(
        id: 'family_123',
        name: 'The Smith Family',
        primaryUserId: 'user_primary',
        settings: const FamilySettings(
          timezone: 'America/New_York',
        ),
        createdAt: DateTime.parse('2025-01-10T14:30:00.000Z'),
        updatedAt: DateTime.parse('2025-01-10T15:00:00.000Z'),
      );

      sampleMembers = [
        const FamilyMemberSummary(
          id: 'user_primary',
          displayName: 'John Smith',
          permissionLevel: UserPermissionLevel.primary,
          profileImageUrl: 'https://example.com/john.jpg',
        ),
        const FamilyMemberSummary(
          id: 'user_adult',
          displayName: 'Jane Smith',
          permissionLevel: UserPermissionLevel.adult,
          profileImageUrl: 'https://example.com/jane.jpg',
        ),
        const FamilyMemberSummary(
          id: 'user_child1',
          displayName: 'Alice Smith',
          permissionLevel: UserPermissionLevel.child,
        ),
        const FamilyMemberSummary(
          id: 'user_child2',
          displayName: 'Bob Smith',
          permissionLevel: UserPermissionLevel.child,
        ),
      ];

      validResponse = FamilyWithMembersResponse(
        family: sampleFamily,
        members: sampleMembers,
      );

      validResponseJson = <String, dynamic>{
        'family': sampleFamily.toJson(),
        'members': sampleMembers.map((FamilyMemberSummary member) => member.toJson()).toList(),
      };
    });

    group('constructor', () {
      /// Verifies that the FamilyWithMembersResponse constructor properly assigns all provided values.
      ///
      /// This test ensures that all constructor parameters are correctly stored as instance fields and that the object
      /// is properly initialized with the expected values.
      test('should create FamilyWithMembersResponse with all provided values', () {
        final FamilyWithMembersResponse response = FamilyWithMembersResponse(
          family: sampleFamily,
          members: sampleMembers,
        );

        expect(response.family, equals(sampleFamily));
        expect(response.members, equals(sampleMembers));
      });

      /// Verifies that the constructor works with empty member lists.
      ///
      /// This test ensures that the FamilyWithMembersResponse constructor works correctly when provided with an empty
      /// member list.
      test('should create FamilyWithMembersResponse with empty member list', () {
        final FamilyWithMembersResponse response = FamilyWithMembersResponse(
          family: sampleFamily,
          members: const <FamilyMemberSummary>[],
        );

        expect(response.family, equals(sampleFamily));
        expect(response.members, isEmpty);
        expect(response.memberCount, equals(0));
      });
    });

    group('computed properties', () {
      /// Tests the memberCount property.
      ///
      /// This test verifies that the memberCount getter correctly returns the number of family members.
      test('should return correct member count', () {
        expect(validResponse.memberCount, equals(4));

        final FamilyWithMembersResponse emptyResponse = FamilyWithMembersResponse(
          family: sampleFamily,
          members: const <FamilyMemberSummary>[],
        );
        expect(emptyResponse.memberCount, equals(0));
      });

      /// Tests the isAtMemberLimit property.
      ///
      /// This test verifies that the isAtMemberLimit getter correctly identifies when the family has reached its
      /// maximum member limit.
      test('should return correct isAtMemberLimit value', () {
        // Current family has 4 members, limit is 10
        expect(validResponse.isAtMemberLimit, isFalse);

        // Create family at limit
        final Family familyAtLimit = sampleFamily.copyWith(
          settings: const FamilySettings(maxFamilyMembers: 4),
        );
        final FamilyWithMembersResponse responseAtLimit = FamilyWithMembersResponse(
          family: familyAtLimit,
          members: sampleMembers,
        );
        expect(responseAtLimit.isAtMemberLimit, isTrue);

        // Create family over limit
        final Family familyOverLimit = sampleFamily.copyWith(
          settings: const FamilySettings(maxFamilyMembers: 3),
        );
        final FamilyWithMembersResponse responseOverLimit = FamilyWithMembersResponse(
          family: familyOverLimit,
          members: sampleMembers,
        );
        expect(responseOverLimit.isAtMemberLimit, isTrue);
      });

      /// Tests the adultMembers property.
      ///
      /// This test verifies that the adultMembers getter correctly filters and returns only members with adult-level
      /// permissions.
      test('should return correct adult members', () {
        final List<FamilyMemberSummary> adultMembers = validResponse.adultMembers;

        expect(adultMembers, hasLength(2));
        expect(adultMembers.any((FamilyMemberSummary member) => member.id == 'user_primary'), isTrue);
        expect(adultMembers.any((FamilyMemberSummary member) => member.id == 'user_adult'), isTrue);
        expect(
          adultMembers.any((FamilyMemberSummary member) => member.permissionLevel == UserPermissionLevel.child),
          isFalse,
        );
      });

      /// Tests the childMembers property.
      ///
      /// This test verifies that the childMembers getter correctly filters and returns only members with child
      /// permission level.
      test('should return correct child members', () {
        final List<FamilyMemberSummary> childMembers = validResponse.childMembers;

        expect(childMembers, hasLength(2));
        expect(childMembers.any((FamilyMemberSummary member) => member.id == 'user_child1'), isTrue);
        expect(childMembers.any((FamilyMemberSummary member) => member.id == 'user_child2'), isTrue);
        expect(
          childMembers.every((FamilyMemberSummary member) => member.permissionLevel == UserPermissionLevel.child),
          isTrue,
        );
      });

      /// Tests the primaryMember property.
      ///
      /// This test verifies that the primaryMember getter correctly identifies and returns the primary administrator of
      /// the family.
      test('should return correct primary member', () {
        final FamilyMemberSummary? primaryMember = validResponse.primaryMember;

        expect(primaryMember, isNotNull);
        expect(primaryMember!.id, equals('user_primary'));
        expect(primaryMember.permissionLevel, equals(UserPermissionLevel.primary));
        expect(primaryMember.displayName, equals('John Smith'));
      });

      /// Tests the primaryMember property when primary user is not in members list.
      ///
      /// This test verifies that the primaryMember getter returns null when the primary user ID doesn't match any
      /// member in the list (which would indicate a data consistency issue).
      test('should return null when primary member not found in members list', () {
        final Family familyWithMissingPrimary = sampleFamily.copyWith(
          primaryUserId: 'user_missing',
        );
        final FamilyWithMembersResponse responseWithMissingPrimary = FamilyWithMembersResponse(
          family: familyWithMissingPrimary,
          members: sampleMembers,
        );

        expect(responseWithMissingPrimary.primaryMember, isNull);
      });
    });

    group('fromJson', () {
      /// Tests successful JSON deserialization with all fields present.
      ///
      /// This test verifies that the fromJson factory constructor correctly parses a complete JSON object and creates a
      /// FamilyWithMembersResponse instance with all fields properly populated and typed.
      test('should create FamilyWithMembersResponse from valid JSON with all fields', () {
        final FamilyWithMembersResponse response = FamilyWithMembersResponse.fromJson(validResponseJson);

        expect(response.family.id, equals('family_123'));
        expect(response.family.name, equals('The Smith Family'));
        expect(response.members, hasLength(4));
        expect(response.members.first.id, equals('user_primary'));
        expect(response.members.first.displayName, equals('John Smith'));
      });

      /// Tests JSON deserialization with empty members list.
      ///
      /// This test ensures that the fromJson constructor works correctly when the members list is empty.
      test('should create FamilyWithMembersResponse from JSON with empty members list', () {
        final Map<String, dynamic> jsonWithEmptyMembers = <String, dynamic>{
          'family': sampleFamily.toJson(),
          'members': <Map<String, dynamic>>[],
        };

        final FamilyWithMembersResponse response = FamilyWithMembersResponse.fromJson(jsonWithEmptyMembers);

        expect(response.family, equals(sampleFamily));
        expect(response.members, isEmpty);
        expect(response.memberCount, equals(0));
      });

      group('error handling', () {
        /// Tests that missing required fields throw appropriate errors.
        ///
        /// This test ensures that the fromJson constructor validates all required fields and throws descriptive
        /// ArgumentError exceptions when required data is missing.
        test('should throw ArgumentError for missing required fields', () {
          final List<String> requiredFields = ['family', 'members'];

          for (final String field in requiredFields) {
            final Map<String, dynamic> incompleteJson = Map<String, dynamic>.from(validResponseJson)..remove(field);

            expect(
              () => FamilyWithMembersResponse.fromJson(incompleteJson),
              throwsA(
                isA<FormatException>().having(
                  (FormatException e) => e.message,
                  'message',
                  contains('Missing required field: $field'),
                ),
              ),
              reason: 'Should throw FormatException for missing $field',
            );
          }
        });

        /// Tests that null values for required fields throw errors.
        ///
        /// This test verifies that explicitly null values for required fields are properly detected and result in
        /// appropriate error messages.
        test('should throw ArgumentError for null required fields', () {
          final List<String> requiredFields = ['family', 'members'];

          for (final String field in requiredFields) {
            final Map<String, dynamic> nullJson = Map<String, dynamic>.from(validResponseJson);
            nullJson[field] = null;

            expect(
              () => FamilyWithMembersResponse.fromJson(nullJson),
              throwsA(
                isA<FormatException>().having(
                  (FormatException e) => e.message,
                  'message',
                  contains('Missing required field: $field'),
                ),
              ),
              reason: 'Should throw FormatException for null $field',
            );
          }
        });

        /// Tests that invalid family data throws appropriate errors.
        ///
        /// This test ensures that malformed family objects are properly handled and result in descriptive errors.
        test('should throw FormatException for invalid family data', () {
          final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validResponseJson);
          invalidJson['family'] = <String, dynamic>{
            'id': 'family_123',
            // Missing required fields
          };

          expect(
            () => FamilyWithMembersResponse.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Failed to parse FamilyWithMembersResponse from JSON'),
              ),
            ),
          );
        });

        /// Tests that invalid member data throws appropriate errors.
        ///
        /// This test ensures that malformed member objects are properly handled and result in descriptive errors.
        test('should throw FormatException for invalid member data', () {
          final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validResponseJson);
          invalidJson['members'] = [
            <String, dynamic>{
              'id': 'user_123',
              // Missing required fields
            },
          ];

          expect(
            () => FamilyWithMembersResponse.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Failed to parse FamilyWithMembersResponse from JSON'),
              ),
            ),
          );
        });
      });
    });

    group('toJson', () {
      /// Tests successful JSON serialization with all fields present.
      ///
      /// This test verifies that the toJson method correctly converts a FamilyWithMembersResponse instance to a JSON
      /// map with all fields properly formatted and typed.
      test('should convert FamilyWithMembersResponse to JSON with all fields', () {
        final Map<String, dynamic> json = validResponse.toJson();

        expect(json['family'], isA<Map<String, dynamic>>());
        expect(json['members'], isA<List<dynamic>>());
        expect(json['memberCount'], equals(4));
        expect(json['isAtMemberLimit'], isFalse);

        // Verify family data
        final Map<String, dynamic> familyJson = json['family'] as Map<String, dynamic>;
        expect(familyJson['id'], equals('family_123'));
        expect(familyJson['name'], equals('The Smith Family'));

        // Verify members data
        final List<dynamic> membersJson = json['members'] as List<dynamic>;
        expect(membersJson, hasLength(4));
        expect(membersJson.first, isA<Map<String, dynamic>>());
      });

      /// Tests JSON serialization with empty members list.
      ///
      /// This test ensures that the toJson method properly handles responses with empty member lists.
      test('should convert FamilyWithMembersResponse to JSON with empty members list', () {
        final FamilyWithMembersResponse emptyResponse = FamilyWithMembersResponse(
          family: sampleFamily,
          members: const <FamilyMemberSummary>[],
        );

        final Map<String, dynamic> json = emptyResponse.toJson();

        expect(json['family'], isA<Map<String, dynamic>>());
        expect(json['members'], isEmpty);
        expect(json['memberCount'], equals(0));
        expect(json['isAtMemberLimit'], isFalse);
      });

      /// Tests that JSON serialization produces expected structure.
      ///
      /// This test verifies that the JSON output contains all expected fields with correct types and can be used for
      /// round-trip serialization.
      test('should produce expected JSON structure', () {
        final Map<String, dynamic> json = validResponse.toJson();

        // Verify all expected fields are present
        expect(json, contains('family'));
        expect(json, contains('members'));
        expect(json, containsPair('memberCount', 4));
        expect(json, containsPair('isAtMemberLimit', false));

        // Verify data types
        expect(json['family'], isA<Map<String, dynamic>>());
        expect(json['members'], isA<List<dynamic>>());
        expect(json['memberCount'], isA<int>());
        expect(json['isAtMemberLimit'], isA<bool>());
      });

      /// Tests round-trip serialization (toJson -> fromJson).
      ///
      /// This test verifies that a FamilyWithMembersResponse instance can be serialized to JSON and then deserialized
      /// back to an equivalent FamilyWithMembersResponse instance without data loss.
      test('should support round-trip serialization', () {
        final Map<String, dynamic> json = validResponse.toJson();
        final FamilyWithMembersResponse deserializedResponse = FamilyWithMembersResponse.fromJson(json);

        expect(deserializedResponse.family, equals(validResponse.family));
        expect(deserializedResponse.members, equals(validResponse.members));
        expect(deserializedResponse.memberCount, equals(validResponse.memberCount));
        expect(deserializedResponse.isAtMemberLimit, equals(validResponse.isAtMemberLimit));
      });
    });

    group('copyWith', () {
      /// Tests that copyWith creates a new instance with updated fields.
      ///
      /// This test verifies that the copyWith method correctly creates a new FamilyWithMembersResponse instance with
      /// specified fields updated while preserving all other field values.
      test('should create new FamilyWithMembersResponse with updated fields', () {
        final Family newFamily = sampleFamily.copyWith(name: 'Updated Family Name');
        final List<FamilyMemberSummary> newMembers = [sampleMembers.first];

        final FamilyWithMembersResponse updatedResponse = validResponse.copyWith(
          family: newFamily,
          members: newMembers,
        );

        expect(updatedResponse.family, equals(newFamily));
        expect(updatedResponse.members, equals(newMembers));
        expect(updatedResponse.memberCount, equals(1));
      });

      /// Tests that copyWith preserves original values when no updates provided.
      ///
      /// This test ensures that calling copyWith without parameters creates an identical copy of the original
      /// FamilyWithMembersResponse instance.
      test('should preserve original values when no updates provided', () {
        final FamilyWithMembersResponse copiedResponse = validResponse.copyWith();

        expect(copiedResponse.family, equals(validResponse.family));
        expect(copiedResponse.members, equals(validResponse.members));
        expect(identical(copiedResponse, validResponse), isFalse);
      });

      /// Tests that copyWith can update individual fields independently.
      ///
      /// This test verifies that each field can be updated independently without affecting other fields, ensuring
      /// proper isolation of changes.
      test('should update individual fields independently', () {
        final Family newFamily = sampleFamily.copyWith(name: 'New Family Name');
        final FamilyWithMembersResponse updatedFamily = validResponse.copyWith(family: newFamily);

        final List<FamilyMemberSummary> newMembers = [sampleMembers.first, sampleMembers.last];
        final FamilyWithMembersResponse updatedMembers = validResponse.copyWith(members: newMembers);

        expect(updatedFamily.family, equals(newFamily));
        expect(updatedFamily.members, equals(validResponse.members));

        expect(updatedMembers.family, equals(validResponse.family));
        expect(updatedMembers.members, equals(newMembers));
      });
    });

    group('withSortedMembers', () {
      /// Tests that withSortedMembers correctly sorts members by permission level and name.
      ///
      /// This test verifies that the withSortedMembers method properly sorts members according to the specified
      /// hierarchy: primary first, then adults, then children, with alphabetical sorting within each group.
      test('should sort members by permission level and display name', () {
        // Create unsorted members list
        final List<FamilyMemberSummary> unsortedMembers = [
          const FamilyMemberSummary(
            id: 'user_child2',
            displayName: 'Zoe Smith',
            permissionLevel: UserPermissionLevel.child,
          ),
          const FamilyMemberSummary(
            id: 'user_adult2',
            displayName: 'Alice Adult',
            permissionLevel: UserPermissionLevel.adult,
          ),
          const FamilyMemberSummary(
            id: 'user_primary',
            displayName: 'John Smith',
            permissionLevel: UserPermissionLevel.primary,
          ),
          const FamilyMemberSummary(
            id: 'user_child1',
            displayName: 'Bob Smith',
            permissionLevel: UserPermissionLevel.child,
          ),
          const FamilyMemberSummary(
            id: 'user_adult1',
            displayName: 'Jane Adult',
            permissionLevel: UserPermissionLevel.adult,
          ),
        ];

        final FamilyWithMembersResponse unsortedResponse = FamilyWithMembersResponse(
          family: sampleFamily,
          members: unsortedMembers,
        );

        final FamilyWithMembersResponse sortedResponse = unsortedResponse.withSortedMembers();

        // Verify sorting order
        expect(sortedResponse.members, hasLength(5));

        // Primary should be first
        expect(sortedResponse.members[0].id, equals('user_primary'));
        expect(sortedResponse.members[0].permissionLevel, equals(UserPermissionLevel.primary));

        // Adults should be next, sorted alphabetically
        expect(sortedResponse.members[1].displayName, equals('Alice Adult'));
        expect(sortedResponse.members[1].permissionLevel, equals(UserPermissionLevel.adult));
        expect(sortedResponse.members[2].displayName, equals('Jane Adult'));
        expect(sortedResponse.members[2].permissionLevel, equals(UserPermissionLevel.adult));

        // Children should be last, sorted alphabetically
        expect(sortedResponse.members[3].displayName, equals('Bob Smith'));
        expect(sortedResponse.members[3].permissionLevel, equals(UserPermissionLevel.child));
        expect(sortedResponse.members[4].displayName, equals('Zoe Smith'));
        expect(sortedResponse.members[4].permissionLevel, equals(UserPermissionLevel.child));
      });

      /// Tests that withSortedMembers handles case-insensitive sorting.
      ///
      /// This test verifies that the sorting is case-insensitive for display names.
      test('should sort display names case-insensitively', () {
        final List<FamilyMemberSummary> membersWithMixedCase = [
          const FamilyMemberSummary(
            id: 'user_primary',
            displayName: 'John Smith',
            permissionLevel: UserPermissionLevel.primary,
          ),
          const FamilyMemberSummary(
            id: 'user_adult1',
            displayName: 'alice Adult',
            permissionLevel: UserPermissionLevel.adult,
          ),
          const FamilyMemberSummary(
            id: 'user_adult2',
            displayName: 'Bob Adult',
            permissionLevel: UserPermissionLevel.adult,
          ),
        ];

        final FamilyWithMembersResponse response = FamilyWithMembersResponse(
          family: sampleFamily,
          members: membersWithMixedCase,
        );

        final FamilyWithMembersResponse sortedResponse = response.withSortedMembers();

        // Primary first
        expect(sortedResponse.members[0].displayName, equals('John Smith'));
        // Adults sorted case-insensitively: alice comes before Bob
        expect(sortedResponse.members[1].displayName, equals('alice Adult'));
        expect(sortedResponse.members[2].displayName, equals('Bob Adult'));
      });

      /// Tests that withSortedMembers returns a new instance.
      ///
      /// This test verifies that the withSortedMembers method returns a new instance rather than modifying the
      /// original.
      test('should return new instance without modifying original', () {
        final FamilyWithMembersResponse sortedResponse = validResponse.withSortedMembers();

        expect(identical(sortedResponse, validResponse), isFalse);
        expect(sortedResponse.family, equals(validResponse.family));
        // Members order might be different, but content should be the same
        expect(sortedResponse.members.toSet(), equals(validResponse.members.toSet()));
      });
    });

    group('equality and hashCode', () {
      /// Tests that identical FamilyWithMembersResponse instances are considered equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyWithMembersResponse instances with
      /// identical field values as equal.
      test('should consider FamilyWithMembersResponses with identical values as equal', () {
        final FamilyWithMembersResponse response1 = FamilyWithMembersResponse(
          family: sampleFamily,
          members: sampleMembers,
        );

        final FamilyWithMembersResponse response2 = FamilyWithMembersResponse(
          family: sampleFamily,
          members: sampleMembers,
        );

        expect(response1, equals(response2));
        expect(response1.hashCode, equals(response2.hashCode));
      });

      /// Tests that FamilyWithMembersResponse instances with different values are not equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyWithMembersResponse instances with
      /// different field values as not equal.
      test('should consider FamilyWithMembersResponses with different values as not equal', () {
        final FamilyWithMembersResponse response1 = validResponse;
        final FamilyWithMembersResponse response2 = validResponse.copyWith(
          members: [sampleMembers.first],
        );

        expect(response1, isNot(equals(response2)));
        expect(response1.hashCode, isNot(equals(response2.hashCode)));
      });

      /// Tests that a FamilyWithMembersResponse instance is equal to itself.
      ///
      /// This test verifies the reflexive property of equality, ensuring that any FamilyWithMembersResponse instance is
      /// equal to itself.
      test('should be equal to itself', () {
        expect(validResponse, equals(validResponse));
        expect(validResponse.hashCode, equals(validResponse.hashCode));
      });

      /// Tests that FamilyWithMembersResponse instances with empty member lists handle equality correctly.
      ///
      /// This test ensures that equality comparison works correctly when member lists are empty.
      test('should handle empty member lists in equality comparison', () {
        final FamilyWithMembersResponse emptyResponse1 = FamilyWithMembersResponse(
          family: sampleFamily,
          members: const <FamilyMemberSummary>[],
        );

        final FamilyWithMembersResponse emptyResponse2 = FamilyWithMembersResponse(
          family: sampleFamily,
          members: const <FamilyMemberSummary>[],
        );

        expect(emptyResponse1, equals(emptyResponse2));
        expect(emptyResponse1.hashCode, equals(emptyResponse2.hashCode));
      });
    });

    group('toString', () {
      /// Tests that toString produces a readable string representation.
      ///
      /// This test verifies that the toString method produces a properly formatted string containing all field values
      /// for debugging purposes.
      test('should produce readable string representation', () {
        final String stringRepresentation = validResponse.toString();

        expect(stringRepresentation, contains('FamilyWithMembersResponse('));
        expect(stringRepresentation, contains('family: '));
        expect(stringRepresentation, contains('members: '));
        expect(stringRepresentation, contains('memberCount: 4'));
      });

      /// Tests that toString handles empty member lists correctly.
      ///
      /// This test ensures that the toString method properly displays empty member lists without causing errors.
      test('should handle empty member lists in string representation', () {
        final FamilyWithMembersResponse emptyResponse = FamilyWithMembersResponse(
          family: sampleFamily,
          members: const <FamilyMemberSummary>[],
        );

        final String stringRepresentation = emptyResponse.toString();

        expect(stringRepresentation, contains('memberCount: 0'));
        expect(stringRepresentation, contains('members: []'));
      });
    });

    group('member filtering and organization', () {
      /// Tests various member filtering scenarios.
      ///
      /// This test verifies that the member filtering properties work correctly with different member compositions.
      test('should handle various member compositions correctly', () {
        // Family with only primary user
        final List<FamilyMemberSummary> primaryOnlyMembers = [
          const FamilyMemberSummary(
            id: 'user_primary',
            displayName: 'John Smith',
            permissionLevel: UserPermissionLevel.primary,
          ),
        ];

        final FamilyWithMembersResponse primaryOnlyResponse = FamilyWithMembersResponse(
          family: sampleFamily,
          members: primaryOnlyMembers,
        );

        expect(primaryOnlyResponse.memberCount, equals(1));
        expect(primaryOnlyResponse.adultMembers, hasLength(1));
        expect(primaryOnlyResponse.childMembers, isEmpty);
        expect(primaryOnlyResponse.primaryMember, isNotNull);

        // Family with only children
        final List<FamilyMemberSummary> childrenOnlyMembers = [
          const FamilyMemberSummary(
            id: 'user_child1',
            displayName: 'Alice Smith',
            permissionLevel: UserPermissionLevel.child,
          ),
          const FamilyMemberSummary(
            id: 'user_child2',
            displayName: 'Bob Smith',
            permissionLevel: UserPermissionLevel.child,
          ),
        ];

        final Family familyWithChildPrimary = sampleFamily.copyWith(
          primaryUserId: 'user_missing', // Primary not in member list
        );

        final FamilyWithMembersResponse childrenOnlyResponse = FamilyWithMembersResponse(
          family: familyWithChildPrimary,
          members: childrenOnlyMembers,
        );

        expect(childrenOnlyResponse.memberCount, equals(2));
        expect(childrenOnlyResponse.adultMembers, isEmpty);
        expect(childrenOnlyResponse.childMembers, hasLength(2));
        expect(childrenOnlyResponse.primaryMember, isNull);
      });
    });
  });
}
