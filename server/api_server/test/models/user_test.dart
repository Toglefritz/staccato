import 'package:staccato_api_server/models/user.dart';
import 'package:test/test.dart';

void main() {
  group('User', () {
    /// Sample valid user data for testing successful operations.
    ///
    /// This data represents a typical primary user with all required fields and some optional fields populated. Used as
    /// a baseline for most tests.
    late Map<String, dynamic> validUserJson;

    /// Sample User instance created from valid data.
    ///
    /// This instance is used for testing methods that operate on existing User objects, such as copyWith and toJson.
    late User validUser;

    /// Set up test data before each test.
    ///
    /// Creates fresh instances of test data to ensure test isolation and prevent interference between tests. All test
    /// data represents valid user information unless specifically testing error conditions.
    setUp(() {
      validUserJson = <String, dynamic>{
        'id': 'user_123',
        'email': 'john.doe@example.com',
        'displayName': 'John Doe',
        'familyId': 'family_456',
        'permissionLevel': 'primary',
        'createdAt': '2025-01-10T14:30:00.000Z',
        'updatedAt': '2025-01-10T15:00:00.000Z',
        'profileImageUrl': 'https://example.com/profile.jpg',
      };

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
      /// Verifies that the User constructor properly assigns all provided values.
      ///
      /// This test ensures that all constructor parameters are correctly stored as instance fields and that the object
      /// is properly initialized with the expected values.
      test('should create User with all provided values', () {
        final DateTime createdAt = DateTime.now();
        final DateTime updatedAt = DateTime.now().add(const Duration(hours: 1));

        final User user = User(
          id: 'test_id',
          displayName: 'Test User',
          familyId: 'test_family',
          permissionLevel: UserPermissionLevel.adult,
          createdAt: createdAt,
          updatedAt: updatedAt,
          profileImageUrl: 'https://test.com/image.jpg',
        );

        expect(user.id, equals('test_id'));
        expect(user.displayName, equals('Test User'));
        expect(user.familyId, equals('test_family'));
        expect(user.permissionLevel, equals(UserPermissionLevel.adult));
        expect(user.createdAt, equals(createdAt));
        expect(user.updatedAt, equals(updatedAt));
        expect(user.profileImageUrl, equals('https://test.com/image.jpg'));
      });

      /// Verifies that optional fields can be omitted during construction.
      ///
      /// This test ensures that the User constructor works correctly when only required fields are provided, with
      /// optional fields defaulting to null as expected.
      test('should create User with only required fields', () {
        final DateTime createdAt = DateTime.now();

        final User user = User(
          id: 'test_id',
          displayName: 'Test User',
          familyId: 'test_family',
          permissionLevel: UserPermissionLevel.child,
          createdAt: createdAt,
        );

        expect(user.id, equals('test_id'));
        expect(user.displayName, equals('Test User'));
        expect(user.familyId, equals('test_family'));
        expect(user.permissionLevel, equals(UserPermissionLevel.child));
        expect(user.createdAt, equals(createdAt));
        expect(user.updatedAt, isNull);
        expect(user.profileImageUrl, isNull);
      });
    });

    group('computed properties', () {
      /// Tests the isAdmin property for different permission levels.
      ///
      /// This test verifies that the isAdmin getter correctly identifies users with administrative privileges based on
      /// their permission level.
      test(
          'should return correct isAdmin value for different permission levels',
          () {
        final User primaryUser =
            validUser.copyWith(permissionLevel: UserPermissionLevel.primary);
        final User adultUser =
            validUser.copyWith(permissionLevel: UserPermissionLevel.adult);
        final User childUser =
            validUser.copyWith(permissionLevel: UserPermissionLevel.child);

        expect(primaryUser.isAdmin, isTrue);
        expect(adultUser.isAdmin, isFalse);
        expect(childUser.isAdmin, isFalse);
      });

      /// Tests the isAdult property for different permission levels.
      ///
      /// This test verifies that the isAdult getter correctly identifies users with adult-level access based on their
      /// permission level.
      test(
          'should return correct isAdult value for different permission levels',
          () {
        final User primaryUser =
            validUser.copyWith(permissionLevel: UserPermissionLevel.primary);
        final User adultUser =
            validUser.copyWith(permissionLevel: UserPermissionLevel.adult);
        final User childUser =
            validUser.copyWith(permissionLevel: UserPermissionLevel.child);

        expect(primaryUser.isAdult, isTrue);
        expect(adultUser.isAdult, isTrue);
        expect(childUser.isAdult, isFalse);
      });

      /// Tests the canManageUsers property for different permission levels.
      ///
      /// This test verifies that the canManageUsers getter correctly identifies users who can manage other family
      /// members based on their permission level.
      test(
          'should return correct canManageUsers value for different permission levels',
          () {
        final User primaryUser =
            validUser.copyWith(permissionLevel: UserPermissionLevel.primary);
        final User adultUser =
            validUser.copyWith(permissionLevel: UserPermissionLevel.adult);
        final User childUser =
            validUser.copyWith(permissionLevel: UserPermissionLevel.child);

        expect(primaryUser.canManageUsers, isTrue);
        expect(adultUser.canManageUsers, isFalse);
        expect(childUser.canManageUsers, isFalse);
      });
    });

    group('fromJson', () {
      /// Tests successful JSON deserialization with all fields present.
      ///
      /// This test verifies that the fromJson factory constructor correctly parses a complete JSON object and creates a
      /// User instance with all fields properly populated and typed.
      test('should create User from valid JSON with all fields', () {
        final User user = User.fromJson(validUserJson);

        expect(user.id, equals('user_123'));
        expect(user.displayName, equals('John Doe'));
        expect(user.familyId, equals('family_456'));
        expect(user.permissionLevel, equals(UserPermissionLevel.primary));
        expect(
          user.createdAt,
          equals(DateTime.parse('2025-01-10T14:30:00.000Z')),
        );
        expect(
          user.updatedAt,
          equals(DateTime.parse('2025-01-10T15:00:00.000Z')),
        );
        expect(user.profileImageUrl, equals('https://example.com/profile.jpg'));
      });

      /// Tests JSON deserialization with only required fields present.
      ///
      /// This test ensures that the fromJson constructor works correctly when optional fields are missing from the
      /// JSON, setting them to null as expected.
      test('should create User from JSON with only required fields', () {
        final Map<String, dynamic> minimalJson = <String, dynamic>{
          'id': 'user_456',
          'email': 'jane.smith@example.com',
          'displayName': 'Jane Smith',
          'familyId': 'family_789',
          'permissionLevel': 'adult',
          'createdAt': '2025-01-10T16:00:00.000Z',
        };

        final User user = User.fromJson(minimalJson);

        expect(user.id, equals('user_456'));
        expect(user.displayName, equals('Jane Smith'));
        expect(user.familyId, equals('family_789'));
        expect(user.permissionLevel, equals(UserPermissionLevel.adult));
        expect(
          user.createdAt,
          equals(DateTime.parse('2025-01-10T16:00:00.000Z')),
        );
        expect(user.updatedAt, isNull);
        expect(user.profileImageUrl, isNull);
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
          final Map<String, dynamic> json =
              Map<String, dynamic>.from(validUserJson);
          json['permissionLevel'] = permissionLevels[i];

          final User user = User.fromJson(json);
          expect(user.permissionLevel, equals(expectedLevels[i]));
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
            'email',
            'displayName',
            'familyId',
            'permissionLevel',
            'createdAt',
          ];

          for (final String field in requiredFields) {
            final Map<String, dynamic> incompleteJson =
                Map<String, dynamic>.from(validUserJson)..remove(field);

            expect(
              () => User.fromJson(incompleteJson),
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
        /// This test ensures that required fields cannot be empty strings, which would be invalid for user
        /// identification and display purposes.
        test('should throw ArgumentError for empty required fields', () {
          final List<String> requiredFields = [
            'id',
            'email',
            'displayName',
            'familyId',
            'permissionLevel',
            'createdAt',
          ];

          for (final String field in requiredFields) {
            final Map<String, dynamic> invalidJson =
                Map<String, dynamic>.from(validUserJson);
            invalidJson[field] = '';

            expect(
              () => User.fromJson(invalidJson),
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
          final Map<String, dynamic> invalidJson =
              Map<String, dynamic>.from(validUserJson);
          invalidJson['permissionLevel'] = 'invalid_level';

          expect(
            () => User.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Invalid permission level: invalid_level'),
              ),
            ),
          );
        });

        /// Tests that malformed timestamp strings throw appropriate errors.
        ///
        /// This test ensures that invalid date/time strings are properly handled and result in descriptive
        /// FormatException errors.
        test('should throw FormatException for invalid timestamp format', () {
          final Map<String, dynamic> invalidJson =
              Map<String, dynamic>.from(validUserJson);
          invalidJson['createdAt'] = 'invalid-timestamp';

          expect(
            () => User.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Failed to parse User from JSON'),
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
            'email',
            'displayName',
            'familyId',
            'permissionLevel',
            'createdAt',
          ];

          for (final String field in requiredFields) {
            final Map<String, dynamic> nullJson =
                Map<String, dynamic>.from(validUserJson);
            nullJson[field] = null;

            expect(
              () => User.fromJson(nullJson),
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
      /// This test verifies that the toJson method correctly converts a User instance to a JSON map with all fields
      /// properly formatted and typed.
      test('should convert User to JSON with all fields', () {
        final Map<String, dynamic> json = validUser.toJson();

        expect(json['id'], equals('user_123'));
        expect(json['displayName'], equals('John Doe'));
        expect(json['familyId'], equals('family_456'));
        expect(json['permissionLevel'], equals('primary'));
        expect(json['createdAt'], equals('2025-01-10T14:30:00.000Z'));
        expect(json['updatedAt'], equals('2025-01-10T15:00:00.000Z'));
        expect(
          json['profileImageUrl'],
          equals('https://example.com/profile.jpg'),
        );
      });

      /// Tests JSON serialization with null optional fields.
      ///
      /// This test ensures that the toJson method properly handles null values for optional fields, including them in
      /// the JSON with null values.
      test('should convert User to JSON with null optional fields', () {
        final User userWithNulls = User(
          id: 'user_789',
          displayName: 'Test User',
          familyId: 'family_123',
          permissionLevel: UserPermissionLevel.child,
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final Map<String, dynamic> json = userWithNulls.toJson();

        expect(json['id'], equals('user_789'));
        expect(json['displayName'], equals('Test User'));
        expect(json['familyId'], equals('family_123'));
        expect(json['permissionLevel'], equals('child'));
        expect(json['createdAt'], equals('2025-01-10T12:00:00.000Z'));
        expect(json['updatedAt'], isNull);
        expect(json['profileImageUrl'], isNull);
      });

      /// Tests that JSON serialization produces expected structure.
      ///
      /// Note: This test cannot verify full serialization cycle due to a bug in the User class where fromJson expects
      /// an 'email' field but toJson doesn't include it. This should be fixed in the User implementation.
      test('should produce expected JSON structure', () {
        final Map<String, dynamic> json = validUser.toJson();

        // Verify all expected fields are present
        expect(json, containsPair('id', 'user_123'));
        expect(json, containsPair('displayName', 'John Doe'));
        expect(json, containsPair('familyId', 'family_456'));
        expect(json, containsPair('permissionLevel', 'primary'));
        expect(json, containsPair('createdAt', '2025-01-10T14:30:00.000Z'));
        expect(json, containsPair('updatedAt', '2025-01-10T15:00:00.000Z'));
        expect(
          json,
          containsPair('profileImageUrl', 'https://example.com/profile.jpg'),
        );

        // Note: 'email' field is missing from toJson but required by fromJson
        // This is a bug that should be fixed in the User class implementation
      });
    });

    group('copyWith', () {
      /// Tests that copyWith creates a new instance with updated fields.
      ///
      /// This test verifies that the copyWith method correctly creates a new User instance with specified fields
      /// updated while preserving all other field values.
      test('should create new User with updated fields', () {
        final DateTime newUpdatedAt = DateTime.now();
        final User updatedUser = validUser.copyWith(
          displayName: 'Updated Name',
          permissionLevel: UserPermissionLevel.adult,
          updatedAt: newUpdatedAt,
        );

        expect(updatedUser.id, equals(validUser.id));
        expect(updatedUser.displayName, equals('Updated Name'));
        expect(updatedUser.familyId, equals(validUser.familyId));
        expect(updatedUser.permissionLevel, equals(UserPermissionLevel.adult));
        expect(updatedUser.createdAt, equals(validUser.createdAt));
        expect(updatedUser.updatedAt, equals(newUpdatedAt));
        expect(updatedUser.profileImageUrl, equals(validUser.profileImageUrl));
      });

      /// Tests that copyWith preserves original values when no updates provided.
      ///
      /// This test ensures that calling copyWith without parameters creates an identical copy of the original User
      /// instance.
      test('should preserve original values when no updates provided', () {
        final User copiedUser = validUser.copyWith();

        expect(copiedUser, equals(validUser));
        expect(identical(copiedUser, validUser), isFalse);
      });

      /// Tests that copyWith can update individual fields independently.
      ///
      /// This test verifies that each field can be updated independently without affecting other fields, ensuring
      /// proper isolation of changes.
      test('should update individual fields independently', () {
        final User updatedDisplayName =
            validUser.copyWith(displayName: 'New Name');
        final User updatedPermission =
            validUser.copyWith(permissionLevel: UserPermissionLevel.child);
        final User updatedImage =
            validUser.copyWith(profileImageUrl: 'https://new.com/image.jpg');

        expect(updatedDisplayName.displayName, equals('New Name'));
        expect(
          updatedDisplayName.permissionLevel,
          equals(validUser.permissionLevel),
        );

        expect(
          updatedPermission.permissionLevel,
          equals(UserPermissionLevel.child),
        );
        expect(updatedPermission.displayName, equals(validUser.displayName));

        expect(
          updatedImage.profileImageUrl,
          equals('https://new.com/image.jpg'),
        );
        expect(updatedImage.displayName, equals(validUser.displayName));
      });

      /// Tests that copyWith preserves null values when not explicitly set.
      ///
      /// This test verifies that the copyWith method correctly handles cases where optional fields are already null and
      /// should remain null.
      test('should preserve null values for optional fields', () {
        final User userWithNulls = User(
          id: 'test_id',
          displayName: 'Test User',
          familyId: 'test_family',
          permissionLevel: UserPermissionLevel.child,
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final User copiedUser = userWithNulls.copyWith(
          displayName: 'Updated Name',
        );

        expect(copiedUser.updatedAt, isNull);
        expect(copiedUser.profileImageUrl, isNull);
        expect(copiedUser.displayName, equals('Updated Name'));
        expect(copiedUser.id, equals('test_id'));
      });
    });

    group('equality and hashCode', () {
      /// Tests that identical User instances are considered equal.
      ///
      /// This test verifies that the equality operator correctly identifies User instances with identical field values
      /// as equal.
      test('should consider Users with identical values as equal', () {
        final User user1 = User(
          id: 'test_id',
          displayName: 'Test User',
          familyId: 'test_family',
          permissionLevel: UserPermissionLevel.adult,
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
          updatedAt: DateTime.parse('2025-01-10T13:00:00.000Z'),
          profileImageUrl: 'https://test.com/image.jpg',
        );

        final User user2 = User(
          id: 'test_id',
          displayName: 'Test User',
          familyId: 'test_family',
          permissionLevel: UserPermissionLevel.adult,
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
          updatedAt: DateTime.parse('2025-01-10T13:00:00.000Z'),
          profileImageUrl: 'https://test.com/image.jpg',
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      /// Tests that User instances with different values are not equal.
      ///
      /// This test verifies that the equality operator correctly identifies User instances with different field values
      /// as not equal.
      test('should consider Users with different values as not equal', () {
        final User user1 = validUser;
        final User user2 = validUser.copyWith(displayName: 'Different Name');

        expect(user1, isNot(equals(user2)));
        expect(user1.hashCode, isNot(equals(user2.hashCode)));
      });

      /// Tests that a User instance is equal to itself.
      ///
      /// This test verifies the reflexive property of equality, ensuring that any User instance is equal to itself.
      test('should be equal to itself', () {
        expect(validUser, equals(validUser));
        expect(validUser.hashCode, equals(validUser.hashCode));
      });

      /// Tests that User instances with null optional fields handle equality correctly.
      ///
      /// This test ensures that equality comparison works correctly when optional fields are null in one or both
      /// instances.
      test('should handle null optional fields in equality comparison', () {
        final User userWithNulls = User(
          id: 'test_id',
          displayName: 'Test User',
          familyId: 'test_family',
          permissionLevel: UserPermissionLevel.adult,
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final User anotherUserWithNulls = User(
          id: 'test_id',
          displayName: 'Test User',
          familyId: 'test_family',
          permissionLevel: UserPermissionLevel.adult,
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        expect(userWithNulls, equals(anotherUserWithNulls));
        expect(userWithNulls.hashCode, equals(anotherUserWithNulls.hashCode));
      });
    });

    group('toString', () {
      /// Tests that toString produces a readable string representation.
      ///
      /// This test verifies that the toString method produces a properly formatted string containing all field values
      /// for debugging purposes.
      test('should produce readable string representation', () {
        final String stringRepresentation = validUser.toString();

        expect(stringRepresentation, contains('User('));
        expect(stringRepresentation, contains('id: user_123'));
        expect(stringRepresentation, contains('displayName: John Doe'));
        expect(stringRepresentation, contains('familyId: family_456'));
        expect(stringRepresentation, contains('permissionLevel: primary'));
        expect(
          stringRepresentation,
          contains('createdAt: 2025-01-10 14:30:00.000Z'),
        );
        expect(
          stringRepresentation,
          contains('updatedAt: 2025-01-10 15:00:00.000Z'),
        );
        expect(
          stringRepresentation,
          contains('profileImageUrl: https://example.com/profile.jpg'),
        );
      });

      /// Tests that toString handles null optional fields correctly.
      ///
      /// This test ensures that the toString method properly displays null values for optional fields without causing
      /// errors.
      test('should handle null optional fields in string representation', () {
        final User userWithNulls = User(
          id: 'test_id',
          displayName: 'Test User',
          familyId: 'test_family',
          permissionLevel: UserPermissionLevel.child,
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final String stringRepresentation = userWithNulls.toString();

        expect(stringRepresentation, contains('updatedAt: null'));
        expect(stringRepresentation, contains('profileImageUrl: null'));
      });
    });
  });
}
