import 'package:staccato_api_server/models/family_member_summary.dart';
import 'package:staccato_api_server/models/user.dart';
import 'package:test/test.dart';

void main() {
  group('FamilyMemberSummary', () {
    /// Sample valid family member summary data for testing successful operations.
    ///
    /// This data represents a typical member summary with all fields populated. Used as a baseline for most tests.
    late Map<String, dynamic> validMemberJson;

    /// Sample FamilyMemberSummary instance created from valid data.
    ///
    /// This instance is used for testing methods that operate on existing FamilyMemberSummary objects, such as
    /// copyWith and toJson.
    late FamilyMemberSummary validMember;

    /// Sample User instance for testing fromUser factory constructor.
    ///
    /// This instance is used to test the conversion from full User objects to lightweight member summaries.
    late User validUser;

    /// Set up test data before each test.
    ///
    /// Creates fresh instances of test data to ensure test isolation and prevent interference between tests. All test
    /// data represents valid member information unless specifically testing error conditions.
    setUp(() {
      validMemberJson = <String, dynamic>{
        'id': 'user_123',
        'displayName': 'John Doe',
        'permissionLevel': 'primary',
        'profileImageUrl': 'https://example.com/profile.jpg',
      };

      validMember = FamilyMemberSummary(
        id: 'user_123',
        displayName: 'John Doe',
        permissionLevel: UserPermissionLevel.primary,
        profileImageUrl: 'https://example.com/profile.jpg',
      );

      validUser = User(
        id: 'user_123',
        displayName: 'John Doe',
        familyId: 'family_456',
        permissionLevel: UserPermissionLevel.primary,
        createdAt: DateTime.parse('2025-01-10T14:30:00.000Z'),
        updatedAt: DateTime.parse('2025-01-10T15:00:00.000Z'),
        profileImageUrl: 'https://example.com/profile.jpg',
      );
    });

    group('constructor', () {
      /// Verifies that the FamilyMemberSummary constructor properly assigns all provided values.
      ///
      /// This test ensures that all constructor parameters are correctly stored as instance fields and that the object
      /// is properly initialized with the expected values.
      test('should create FamilyMemberSummary with all provided values', () {
        final FamilyMemberSummary member = FamilyMemberSummary(
          id: 'test_id',
          displayName: 'Test User',
          permissionLevel: UserPermissionLevel.adult,
          profileImageUrl: 'https://test.com/image.jpg',
        );

        expect(member.id, equals('test_id'));
        expect(member.displayName, equals('Test User'));
        expect(member.permissionLevel, equals(UserPermissionLevel.adult));
        expect(member.profileImageUrl, equals('https://test.com/image.jpg'));
      });

      /// Verifies that optional fields can be omitted during construction.
      ///
      /// This test ensures that the FamilyMemberSummary constructor works correctly when only required fields are
      /// provided, with optional fields defaulting to null as expected.
      test('should create FamilyMemberSummary with only required fields', () {
        final FamilyMemberSummary member = FamilyMemberSummary(
          id: 'test_id',
          displayName: 'Test User',
          permissionLevel: UserPermissionLevel.child,
        );

        expect(member.id, equals('test_id'));
        expect(member.displayName, equals('Test User'));
        expect(member.permissionLevel, equals(UserPermissionLevel.child));
        expect(member.profileImageUrl, isNull);
      });
    });

    group('computed properties', () {
      /// Tests the isAdmin property for different permission levels.
      ///
      /// This test verifies that the isAdmin getter correctly identifies members with administrative privileges based
      /// on their permission level.
      test('should return correct isAdmin value for different permission levels', () {
        final FamilyMemberSummary primaryMember = validMember.copyWith(
          permissionLevel: UserPermissionLevel.primary,
        );
        final FamilyMemberSummary adultMember = validMember.copyWith(
          permissionLevel: UserPermissionLevel.adult,
        );
        final FamilyMemberSummary childMember = validMember.copyWith(
          permissionLevel: UserPermissionLevel.child,
        );

        expect(primaryMember.isAdmin, isTrue);
        expect(adultMember.isAdmin, isFalse);
        expect(childMember.isAdmin, isFalse);
      });

      /// Tests the isAdult property for different permission levels.
      ///
      /// This test verifies that the isAdult getter correctly identifies members with adult-level access based on their
      /// permission level.
      test('should return correct isAdult value for different permission levels', () {
        final FamilyMemberSummary primaryMember = validMember.copyWith(
          permissionLevel: UserPermissionLevel.primary,
        );
        final FamilyMemberSummary adultMember = validMember.copyWith(
          permissionLevel: UserPermissionLevel.adult,
        );
        final FamilyMemberSummary childMember = validMember.copyWith(
          permissionLevel: UserPermissionLevel.child,
        );

        expect(primaryMember.isAdult, isTrue);
        expect(adultMember.isAdult, isTrue);
        expect(childMember.isAdult, isFalse);
      });

      /// Tests the canManageUsers property for different permission levels.
      ///
      /// This test verifies that the canManageUsers getter correctly identifies members who can manage other family
      /// members based on their permission level.
      test('should return correct canManageUsers value for different permission levels', () {
        final FamilyMemberSummary primaryMember = validMember.copyWith(
          permissionLevel: UserPermissionLevel.primary,
        );
        final FamilyMemberSummary adultMember = validMember.copyWith(
          permissionLevel: UserPermissionLevel.adult,
        );
        final FamilyMemberSummary childMember = validMember.copyWith(
          permissionLevel: UserPermissionLevel.child,
        );

        expect(primaryMember.canManageUsers, isTrue);
        expect(adultMember.canManageUsers, isFalse);
        expect(childMember.canManageUsers, isFalse);
      });
    });

    group('fromUser', () {
      /// Tests successful creation from a full User instance.
      ///
      /// This test verifies that the fromUser factory constructor correctly extracts the essential information from a
      /// complete User model to create a lightweight summary.
      test('should create FamilyMemberSummary from User with all fields', () {
        final FamilyMemberSummary member = FamilyMemberSummary.fromUser(validUser);

        expect(member.id, equals(validUser.id));
        expect(member.displayName, equals(validUser.displayName));
        expect(member.permissionLevel, equals(validUser.permissionLevel));
        expect(member.profileImageUrl, equals(validUser.profileImageUrl));
      });

      /// Tests creation from User with null optional fields.
      ///
      /// This test ensures that the fromUser constructor correctly handles User instances where optional fields are
      /// null.
      test('should create FamilyMemberSummary from User with null optional fields', () {
        final User userWithNulls = User(
          id: 'user_456',
          displayName: 'Jane Smith',
          familyId: 'family_789',
          permissionLevel: UserPermissionLevel.adult,
          createdAt: DateTime.parse('2025-01-10T16:00:00.000Z'),
        );

        final FamilyMemberSummary member = FamilyMemberSummary.fromUser(userWithNulls);

        expect(member.id, equals('user_456'));
        expect(member.displayName, equals('Jane Smith'));
        expect(member.permissionLevel, equals(UserPermissionLevel.adult));
        expect(member.profileImageUrl, isNull);
      });

      /// Tests creation from User with different permission levels.
      ///
      /// This test verifies that all permission levels are correctly preserved when converting from User to
      /// FamilyMemberSummary.
      test('should preserve permission levels correctly', () {
        final List<UserPermissionLevel> permissionLevels = [
          UserPermissionLevel.primary,
          UserPermissionLevel.adult,
          UserPermissionLevel.child,
        ];

        for (final UserPermissionLevel level in permissionLevels) {
          final User user = validUser.copyWith(permissionLevel: level);
          final FamilyMemberSummary member = FamilyMemberSummary.fromUser(user);

          expect(member.permissionLevel, equals(level));
        }
      });
    });

    group('fromJson', () {
      /// Tests successful JSON deserialization with all fields present.
      ///
      /// This test verifies that the fromJson factory constructor correctly parses a complete JSON object and creates a
      /// FamilyMemberSummary instance with all fields properly populated and typed.
      test('should create FamilyMemberSummary from valid JSON with all fields', () {
        final FamilyMemberSummary member = FamilyMemberSummary.fromJson(validMemberJson);

        expect(member.id, equals('user_123'));
        expect(member.displayName, equals('John Doe'));
        expect(member.permissionLevel, equals(UserPermissionLevel.primary));
        expect(member.profileImageUrl, equals('https://example.com/profile.jpg'));
      });

      /// Tests JSON deserialization with only required fields present.
      ///
      /// This test ensures that the fromJson constructor works correctly when optional fields are missing from the
      /// JSON, setting them to null as expected.
      test('should create FamilyMemberSummary from JSON with only required fields', () {
        final Map<String, dynamic> minimalJson = <String, dynamic>{
          'id': 'user_456',
          'displayName': 'Jane Smith',
          'permissionLevel': 'adult',
        };

        final FamilyMemberSummary member = FamilyMemberSummary.fromJson(minimalJson);

        expect(member.id, equals('user_456'));
        expect(member.displayName, equals('Jane Smith'));
        expect(member.permissionLevel, equals(UserPermissionLevel.adult));
        expect(member.profileImageUrl, isNull);
      });

      /// Tests JSON deserialization with different permission levels.
      ///
      /// This test verifies that all valid permission level strings are correctly parsed and converted to the
      /// appropriate enum values.
      test('should handle different permission levels correctly', () {
        final List<String> permissionLevels = ['primary', 'adult', 'child'];
        final List<UserPermissionLevel> expectedLevels = [
          UserPermissionLevel.primary,
          UserPermissionLevel.adult,
          UserPermissionLevel.child,
        ];

        for (int i = 0; i < permissionLevels.length; i++) {
          final Map<String, dynamic> json = Map<String, dynamic>.from(validMemberJson);
          json['permissionLevel'] = permissionLevels[i];

          final FamilyMemberSummary member = FamilyMemberSummary.fromJson(json);
          expect(member.permissionLevel, equals(expectedLevels[i]));
        }
      });

      group('error handling', () {
        /// Tests that missing required fields throw appropriate errors.
        ///
        /// This test ensures that the fromJson constructor validates all required fields and throws descriptive
        /// ArgumentError exceptions when required data is missing.
        test('should throw ArgumentError for missing required fields', () {
          final List<String> requiredFields = [
            'id',
            'displayName',
            'permissionLevel',
          ];

          for (final String field in requiredFields) {
            final Map<String, dynamic> incompleteJson = Map<String, dynamic>.from(validMemberJson)..remove(field);

            expect(
              () => FamilyMemberSummary.fromJson(incompleteJson),
              throwsA(
                isA<FormatException>().having(
                  (FormatException e) => e.message,
                  'message',
                  contains('Missing or empty required field: $field'),
                ),
              ),
              reason: 'Should throw FormatException for missing $field',
            );
          }
        });

        /// Tests that empty string values for required fields throw errors.
        ///
        /// This test ensures that required fields cannot be empty strings, which would be invalid for member
        /// identification and display purposes.
        test('should throw ArgumentError for empty required fields', () {
          final List<String> requiredFields = [
            'id',
            'displayName',
            'permissionLevel',
          ];

          for (final String field in requiredFields) {
            final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validMemberJson);
            invalidJson[field] = '';

            expect(
              () => FamilyMemberSummary.fromJson(invalidJson),
              throwsA(
                isA<FormatException>().having(
                  (FormatException e) => e.message,
                  'message',
                  contains('Missing or empty required field: $field'),
                ),
              ),
              reason: 'Should throw FormatException for empty $field',
            );
          }
        });

        /// Tests that invalid permission levels throw appropriate errors.
        ///
        /// This test verifies that the fromJson constructor properly validates permission level values and throws
        /// descriptive errors for invalid values.
        test('should throw ArgumentError for invalid permission level', () {
          final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validMemberJson);
          invalidJson['permissionLevel'] = 'invalid_level';

          expect(
            () => FamilyMemberSummary.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Invalid permission level: invalid_level'),
              ),
            ),
          );
        });

        /// Tests that null values for required fields throw errors.
        ///
        /// This test verifies that explicitly null values for required fields are properly detected and result in
        /// appropriate error messages.
        test('should throw ArgumentError for null required fields', () {
          final List<String> requiredFields = [
            'id',
            'displayName',
            'permissionLevel',
          ];

          for (final String field in requiredFields) {
            final Map<String, dynamic> nullJson = Map<String, dynamic>.from(validMemberJson);
            nullJson[field] = null;

            expect(
              () => FamilyMemberSummary.fromJson(nullJson),
              throwsA(
                isA<FormatException>().having(
                  (FormatException e) => e.message,
                  'message',
                  contains('Missing or empty required field: $field'),
                ),
              ),
              reason: 'Should throw FormatException for null $field',
            );
          }
        });
      });
    });

    group('toJson', () {
      /// Tests successful JSON serialization with all fields present.
      ///
      /// This test verifies that the toJson method correctly converts a FamilyMemberSummary instance to a JSON map
      /// with all fields properly formatted and typed.
      test('should convert FamilyMemberSummary to JSON with all fields', () {
        final Map<String, dynamic> json = validMember.toJson();

        expect(json['id'], equals('user_123'));
        expect(json['displayName'], equals('John Doe'));
        expect(json['permissionLevel'], equals('primary'));
        expect(json['profileImageUrl'], equals('https://example.com/profile.jpg'));
      });

      /// Tests JSON serialization with null optional fields.
      ///
      /// This test ensures that the toJson method properly handles null values for optional fields, including them in
      /// the JSON with null values.
      test('should convert FamilyMemberSummary to JSON with null optional fields', () {
        final FamilyMemberSummary memberWithNulls = FamilyMemberSummary(
          id: 'user_789',
          displayName: 'Test User',
          permissionLevel: UserPermissionLevel.child,
        );

        final Map<String, dynamic> json = memberWithNulls.toJson();

        expect(json['id'], equals('user_789'));
        expect(json['displayName'], equals('Test User'));
        expect(json['permissionLevel'], equals('child'));
        expect(json['profileImageUrl'], isNull);
      });

      /// Tests that JSON serialization produces expected structure.
      ///
      /// This test verifies that the JSON output contains all expected fields with correct types and can be used for
      /// round-trip serialization.
      test('should produce expected JSON structure', () {
        final Map<String, dynamic> json = validMember.toJson();

        // Verify all expected fields are present
        expect(json, containsPair('id', 'user_123'));
        expect(json, containsPair('displayName', 'John Doe'));
        expect(json, containsPair('permissionLevel', 'primary'));
        expect(json, containsPair('profileImageUrl', 'https://example.com/profile.jpg'));

        // Verify data types
        expect(json['id'], isA<String>());
        expect(json['displayName'], isA<String>());
        expect(json['permissionLevel'], isA<String>());
        expect(json['profileImageUrl'], isA<String>());
      });

      /// Tests round-trip serialization (toJson -> fromJson).
      ///
      /// This test verifies that a FamilyMemberSummary instance can be serialized to JSON and then deserialized back
      /// to an equivalent FamilyMemberSummary instance without data loss.
      test('should support round-trip serialization', () {
        final Map<String, dynamic> json = validMember.toJson();
        final FamilyMemberSummary deserializedMember = FamilyMemberSummary.fromJson(json);

        expect(deserializedMember, equals(validMember));
      });
    });

    group('copyWith', () {
      /// Tests that copyWith creates a new instance with updated fields.
      ///
      /// This test verifies that the copyWith method correctly creates a new FamilyMemberSummary instance with
      /// specified fields updated while preserving all other field values.
      test('should create new FamilyMemberSummary with updated fields', () {
        final FamilyMemberSummary updatedMember = validMember.copyWith(
          displayName: 'Updated Name',
          permissionLevel: UserPermissionLevel.adult,
          profileImageUrl: 'https://new.com/image.jpg',
        );

        expect(updatedMember.id, equals(validMember.id));
        expect(updatedMember.displayName, equals('Updated Name'));
        expect(updatedMember.permissionLevel, equals(UserPermissionLevel.adult));
        expect(updatedMember.profileImageUrl, equals('https://new.com/image.jpg'));
      });

      /// Tests that copyWith preserves original values when no updates provided.
      ///
      /// This test ensures that calling copyWith without parameters creates an identical copy of the original
      /// FamilyMemberSummary instance.
      test('should preserve original values when no updates provided', () {
        final FamilyMemberSummary copiedMember = validMember.copyWith();

        expect(copiedMember, equals(validMember));
        expect(identical(copiedMember, validMember), isFalse);
      });

      /// Tests that copyWith can update individual fields independently.
      ///
      /// This test verifies that each field can be updated independently without affecting other fields, ensuring
      /// proper isolation of changes.
      test('should update individual fields independently', () {
        final FamilyMemberSummary updatedName = validMember.copyWith(displayName: 'New Name');
        final FamilyMemberSummary updatedPermission = validMember.copyWith(
          permissionLevel: UserPermissionLevel.child,
        );
        final FamilyMemberSummary updatedImage = validMember.copyWith(
          profileImageUrl: 'https://new.com/image.jpg',
        );

        expect(updatedName.displayName, equals('New Name'));
        expect(updatedName.permissionLevel, equals(validMember.permissionLevel));

        expect(updatedPermission.permissionLevel, equals(UserPermissionLevel.child));
        expect(updatedPermission.displayName, equals(validMember.displayName));

        expect(updatedImage.profileImageUrl, equals('https://new.com/image.jpg'));
        expect(updatedImage.displayName, equals(validMember.displayName));
      });

      /// Tests that copyWith preserves null values when not explicitly set.
      ///
      /// This test verifies that the copyWith method correctly handles cases where optional fields are already null
      /// and should remain null.
      test('should preserve null values for optional fields', () {
        final FamilyMemberSummary memberWithNulls = FamilyMemberSummary(
          id: 'test_id',
          displayName: 'Test User',
          permissionLevel: UserPermissionLevel.child,
        );

        final FamilyMemberSummary copiedMember = memberWithNulls.copyWith(
          displayName: 'Updated Name',
        );

        expect(copiedMember.profileImageUrl, isNull);
        expect(copiedMember.displayName, equals('Updated Name'));
        expect(copiedMember.id, equals('test_id'));
      });

      /// Tests that copyWith preserves null values correctly.
      ///
      /// This test verifies that the copyWith method correctly handles members that already have null optional fields.
      test('should preserve null values correctly', () {
        final FamilyMemberSummary memberWithNulls = FamilyMemberSummary(
          id: 'test_id',
          displayName: 'Test User',
          permissionLevel: UserPermissionLevel.child,
        );

        final FamilyMemberSummary updatedMember = memberWithNulls.copyWith(
          displayName: 'Updated Name',
        );

        expect(updatedMember.profileImageUrl, isNull);
        expect(updatedMember.id, equals('test_id'));
        expect(updatedMember.displayName, equals('Updated Name'));
        expect(updatedMember.permissionLevel, equals(UserPermissionLevel.child));
      });
    });

    group('equality and hashCode', () {
      /// Tests that identical FamilyMemberSummary instances are considered equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyMemberSummary instances with
      /// identical field values as equal.
      test('should consider FamilyMemberSummaries with identical values as equal', () {
        final FamilyMemberSummary member1 = FamilyMemberSummary(
          id: 'test_id',
          displayName: 'Test User',
          permissionLevel: UserPermissionLevel.adult,
          profileImageUrl: 'https://test.com/image.jpg',
        );

        final FamilyMemberSummary member2 = FamilyMemberSummary(
          id: 'test_id',
          displayName: 'Test User',
          permissionLevel: UserPermissionLevel.adult,
          profileImageUrl: 'https://test.com/image.jpg',
        );

        expect(member1, equals(member2));
        expect(member1.hashCode, equals(member2.hashCode));
      });

      /// Tests that FamilyMemberSummary instances with different values are not equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyMemberSummary instances with
      /// different field values as not equal.
      test('should consider FamilyMemberSummaries with different values as not equal', () {
        final FamilyMemberSummary member1 = validMember;
        final FamilyMemberSummary member2 = validMember.copyWith(displayName: 'Different Name');

        expect(member1, isNot(equals(member2)));
        expect(member1.hashCode, isNot(equals(member2.hashCode)));
      });

      /// Tests that a FamilyMemberSummary instance is equal to itself.
      ///
      /// This test verifies the reflexive property of equality, ensuring that any FamilyMemberSummary instance is
      /// equal to itself.
      test('should be equal to itself', () {
        expect(validMember, equals(validMember));
        expect(validMember.hashCode, equals(validMember.hashCode));
      });

      /// Tests that FamilyMemberSummary instances with null optional fields handle equality correctly.
      ///
      /// This test ensures that equality comparison works correctly when optional fields are null in one or both
      /// instances.
      test('should handle null optional fields in equality comparison', () {
        final FamilyMemberSummary memberWithNulls = FamilyMemberSummary(
          id: 'test_id',
          displayName: 'Test User',
          permissionLevel: UserPermissionLevel.adult,
        );

        final FamilyMemberSummary anotherMemberWithNulls = FamilyMemberSummary(
          id: 'test_id',
          displayName: 'Test User',
          permissionLevel: UserPermissionLevel.adult,
        );

        expect(memberWithNulls, equals(anotherMemberWithNulls));
        expect(memberWithNulls.hashCode, equals(anotherMemberWithNulls.hashCode));
      });
    });

    group('toString', () {
      /// Tests that toString produces a readable string representation.
      ///
      /// This test verifies that the toString method produces a properly formatted string containing all field values
      /// for debugging purposes.
      test('should produce readable string representation', () {
        final String stringRepresentation = validMember.toString();

        expect(stringRepresentation, contains('FamilyMemberSummary('));
        expect(stringRepresentation, contains('id: user_123'));
        expect(stringRepresentation, contains('displayName: John Doe'));
        expect(stringRepresentation, contains('permissionLevel: primary'));
        expect(stringRepresentation, contains('profileImageUrl: https://example.com/profile.jpg'));
      });

      /// Tests that toString handles null optional fields correctly.
      ///
      /// This test ensures that the toString method properly displays null values for optional fields without causing
      /// errors.
      test('should handle null optional fields in string representation', () {
        final FamilyMemberSummary memberWithNulls = FamilyMemberSummary(
          id: 'test_id',
          displayName: 'Test User',
          permissionLevel: UserPermissionLevel.child,
        );

        final String stringRepresentation = memberWithNulls.toString();

        expect(stringRepresentation, contains('profileImageUrl: null'));
      });
    });

    group('integration with User model', () {
      /// Tests that FamilyMemberSummary correctly represents User data.
      ///
      /// This test verifies that the essential information from a User is properly preserved in the summary format.
      test('should preserve essential User information', () {
        final FamilyMemberSummary summary = FamilyMemberSummary.fromUser(validUser);

        // Essential fields should match
        expect(summary.id, equals(validUser.id));
        expect(summary.displayName, equals(validUser.displayName));
        expect(summary.permissionLevel, equals(validUser.permissionLevel));
        expect(summary.profileImageUrl, equals(validUser.profileImageUrl));

        // Computed properties should match
        expect(summary.isAdmin, equals(validUser.isAdmin));
        expect(summary.isAdult, equals(validUser.isAdult));
        expect(summary.canManageUsers, equals(validUser.canManageUsers));
      });

      /// Tests that FamilyMemberSummary can be created from Users with different permission levels.
      ///
      /// This test ensures that the summary correctly handles all permission levels and their associated properties.
      test('should handle all permission levels from User', () {
        final List<UserPermissionLevel> levels = [
          UserPermissionLevel.primary,
          UserPermissionLevel.adult,
          UserPermissionLevel.child,
        ];

        for (final UserPermissionLevel level in levels) {
          final User user = validUser.copyWith(permissionLevel: level);
          final FamilyMemberSummary summary = FamilyMemberSummary.fromUser(user);

          expect(summary.permissionLevel, equals(level));
          expect(summary.isAdmin, equals(level.isAdmin));
          expect(summary.isAdult, equals(level.isAdult));
          expect(summary.canManageUsers, equals(level.canManageUsers));
        }
      });
    });
  });
}
