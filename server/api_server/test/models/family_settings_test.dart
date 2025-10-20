import 'package:staccato_api_server/models/family.dart';
import 'package:test/test.dart';

void main() {
  group('FamilySettings', () {
    /// Sample valid family settings data for testing successful operations.
    ///
    /// This data represents typical family settings with various configuration options. Used as a baseline for most
    /// tests.
    late Map<String, dynamic> validSettingsJson;

    /// Sample FamilySettings instance created from valid data.
    ///
    /// This instance is used for testing methods that operate on existing FamilySettings objects, such as copyWith and
    /// toJson.
    late FamilySettings validSettings;

    /// Set up test data before each test.
    ///
    /// Creates fresh instances of test data to ensure test isolation and prevent interference between tests. All test
    /// data represents valid settings unless specifically testing error conditions.
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

      validSettings = FamilySettings(
        timezone: 'America/New_York',
        maxFamilyMembers: 8,
        defaultChildPermissions: const <String>['view_calendar', 'complete_tasks'],
      );
    });

    group('constructor', () {
      /// Verifies that the FamilySettings constructor properly assigns all provided values.
      ///
      /// This test ensures that all constructor parameters are correctly stored as instance fields and that the object
      /// is properly initialized with the expected values.
      test('should create FamilySettings with all provided values', () {
        final List<String> permissions = <String>['permission1', 'permission2'];

        final FamilySettings settings = FamilySettings(
          timezone: 'Europe/London',
          allowChildRegistration: false,
          requireTaskApproval: true,
          enableNotifications: false,
          allowGuestAccess: true,
          maxFamilyMembers: 12,
          defaultChildPermissions: permissions,
          enableLocationSharing: true,
          requireParentalApproval: false,
        );

        expect(settings.timezone, equals('Europe/London'));
        expect(settings.allowChildRegistration, isFalse);
        expect(settings.requireTaskApproval, isTrue);
        expect(settings.enableNotifications, isFalse);
        expect(settings.allowGuestAccess, isTrue);
        expect(settings.maxFamilyMembers, equals(12));
        expect(settings.defaultChildPermissions, equals(permissions));
        expect(settings.enableLocationSharing, isTrue);
        expect(settings.requireParentalApproval, isFalse);
      });

      /// Verifies that FamilySettings constructor uses proper defaults.
      ///
      /// This test ensures that the FamilySettings constructor applies sensible default values when no parameters are
      /// provided.
      test('should create FamilySettings with default values', () {
        const FamilySettings settings = FamilySettings();

        expect(settings.timezone, equals('UTC'));
        expect(settings.allowChildRegistration, isTrue);
        expect(settings.requireTaskApproval, isFalse);
        expect(settings.enableNotifications, isTrue);
        expect(settings.allowGuestAccess, isFalse);
        expect(settings.maxFamilyMembers, equals(10));
        expect(settings.defaultChildPermissions, isEmpty);
        expect(settings.enableLocationSharing, isFalse);
        expect(settings.requireParentalApproval, isTrue);
      });
    });

    group('fromJson', () {
      /// Tests successful JSON deserialization with all fields present.
      ///
      /// This test verifies that the fromJson factory constructor correctly parses a complete JSON object and creates a
      /// FamilySettings instance with all fields properly populated and typed.
      test('should create FamilySettings from valid JSON with all fields', () {
        final FamilySettings settings = FamilySettings.fromJson(validSettingsJson);

        expect(settings.timezone, equals('America/New_York'));
        expect(settings.allowChildRegistration, isTrue);
        expect(settings.requireTaskApproval, isFalse);
        expect(settings.enableNotifications, isTrue);
        expect(settings.allowGuestAccess, isFalse);
        expect(settings.maxFamilyMembers, equals(8));
        expect(
          settings.defaultChildPermissions,
          equals(<String>['view_calendar', 'complete_tasks']),
        );
        expect(settings.enableLocationSharing, isFalse);
        expect(settings.requireParentalApproval, isTrue);
      });

      /// Tests JSON deserialization with missing optional fields.
      ///
      /// This test ensures that the fromJson constructor works correctly when optional fields are missing from the
      /// JSON, applying default values as expected.
      test('should create FamilySettings from JSON with missing optional fields', () {
        final Map<String, dynamic> minimalJson = <String, dynamic>{
          'timezone': 'Europe/Paris',
        };

        final FamilySettings settings = FamilySettings.fromJson(minimalJson);

        expect(settings.timezone, equals('Europe/Paris'));
        expect(settings.allowChildRegistration, isTrue); // Default
        expect(settings.requireTaskApproval, isFalse); // Default
        expect(settings.enableNotifications, isTrue); // Default
        expect(settings.allowGuestAccess, isFalse); // Default
        expect(settings.maxFamilyMembers, equals(10)); // Default
        expect(settings.defaultChildPermissions, isEmpty); // Default
        expect(settings.enableLocationSharing, isFalse); // Default
        expect(settings.requireParentalApproval, isTrue); // Default
      });

      /// Tests JSON deserialization with empty JSON object.
      ///
      /// This test verifies that the fromJson constructor applies all default values when given an empty JSON object.
      test('should create FamilySettings from empty JSON with all defaults', () {
        final FamilySettings settings = FamilySettings.fromJson(const <String, dynamic>{});

        expect(settings.timezone, equals('UTC'));
        expect(settings.allowChildRegistration, isTrue);
        expect(settings.requireTaskApproval, isFalse);
        expect(settings.enableNotifications, isTrue);
        expect(settings.allowGuestAccess, isFalse);
        expect(settings.maxFamilyMembers, equals(10));
        expect(settings.defaultChildPermissions, isEmpty);
        expect(settings.enableLocationSharing, isFalse);
        expect(settings.requireParentalApproval, isTrue);
      });

      /// Tests JSON deserialization with incorrect data types.
      ///
      /// This test verifies that the fromJson constructor throws appropriate errors when given incorrect data types.
      test('should throw FormatException for incorrect data types', () {
        final Map<String, dynamic> mixedTypesJson = <String, dynamic>{
          'timezone': 'Asia/Tokyo',
          'allowChildRegistration': 'true', // String instead of bool
          'maxFamilyMembers': '15', // String instead of int
          'defaultChildPermissions': ['perm1', 'perm2', 123], // Mixed types in list
        };

        expect(
          () => FamilySettings.fromJson(mixedTypesJson),
          throwsA(isA<FormatException>()),
        );
      });

      group('error handling', () {
        /// Tests that invalid maxFamilyMembers values throw appropriate errors.
        ///
        /// This test ensures that the fromJson constructor validates maxFamilyMembers constraints and throws
        /// descriptive ArgumentError exceptions when invalid values are provided.
        test('should throw ArgumentError for invalid maxFamilyMembers', () {
          final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validSettingsJson);

          // Test negative value
          invalidJson['maxFamilyMembers'] = -1;
          expect(
            () => FamilySettings.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('maxFamilyMembers must be at least 1'),
              ),
            ),
          );

          // Test zero value
          invalidJson['maxFamilyMembers'] = 0;
          expect(
            () => FamilySettings.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('maxFamilyMembers must be at least 1'),
              ),
            ),
          );

          // Test value too large
          invalidJson['maxFamilyMembers'] = 100;
          expect(
            () => FamilySettings.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('maxFamilyMembers cannot exceed 50'),
              ),
            ),
          );
        });

        /// Tests that malformed JSON throws appropriate errors.
        ///
        /// This test ensures that various types of malformed JSON are properly handled and result in descriptive
        /// FormatException errors.
        test('should throw FormatException for malformed JSON', () {
          // This test would be more relevant if we had more complex validation
          // For now, we test that the error handling wrapper works
          final Map<String, dynamic> invalidJson = <String, dynamic>{
            'maxFamilyMembers': -5,
          };

          expect(
            () => FamilySettings.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Failed to parse FamilySettings from JSON'),
              ),
            ),
          );
        });
      });
    });

    group('toJson', () {
      /// Tests successful JSON serialization with all fields present.
      ///
      /// This test verifies that the toJson method correctly converts a FamilySettings instance to a JSON map with all
      /// fields properly formatted and typed.
      test('should convert FamilySettings to JSON with all fields', () {
        final Map<String, dynamic> json = validSettings.toJson();

        expect(json['timezone'], equals('America/New_York'));
        expect(json['allowChildRegistration'], isTrue);
        expect(json['requireTaskApproval'], isFalse);
        expect(json['enableNotifications'], isTrue);
        expect(json['allowGuestAccess'], isFalse);
        expect(json['maxFamilyMembers'], equals(8));
        expect(
          json['defaultChildPermissions'],
          equals(<String>['view_calendar', 'complete_tasks']),
        );
        expect(json['enableLocationSharing'], isFalse);
        expect(json['requireParentalApproval'], isTrue);
      });

      /// Tests JSON serialization with default values.
      ///
      /// This test ensures that the toJson method properly handles default values and includes all fields in the JSON
      /// output.
      test('should convert FamilySettings with defaults to JSON', () {
        const FamilySettings defaultSettings = FamilySettings();
        final Map<String, dynamic> json = defaultSettings.toJson();

        expect(json['timezone'], equals('UTC'));
        expect(json['allowChildRegistration'], isTrue);
        expect(json['requireTaskApproval'], isFalse);
        expect(json['enableNotifications'], isTrue);
        expect(json['allowGuestAccess'], isFalse);
        expect(json['maxFamilyMembers'], equals(10));
        expect(json['defaultChildPermissions'], isEmpty);
        expect(json['enableLocationSharing'], isFalse);
        expect(json['requireParentalApproval'], isTrue);
      });

      /// Tests that JSON serialization produces expected structure.
      ///
      /// This test verifies that the JSON output contains all expected fields with correct types and can be used for
      /// round-trip serialization.
      test('should produce expected JSON structure', () {
        final Map<String, dynamic> json = validSettings.toJson();

        // Verify all expected fields are present
        expect(json, containsPair('timezone', 'America/New_York'));
        expect(json, containsPair('allowChildRegistration', true));
        expect(json, containsPair('requireTaskApproval', false));
        expect(json, containsPair('enableNotifications', true));
        expect(json, containsPair('allowGuestAccess', false));
        expect(json, containsPair('maxFamilyMembers', 8));
        expect(json, contains('defaultChildPermissions'));
        expect(json, containsPair('enableLocationSharing', false));
        expect(json, containsPair('requireParentalApproval', true));

        // Verify data types
        expect(json['timezone'], isA<String>());
        expect(json['allowChildRegistration'], isA<bool>());
        expect(json['maxFamilyMembers'], isA<int>());
        expect(json['defaultChildPermissions'], isA<List<String>>());
      });

      /// Tests round-trip serialization (toJson -> fromJson).
      ///
      /// This test verifies that a FamilySettings instance can be serialized to JSON and then deserialized back to an
      /// equivalent FamilySettings instance without data loss.
      test('should support round-trip serialization', () {
        final Map<String, dynamic> json = validSettings.toJson();
        final FamilySettings deserializedSettings = FamilySettings.fromJson(json);

        expect(deserializedSettings, equals(validSettings));
      });
    });

    group('copyWith', () {
      /// Tests that copyWith creates a new instance with updated fields.
      ///
      /// This test verifies that the copyWith method correctly creates a new FamilySettings instance with specified
      /// fields updated while preserving all other field values.
      test('should create new FamilySettings with updated fields', () {
        final List<String> newPermissions = <String>['new_permission'];

        final FamilySettings updatedSettings = validSettings.copyWith(
          timezone: 'Europe/London',
          maxFamilyMembers: 15,
          defaultChildPermissions: newPermissions,
          enableLocationSharing: true,
        );

        expect(updatedSettings.timezone, equals('Europe/London'));
        expect(updatedSettings.allowChildRegistration, equals(validSettings.allowChildRegistration));
        expect(updatedSettings.requireTaskApproval, equals(validSettings.requireTaskApproval));
        expect(updatedSettings.enableNotifications, equals(validSettings.enableNotifications));
        expect(updatedSettings.allowGuestAccess, equals(validSettings.allowGuestAccess));
        expect(updatedSettings.maxFamilyMembers, equals(15));
        expect(updatedSettings.defaultChildPermissions, equals(newPermissions));
        expect(updatedSettings.enableLocationSharing, isTrue);
        expect(updatedSettings.requireParentalApproval, equals(validSettings.requireParentalApproval));
      });

      /// Tests that copyWith preserves original values when no updates provided.
      ///
      /// This test ensures that calling copyWith without parameters creates an identical copy of the original
      /// FamilySettings instance.
      test('should preserve original values when no updates provided', () {
        final FamilySettings copiedSettings = validSettings.copyWith();

        expect(copiedSettings, equals(validSettings));
        expect(identical(copiedSettings, validSettings), isFalse);
      });

      /// Tests that copyWith can update individual fields independently.
      ///
      /// This test verifies that each field can be updated independently without affecting other fields, ensuring
      /// proper isolation of changes.
      test('should update individual fields independently', () {
        final FamilySettings updatedTimezone = validSettings.copyWith(timezone: 'UTC');
        final FamilySettings updatedRegistration = validSettings.copyWith(allowChildRegistration: false);
        final FamilySettings updatedMembers = validSettings.copyWith(maxFamilyMembers: 20);

        expect(updatedTimezone.timezone, equals('UTC'));
        expect(updatedTimezone.allowChildRegistration, equals(validSettings.allowChildRegistration));

        expect(updatedRegistration.allowChildRegistration, isFalse);
        expect(updatedRegistration.timezone, equals(validSettings.timezone));

        expect(updatedMembers.maxFamilyMembers, equals(20));
        expect(updatedMembers.timezone, equals(validSettings.timezone));
      });

      /// Tests that copyWith handles boolean toggles correctly.
      ///
      /// This test verifies that boolean fields can be properly toggled using copyWith without affecting other fields.
      test('should handle boolean toggles correctly', () {
        final FamilySettings toggledSettings = validSettings.copyWith(
          allowChildRegistration: !validSettings.allowChildRegistration,
          requireTaskApproval: !validSettings.requireTaskApproval,
          enableNotifications: !validSettings.enableNotifications,
          allowGuestAccess: !validSettings.allowGuestAccess,
          enableLocationSharing: !validSettings.enableLocationSharing,
          requireParentalApproval: !validSettings.requireParentalApproval,
        );

        expect(toggledSettings.allowChildRegistration, isFalse);
        expect(toggledSettings.requireTaskApproval, isTrue);
        expect(toggledSettings.enableNotifications, isFalse);
        expect(toggledSettings.allowGuestAccess, isTrue);
        expect(toggledSettings.enableLocationSharing, isTrue);
        expect(toggledSettings.requireParentalApproval, isFalse);

        // Verify non-boolean fields are preserved
        expect(toggledSettings.timezone, equals(validSettings.timezone));
        expect(toggledSettings.maxFamilyMembers, equals(validSettings.maxFamilyMembers));
        expect(toggledSettings.defaultChildPermissions, equals(validSettings.defaultChildPermissions));
      });
    });

    group('equality and hashCode', () {
      /// Tests that identical FamilySettings instances are considered equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilySettings instances with identical
      /// field values as equal.
      test('should consider FamilySettings with identical values as equal', () {
        final List<String> permissions = <String>['perm1', 'perm2'];

        final FamilySettings settings1 = FamilySettings(
          timezone: 'America/Chicago',
          allowChildRegistration: false,
          requireTaskApproval: true,
          enableNotifications: false,
          allowGuestAccess: true,
          maxFamilyMembers: 12,
          defaultChildPermissions: permissions,
          enableLocationSharing: true,
          requireParentalApproval: false,
        );

        final FamilySettings settings2 = FamilySettings(
          timezone: 'America/Chicago',
          allowChildRegistration: false,
          requireTaskApproval: true,
          enableNotifications: false,
          allowGuestAccess: true,
          maxFamilyMembers: 12,
          defaultChildPermissions: permissions,
          enableLocationSharing: true,
          requireParentalApproval: false,
        );

        expect(settings1, equals(settings2));
        expect(settings1.hashCode, equals(settings2.hashCode));
      });

      /// Tests that FamilySettings instances with different values are not equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilySettings instances with different
      /// field values as not equal.
      test('should consider FamilySettings with different values as not equal', () {
        final FamilySettings settings1 = validSettings;
        final FamilySettings settings2 = validSettings.copyWith(timezone: 'UTC');

        expect(settings1, isNot(equals(settings2)));
        expect(settings1.hashCode, isNot(equals(settings2.hashCode)));
      });

      /// Tests that a FamilySettings instance is equal to itself.
      ///
      /// This test verifies the reflexive property of equality, ensuring that any FamilySettings instance is equal to
      /// itself.
      test('should be equal to itself', () {
        expect(validSettings, equals(validSettings));
        expect(validSettings.hashCode, equals(validSettings.hashCode));
      });

      /// Tests that FamilySettings instances with different list contents are not equal.
      ///
      /// This test ensures that equality comparison correctly handles list fields and identifies differences in list
      /// contents.
      test('should handle list equality correctly', () {
        final FamilySettings settings1 = validSettings.copyWith(
          defaultChildPermissions: <String>['perm1', 'perm2'],
        );
        final FamilySettings settings2 = validSettings.copyWith(
          defaultChildPermissions: <String>['perm1', 'perm3'],
        );
        final FamilySettings settings3 = validSettings.copyWith(
          defaultChildPermissions: <String>['perm1', 'perm2'],
        );

        expect(settings1, isNot(equals(settings2)));
        expect(settings1, equals(settings3));
        expect(settings1.hashCode, equals(settings3.hashCode));
      });
    });

    group('toString', () {
      /// Tests that toString produces a readable string representation.
      ///
      /// This test verifies that the toString method produces a properly formatted string containing all field values
      /// for debugging purposes.
      test('should produce readable string representation', () {
        final String stringRepresentation = validSettings.toString();

        expect(stringRepresentation, contains('FamilySettings('));
        expect(stringRepresentation, contains('timezone: America/New_York'));
        expect(stringRepresentation, contains('allowChildRegistration: true'));
        expect(stringRepresentation, contains('requireTaskApproval: false'));
        expect(stringRepresentation, contains('enableNotifications: true'));
        expect(stringRepresentation, contains('allowGuestAccess: false'));
        expect(stringRepresentation, contains('maxFamilyMembers: 8'));
        expect(stringRepresentation, contains('defaultChildPermissions: [view_calendar, complete_tasks]'));
        expect(stringRepresentation, contains('enableLocationSharing: false'));
        expect(stringRepresentation, contains('requireParentalApproval: true'));
      });

      /// Tests that toString handles empty lists correctly.
      ///
      /// This test ensures that the toString method properly displays empty lists without causing errors.
      test('should handle empty lists in string representation', () {
        const FamilySettings settingsWithEmptyList = FamilySettings();

        final String stringRepresentation = settingsWithEmptyList.toString();

        expect(stringRepresentation, contains('defaultChildPermissions: []'));
      });
    });

    group('validation constraints', () {
      /// Tests that maxFamilyMembers constraints are properly enforced.
      ///
      /// This test verifies that the FamilySettings validation correctly enforces the minimum and maximum limits for
      /// family member counts.
      test('should enforce maxFamilyMembers constraints', () {
        // Test minimum boundary
        expect(
          () => FamilySettings.fromJson(const <String, dynamic>{'maxFamilyMembers': 1}),
          returnsNormally,
        );

        // Test maximum boundary
        expect(
          () => FamilySettings.fromJson(const <String, dynamic>{'maxFamilyMembers': 50}),
          returnsNormally,
        );

        // Test below minimum
        expect(
          () => FamilySettings.fromJson(const <String, dynamic>{'maxFamilyMembers': 0}),
          throwsA(isA<FormatException>()),
        );

        // Test above maximum
        expect(
          () => FamilySettings.fromJson(const <String, dynamic>{'maxFamilyMembers': 51}),
          throwsA(isA<FormatException>()),
        );
      });

      /// Tests that timezone values are accepted without validation.
      ///
      /// This test documents that the current implementation accepts any string as a timezone value. In a production
      /// system, this might include timezone validation.
      test('should accept any timezone string', () {
        final List<String> timezones = [
          'UTC',
          'America/New_York',
          'Europe/London',
          'Asia/Tokyo',
          'Invalid/Timezone', // Currently accepted
        ];

        for (final String timezone in timezones) {
          expect(
            () => FamilySettings.fromJson(<String, dynamic>{'timezone': timezone}),
            returnsNormally,
            reason: 'Should accept timezone: $timezone',
          );
        }
      });
    });
  });
}
