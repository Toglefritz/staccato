import 'package:staccato_api_server/models/family.dart';
import 'package:test/test.dart';

void main() {
  group('Family', () {
    /// Sample valid family data for testing successful operations.
    ///
    /// This data represents a typical family with all required fields and some optional fields populated. Used as a
    /// baseline for most tests.
    late Map<String, dynamic> validFamilyJson;

    /// Sample Family instance created from valid data.
    ///
    /// This instance is used for testing methods that operate on existing Family objects, such as copyWith and toJson.
    late Family validFamily;

    /// Sample valid family settings data for testing.
    ///
    /// This data represents typical family settings with various configuration options.
    late Map<String, dynamic> validSettingsJson;

    /// Set up test data before each test.
    ///
    /// Creates fresh instances of test data to ensure test isolation and prevent interference between tests. All test
    /// data represents valid family information unless specifically testing error conditions.
    setUp(() {
      validSettingsJson = <String, dynamic>{
        'timezone': 'America/New_York',
        'allowChildRegistration': true,
        'requireTaskApproval': false,
        'enableNotifications': true,
        'allowGuestAccess': false,
        'maxFamilyMembers': 8,
        'defaultChildPermissions': <String>['view_calendar', 'complete_tasks'],
        'enableLocationSharing': false,
        'requireParentalApproval': true,
      };

      validFamilyJson = <String, dynamic>{
        'id': 'family_123',
        'name': 'The Smith Family',
        'primaryUserId': 'user_456',
        'settings': validSettingsJson,
        'createdAt': '2025-01-10T14:30:00.000Z',
        'updatedAt': '2025-01-10T15:00:00.000Z',
      };

      validFamily = Family(
        id: 'family_123',
        name: 'The Smith Family',
        primaryUserId: 'user_456',
        settings: FamilySettings.fromJson(validSettingsJson),
        createdAt: DateTime.parse('2025-01-10T14:30:00.000Z'),
        updatedAt: DateTime.parse('2025-01-10T15:00:00.000Z'),
      );
    });

    group('constructor', () {
      /// Verifies that the Family constructor properly assigns all provided values.
      ///
      /// This test ensures that all constructor parameters are correctly stored as instance fields and that the object
      /// is properly initialized with the expected values.
      test('should create Family with all provided values', () {
        final DateTime createdAt = DateTime.now();
        final DateTime updatedAt = DateTime.now().add(const Duration(hours: 1));
        final FamilySettings settings = FamilySettings.fromJson(validSettingsJson);

        final Family family = Family(
          id: 'test_id',
          name: 'Test Family',
          primaryUserId: 'user_123',
          settings: settings,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(family.id, equals('test_id'));
        expect(family.name, equals('Test Family'));
        expect(family.primaryUserId, equals('user_123'));
        expect(family.settings, equals(settings));
        expect(family.createdAt, equals(createdAt));
        expect(family.updatedAt, equals(updatedAt));
      });

      /// Verifies that optional fields can be omitted during construction.
      ///
      /// This test ensures that the Family constructor works correctly when only required fields are provided, with
      /// optional fields defaulting to null as expected.
      test('should create Family with only required fields', () {
        final DateTime createdAt = DateTime.now();
        final FamilySettings settings = FamilySettings.fromJson(validSettingsJson);

        final Family family = Family(
          id: 'test_id',
          name: 'Test Family',
          primaryUserId: 'user_123',
          settings: settings,
          createdAt: createdAt,
        );

        expect(family.id, equals('test_id'));
        expect(family.name, equals('Test Family'));
        expect(family.primaryUserId, equals('user_123'));
        expect(family.settings, equals(settings));
        expect(family.createdAt, equals(createdAt));
        expect(family.updatedAt, isNull);
      });
    });

    group('fromJson', () {
      /// Tests successful JSON deserialization with all fields present.
      ///
      /// This test verifies that the fromJson factory constructor correctly parses a complete JSON object and creates a
      /// Family instance with all fields properly populated and typed.
      test('should create Family from valid JSON with all fields', () {
        final Family family = Family.fromJson(validFamilyJson);

        expect(family.id, equals('family_123'));
        expect(family.name, equals('The Smith Family'));
        expect(family.primaryUserId, equals('user_456'));
        expect(family.settings.timezone, equals('America/New_York'));
        expect(family.settings.maxFamilyMembers, equals(8));
        expect(
          family.createdAt,
          equals(DateTime.parse('2025-01-10T14:30:00.000Z')),
        );
        expect(
          family.updatedAt,
          equals(DateTime.parse('2025-01-10T15:00:00.000Z')),
        );
      });

      /// Tests JSON deserialization with only required fields present.
      ///
      /// This test ensures that the fromJson constructor works correctly when optional fields are missing from the
      /// JSON, setting them to null as expected.
      test('should create Family from JSON with only required fields', () {
        final Map<String, dynamic> minimalJson = <String, dynamic>{
          'id': 'family_456',
          'name': 'The Johnson Family',
          'primaryUserId': 'user_789',
          'settings': <String, dynamic>{
            'timezone': 'UTC',
            'allowChildRegistration': true,
            'requireTaskApproval': false,
            'enableNotifications': true,
            'allowGuestAccess': false,
            'maxFamilyMembers': 10,
            'defaultChildPermissions': <String>[],
            'enableLocationSharing': false,
            'requireParentalApproval': true,
          },
          'createdAt': '2025-01-10T16:00:00.000Z',
        };

        final Family family = Family.fromJson(minimalJson);

        expect(family.id, equals('family_456'));
        expect(family.name, equals('The Johnson Family'));
        expect(family.primaryUserId, equals('user_789'));
        expect(family.settings.timezone, equals('UTC'));
        expect(
          family.createdAt,
          equals(DateTime.parse('2025-01-10T16:00:00.000Z')),
        );
        expect(family.updatedAt, isNull);
      });

      group('error handling', () {
        /// Tests that missing required fields throw appropriate errors.
        ///
        /// This test ensures that the fromJson constructor validates all required fields and throws descriptive
        /// ArgumentError exceptions when required data is missing.
        test('should throw ArgumentError for missing required fields', () {
          final List<String> requiredFields = [
            'id',
            'name',
            'primaryUserId',
            'settings',
            'createdAt',
          ];

          for (final String field in requiredFields) {
            final Map<String, dynamic> incompleteJson = Map<String, dynamic>.from(validFamilyJson)..remove(field);

            expect(
              () => Family.fromJson(incompleteJson),
              throwsA(
                isA<FormatException>().having(
                  (FormatException e) => e.message,
                  'message',
                  contains('Missing'),
                ),
              ),
              reason: 'Should throw FormatException for missing $field',
            );
          }
        });

        /// Tests that empty string values for required fields throw errors.
        ///
        /// This test ensures that required fields cannot be empty strings, which would be invalid for family
        /// identification and display purposes.
        test('should throw ArgumentError for empty required fields', () {
          final List<String> stringFields = ['id', 'name', 'primaryUserId', 'createdAt'];

          for (final String field in stringFields) {
            final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validFamilyJson);
            invalidJson[field] = '';

            expect(
              () => Family.fromJson(invalidJson),
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

        /// Tests that malformed timestamp strings throw appropriate errors.
        ///
        /// This test ensures that invalid date/time strings are properly handled and result in descriptive
        /// FormatException errors.
        test('should throw FormatException for invalid timestamp format', () {
          final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validFamilyJson);
          invalidJson['createdAt'] = 'invalid-timestamp';

          expect(
            () => Family.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Failed to parse Family from JSON'),
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
            'name',
            'primaryUserId',
            'settings',
            'createdAt',
          ];

          for (final String field in requiredFields) {
            final Map<String, dynamic> nullJson = Map<String, dynamic>.from(validFamilyJson);
            nullJson[field] = null;

            expect(
              () => Family.fromJson(nullJson),
              throwsA(
                isA<FormatException>().having(
                  (FormatException e) => e.message,
                  'message',
                  contains('Missing'),
                ),
              ),
              reason: 'Should throw FormatException for null $field',
            );
          }
        });

        /// Tests that invalid settings data throws appropriate errors.
        ///
        /// This test ensures that malformed settings objects are properly handled and result in descriptive errors.
        test('should throw FormatException for invalid settings', () {
          final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validFamilyJson);
          invalidJson['settings'] = <String, dynamic>{
            'maxFamilyMembers': -1, // Invalid value
          };

          expect(
            () => Family.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Failed to parse Family from JSON'),
              ),
            ),
          );
        });
      });
    });

    group('toJson', () {
      /// Tests successful JSON serialization with all fields present.
      ///
      /// This test verifies that the toJson method correctly converts a Family instance to a JSON map with all fields
      /// properly formatted and typed.
      test('should convert Family to JSON with all fields', () {
        final Map<String, dynamic> json = validFamily.toJson();

        expect(json['id'], equals('family_123'));
        expect(json['name'], equals('The Smith Family'));
        expect(json['primaryUserId'], equals('user_456'));
        expect(json['settings'], isA<Map<String, dynamic>>());
        expect(json['createdAt'], equals('2025-01-10T14:30:00.000Z'));
        expect(json['updatedAt'], equals('2025-01-10T15:00:00.000Z'));

        // Verify settings are properly serialized
        final Map<String, dynamic> settingsJson = json['settings'] as Map<String, dynamic>;
        expect(settingsJson['timezone'], equals('America/New_York'));
        expect(settingsJson['maxFamilyMembers'], equals(8));
      });

      /// Tests JSON serialization with null optional fields.
      ///
      /// This test ensures that the toJson method properly handles null values for optional fields, including them in
      /// the JSON with null values.
      test('should convert Family to JSON with null optional fields', () {
        final Family familyWithNulls = Family(
          id: 'family_789',
          name: 'Test Family',
          primaryUserId: 'user_123',
          settings: FamilySettings.fromJson(validSettingsJson),
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final Map<String, dynamic> json = familyWithNulls.toJson();

        expect(json['id'], equals('family_789'));
        expect(json['name'], equals('Test Family'));
        expect(json['primaryUserId'], equals('user_123'));
        expect(json['settings'], isA<Map<String, dynamic>>());
        expect(json['createdAt'], equals('2025-01-10T12:00:00.000Z'));
        expect(json['updatedAt'], isNull);
      });

      /// Tests that JSON serialization produces expected structure.
      ///
      /// This test verifies that the JSON output contains all expected fields with correct types and can be used for
      /// round-trip serialization.
      test('should produce expected JSON structure', () {
        final Map<String, dynamic> json = validFamily.toJson();

        // Verify all expected fields are present
        expect(json, containsPair('id', 'family_123'));
        expect(json, containsPair('name', 'The Smith Family'));
        expect(json, containsPair('primaryUserId', 'user_456'));
        expect(json, contains('settings'));
        expect(json, containsPair('createdAt', '2025-01-10T14:30:00.000Z'));
        expect(json, containsPair('updatedAt', '2025-01-10T15:00:00.000Z'));

        // Verify settings structure
        final Map<String, dynamic> settingsJson = json['settings'] as Map<String, dynamic>;
        expect(settingsJson, isA<Map<String, dynamic>>());
        expect(settingsJson, contains('timezone'));
        expect(settingsJson, contains('maxFamilyMembers'));
      });

      /// Tests round-trip serialization (toJson -> fromJson).
      ///
      /// This test verifies that a Family instance can be serialized to JSON and then deserialized back to an
      /// equivalent Family instance without data loss.
      test('should support round-trip serialization', () {
        final Map<String, dynamic> json = validFamily.toJson();
        final Family deserializedFamily = Family.fromJson(json);

        expect(deserializedFamily, equals(validFamily));
      });
    });

    group('copyWith', () {
      /// Tests that copyWith creates a new instance with updated fields.
      ///
      /// This test verifies that the copyWith method correctly creates a new Family instance with specified fields
      /// updated while preserving all other field values.
      test('should create new Family with updated fields', () {
        final DateTime newUpdatedAt = DateTime.now();
        final FamilySettings newSettings = FamilySettings(timezone: 'America/Los_Angeles');

        final Family updatedFamily = validFamily.copyWith(
          name: 'Updated Family Name',
          settings: newSettings,
          updatedAt: newUpdatedAt,
        );

        expect(updatedFamily.id, equals(validFamily.id));
        expect(updatedFamily.name, equals('Updated Family Name'));
        expect(updatedFamily.primaryUserId, equals(validFamily.primaryUserId));
        expect(updatedFamily.settings, equals(newSettings));
        expect(updatedFamily.createdAt, equals(validFamily.createdAt));
        expect(updatedFamily.updatedAt, equals(newUpdatedAt));
      });

      /// Tests that copyWith preserves original values when no updates provided.
      ///
      /// This test ensures that calling copyWith without parameters creates an identical copy of the original Family
      /// instance.
      test('should preserve original values when no updates provided', () {
        final Family copiedFamily = validFamily.copyWith();

        expect(copiedFamily, equals(validFamily));
        expect(identical(copiedFamily, validFamily), isFalse);
      });

      /// Tests that copyWith can update individual fields independently.
      ///
      /// This test verifies that each field can be updated independently without affecting other fields, ensuring
      /// proper isolation of changes.
      test('should update individual fields independently', () {
        final Family updatedName = validFamily.copyWith(name: 'New Name');
        final Family updatedPrimary = validFamily.copyWith(primaryUserId: 'user_999');
        final FamilySettings newSettings = FamilySettings();
        final Family updatedSettings = validFamily.copyWith(settings: newSettings);

        expect(updatedName.name, equals('New Name'));
        expect(updatedName.primaryUserId, equals(validFamily.primaryUserId));

        expect(updatedPrimary.primaryUserId, equals('user_999'));
        expect(updatedPrimary.name, equals(validFamily.name));

        expect(updatedSettings.settings, equals(newSettings));
        expect(updatedSettings.name, equals(validFamily.name));
      });

      /// Tests that copyWith preserves null values when not explicitly set.
      ///
      /// This test verifies that the copyWith method correctly handles cases where optional fields are already null and
      /// should remain null.
      test('should preserve null values for optional fields', () {
        final Family familyWithNulls = Family(
          id: 'test_id',
          name: 'Test Family',
          primaryUserId: 'user_123',
          settings: FamilySettings.fromJson(validSettingsJson),
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final Family copiedFamily = familyWithNulls.copyWith(
          name: 'Updated Name',
        );

        expect(copiedFamily.updatedAt, isNull);
        expect(copiedFamily.name, equals('Updated Name'));
        expect(copiedFamily.id, equals('test_id'));
      });
    });

    group('equality and hashCode', () {
      /// Tests that identical Family instances are considered equal.
      ///
      /// This test verifies that the equality operator correctly identifies Family instances with identical field
      /// values as equal.
      test('should consider Families with identical values as equal', () {
        final FamilySettings settings = FamilySettings.fromJson(validSettingsJson);
        final DateTime createdAt = DateTime.parse('2025-01-10T12:00:00.000Z');
        final DateTime updatedAt = DateTime.parse('2025-01-10T13:00:00.000Z');

        final Family family1 = Family(
          id: 'test_id',
          name: 'Test Family',
          primaryUserId: 'user_123',
          settings: settings,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        final Family family2 = Family(
          id: 'test_id',
          name: 'Test Family',
          primaryUserId: 'user_123',
          settings: settings,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

        expect(family1, equals(family2));
        expect(family1.hashCode, equals(family2.hashCode));
      });

      /// Tests that Family instances with different values are not equal.
      ///
      /// This test verifies that the equality operator correctly identifies Family instances with different field
      /// values as not equal.
      test('should consider Families with different values as not equal', () {
        final Family family1 = validFamily;
        final Family family2 = validFamily.copyWith(name: 'Different Name');

        expect(family1, isNot(equals(family2)));
        expect(family1.hashCode, isNot(equals(family2.hashCode)));
      });

      /// Tests that a Family instance is equal to itself.
      ///
      /// This test verifies the reflexive property of equality, ensuring that any Family instance is equal to itself.
      test('should be equal to itself', () {
        expect(validFamily, equals(validFamily));
        expect(validFamily.hashCode, equals(validFamily.hashCode));
      });

      /// Tests that Family instances with null optional fields handle equality correctly.
      ///
      /// This test ensures that equality comparison works correctly when optional fields are null in one or both
      /// instances.
      test('should handle null optional fields in equality comparison', () {
        final FamilySettings settings = FamilySettings.fromJson(validSettingsJson);

        final Family familyWithNulls = Family(
          id: 'test_id',
          name: 'Test Family',
          primaryUserId: 'user_123',
          settings: settings,
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final Family anotherFamilyWithNulls = Family(
          id: 'test_id',
          name: 'Test Family',
          primaryUserId: 'user_123',
          settings: settings,
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        expect(familyWithNulls, equals(anotherFamilyWithNulls));
        expect(familyWithNulls.hashCode, equals(anotherFamilyWithNulls.hashCode));
      });
    });

    group('toString', () {
      /// Tests that toString produces a readable string representation.
      ///
      /// This test verifies that the toString method produces a properly formatted string containing all field values
      /// for debugging purposes.
      test('should produce readable string representation', () {
        final String stringRepresentation = validFamily.toString();

        expect(stringRepresentation, contains('Family('));
        expect(stringRepresentation, contains('id: family_123'));
        expect(stringRepresentation, contains('name: The Smith Family'));
        expect(stringRepresentation, contains('primaryUserId: user_456'));
        expect(stringRepresentation, contains('settings: '));
        expect(
          stringRepresentation,
          contains('createdAt: 2025-01-10 14:30:00.000Z'),
        );
        expect(
          stringRepresentation,
          contains('updatedAt: 2025-01-10 15:00:00.000Z'),
        );
      });

      /// Tests that toString handles null optional fields correctly.
      ///
      /// This test ensures that the toString method properly displays null values for optional fields without causing
      /// errors.
      test('should handle null optional fields in string representation', () {
        final Family familyWithNulls = Family(
          id: 'test_id',
          name: 'Test Family',
          primaryUserId: 'user_123',
          settings: FamilySettings.fromJson(validSettingsJson),
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final String stringRepresentation = familyWithNulls.toString();

        expect(stringRepresentation, contains('updatedAt: null'));
      });
    });
  });
}
