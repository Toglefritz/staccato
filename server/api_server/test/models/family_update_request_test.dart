import 'package:staccato_api_server/models/family.dart';
import 'package:staccato_api_server/models/family_update_request.dart';
import 'package:test/test.dart';

void main() {
  group('FamilyUpdateRequest', () {
    /// Sample valid family update request data for testing successful operations.
    ///
    /// This data represents a typical family update request with some fields populated. Used as a baseline for most
    /// tests.
    late Map<String, dynamic> validRequestJson;

    /// Sample FamilyUpdateRequest instance created from valid data.
    ///
    /// This instance is used for testing methods that operate on existing FamilyUpdateRequest objects, such as
    /// validation and toJson.
    late FamilyUpdateRequest validRequest;

    /// Sample valid family settings data for testing.
    ///
    /// This data represents typical family settings that can be included in update requests.
    late Map<String, dynamic> validSettingsJson;

    /// Sample Family instance for testing applyTo method.
    ///
    /// This instance represents an existing family that can be updated using the request.
    late Family existingFamily;

    /// Set up test data before each test.
    ///
    /// Creates fresh instances of test data to ensure test isolation and prevent interference between tests. All test
    /// data represents valid request information unless specifically testing error conditions.
    setUp(() {
      validSettingsJson = <String, dynamic>{
        'timezone': 'America/Los_Angeles',
        'allowChildRegistration': false,
        'requireTaskApproval': true,
        'enableNotifications': false,
        'allowGuestAccess': true,
        'maxFamilyMembers': 12,
        'defaultChildPermissions': <String>['view_calendar'],
        'enableLocationSharing': true,
        'requireParentalApproval': false,
      };

      validRequestJson = <String, dynamic>{
        'name': 'Updated Smith Family',
        'settings': validSettingsJson,
      };

      validRequest = FamilyUpdateRequest(
        name: 'Updated Smith Family',
        settings: FamilySettings.fromJson(validSettingsJson),
      );

      existingFamily = Family(
        id: 'family_123',
        name: 'Original Smith Family',
        primaryUserId: 'user_456',
        settings: const FamilySettings(
          timezone: 'America/New_York',
          maxFamilyMembers: 8,
        ),
        createdAt: DateTime.parse('2025-01-10T14:30:00.000Z'),
        updatedAt: DateTime.parse('2025-01-10T15:00:00.000Z'),
      );
    });

    group('constructor', () {
      /// Verifies that the FamilyUpdateRequest constructor properly assigns all provided values.
      ///
      /// This test ensures that all constructor parameters are correctly stored as instance fields and that the object
      /// is properly initialized with the expected values.
      test('should create FamilyUpdateRequest with all provided values', () {
        final FamilySettings settings = FamilySettings.fromJson(validSettingsJson);

        final FamilyUpdateRequest request = FamilyUpdateRequest(
          name: 'Test Family',
          settings: settings,
        );

        expect(request.name, equals('Test Family'));
        expect(request.settings, equals(settings));
      });

      /// Verifies that all fields are optional during construction.
      ///
      /// This test ensures that the FamilyUpdateRequest constructor works correctly when no fields are provided,
      /// creating an empty update request.
      test('should create FamilyUpdateRequest with no fields provided', () {
        const FamilyUpdateRequest request = FamilyUpdateRequest();

        expect(request.name, isNull);
        expect(request.settings, isNull);
      });

      /// Verifies that individual fields can be provided independently.
      ///
      /// This test ensures that the FamilyUpdateRequest constructor works correctly when only some fields are provided.
      test('should create FamilyUpdateRequest with individual fields', () {
        const FamilyUpdateRequest nameOnlyRequest = FamilyUpdateRequest(
          name: 'Name Only Family',
        );

        final FamilySettings settings = FamilySettings.fromJson(validSettingsJson);
        final FamilyUpdateRequest settingsOnlyRequest = FamilyUpdateRequest(
          settings: settings,
        );

        expect(nameOnlyRequest.name, equals('Name Only Family'));
        expect(nameOnlyRequest.settings, isNull);

        expect(settingsOnlyRequest.name, isNull);
        expect(settingsOnlyRequest.settings, equals(settings));
      });
    });

    group('hasUpdates property', () {
      /// Tests that hasUpdates returns true when updates are present.
      ///
      /// This test verifies that the hasUpdates getter correctly identifies requests that contain update data.
      test('should return true when updates are present', () {
        expect(validRequest.hasUpdates, isTrue);

        const FamilyUpdateRequest nameOnlyRequest = FamilyUpdateRequest(
          name: 'Test Family',
        );
        expect(nameOnlyRequest.hasUpdates, isTrue);

        final FamilyUpdateRequest settingsOnlyRequest = FamilyUpdateRequest(
          settings: const FamilySettings(),
        );
        expect(settingsOnlyRequest.hasUpdates, isTrue);
      });

      /// Tests that hasUpdates returns false when no updates are present.
      ///
      /// This test verifies that the hasUpdates getter correctly identifies empty requests.
      test('should return false when no updates are present', () {
        const FamilyUpdateRequest emptyRequest = FamilyUpdateRequest();

        expect(emptyRequest.hasUpdates, isFalse);
      });
    });

    group('fromJson', () {
      /// Tests successful JSON deserialization with all fields present.
      ///
      /// This test verifies that the fromJson factory constructor correctly parses a complete JSON object and creates a
      /// FamilyUpdateRequest instance with all fields properly populated and typed.
      test('should create FamilyUpdateRequest from valid JSON with all fields', () {
        final FamilyUpdateRequest request = FamilyUpdateRequest.fromJson(validRequestJson);

        expect(request.name, equals('Updated Smith Family'));
        expect(request.settings, isNotNull);
        expect(request.settings!.timezone, equals('America/Los_Angeles'));
        expect(request.settings!.maxFamilyMembers, equals(12));
      });

      /// Tests JSON deserialization with only name field present.
      ///
      /// This test ensures that the fromJson constructor works correctly when only the name field is provided.
      test('should create FamilyUpdateRequest from JSON with only name field', () {
        final Map<String, dynamic> nameOnlyJson = <String, dynamic>{
          'name': 'Name Only Family',
        };

        final FamilyUpdateRequest request = FamilyUpdateRequest.fromJson(nameOnlyJson);

        expect(request.name, equals('Name Only Family'));
        expect(request.settings, isNull);
      });

      /// Tests JSON deserialization with only settings field present.
      ///
      /// This test ensures that the fromJson constructor works correctly when only the settings field is provided.
      test('should create FamilyUpdateRequest from JSON with only settings field', () {
        final Map<String, dynamic> settingsOnlyJson = <String, dynamic>{
          'settings': validSettingsJson,
        };

        final FamilyUpdateRequest request = FamilyUpdateRequest.fromJson(settingsOnlyJson);

        expect(request.name, isNull);
        expect(request.settings, isNotNull);
        expect(request.settings!.timezone, equals('America/Los_Angeles'));
      });

      /// Tests JSON deserialization with empty JSON object.
      ///
      /// This test verifies that the fromJson constructor correctly handles empty JSON objects.
      test('should create FamilyUpdateRequest from empty JSON', () {
        final FamilyUpdateRequest request = FamilyUpdateRequest.fromJson(const <String, dynamic>{});

        expect(request.name, isNull);
        expect(request.settings, isNull);
        expect(request.hasUpdates, isFalse);
      });

      /// Tests JSON deserialization with name trimming.
      ///
      /// This test verifies that the fromJson constructor properly trims whitespace from the family name.
      test('should trim whitespace from family name', () {
        final Map<String, dynamic> jsonWithWhitespace = <String, dynamic>{
          'name': '  The Trimmed Family  ',
        };

        final FamilyUpdateRequest request = FamilyUpdateRequest.fromJson(jsonWithWhitespace);

        expect(request.name, equals('The Trimmed Family'));
      });

      group('error handling', () {
        /// Tests that empty string values for name field throw errors.
        ///
        /// This test ensures that the name field cannot be an empty string, which would be invalid for family
        /// identification and display purposes.
        test('should throw ArgumentError for empty name field', () {
          final Map<String, dynamic> invalidJson = <String, dynamic>{
            'name': '',
          };

          expect(
            () => FamilyUpdateRequest.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Family name cannot be empty'),
              ),
            ),
          );
        });

        /// Tests that whitespace-only names throw errors.
        ///
        /// This test ensures that names consisting only of whitespace are properly rejected.
        test('should throw ArgumentError for whitespace-only name', () {
          final Map<String, dynamic> invalidJson = <String, dynamic>{
            'name': '   ',
          };

          expect(
            () => FamilyUpdateRequest.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Family name cannot be empty'),
              ),
            ),
          );
        });

        /// Tests that names exceeding maximum length throw errors.
        ///
        /// This test ensures that family names cannot exceed the maximum allowed length of 100 characters.
        test('should throw ArgumentError for name exceeding maximum length', () {
          final String longName = 'A' * 101; // 101 characters
          final Map<String, dynamic> invalidJson = <String, dynamic>{
            'name': longName,
          };

          expect(
            () => FamilyUpdateRequest.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Family name cannot exceed 100 characters'),
              ),
            ),
          );
        });

        /// Tests that invalid settings data throws appropriate errors.
        ///
        /// This test ensures that malformed settings objects are properly handled and result in descriptive errors.
        test('should throw FormatException for invalid settings', () {
          final Map<String, dynamic> invalidJson = <String, dynamic>{
            'name': 'Valid Family Name',
            'settings': <String, dynamic>{
              'maxFamilyMembers': -1, // Invalid value
            },
          };

          expect(
            () => FamilyUpdateRequest.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Failed to parse FamilyUpdateRequest from JSON'),
              ),
            ),
          );
        });
      });
    });

    group('toJson', () {
      /// Tests successful JSON serialization with all fields present.
      ///
      /// This test verifies that the toJson method correctly converts a FamilyUpdateRequest instance to a JSON map with
      /// all fields properly formatted and typed.
      test('should convert FamilyUpdateRequest to JSON with all fields', () {
        final Map<String, dynamic> json = validRequest.toJson();

        expect(json['name'], equals('Updated Smith Family'));
        expect(json['settings'], isA<Map<String, dynamic>>());

        // Verify settings are properly serialized
        final Map<String, dynamic> settingsJson = json['settings'] as Map<String, dynamic>;
        expect(settingsJson['timezone'], equals('America/Los_Angeles'));
        expect(settingsJson['maxFamilyMembers'], equals(12));
      });

      /// Tests JSON serialization with only name field present.
      ///
      /// This test ensures that the toJson method properly handles requests with only the name field populated.
      test('should convert FamilyUpdateRequest to JSON with only name field', () {
        const FamilyUpdateRequest nameOnlyRequest = FamilyUpdateRequest(
          name: 'Name Only Family',
        );

        final Map<String, dynamic> json = nameOnlyRequest.toJson();

        expect(json['name'], equals('Name Only Family'));
        expect(json, isNot(contains('settings')));
      });

      /// Tests JSON serialization with only settings field present.
      ///
      /// This test ensures that the toJson method properly handles requests with only the settings field populated.
      test('should convert FamilyUpdateRequest to JSON with only settings field', () {
        final FamilyUpdateRequest settingsOnlyRequest = FamilyUpdateRequest(
          settings: FamilySettings.fromJson(validSettingsJson),
        );

        final Map<String, dynamic> json = settingsOnlyRequest.toJson();

        expect(json, isNot(contains('name')));
        expect(json['settings'], isA<Map<String, dynamic>>());
      });

      /// Tests JSON serialization with empty request.
      ///
      /// This test ensures that the toJson method properly handles empty requests by returning an empty JSON object.
      test('should convert empty FamilyUpdateRequest to empty JSON', () {
        const FamilyUpdateRequest emptyRequest = FamilyUpdateRequest();

        final Map<String, dynamic> json = emptyRequest.toJson();

        expect(json, isEmpty);
      });

      /// Tests round-trip serialization (toJson -> fromJson).
      ///
      /// This test verifies that a FamilyUpdateRequest instance can be serialized to JSON and then deserialized back to
      /// an equivalent FamilyUpdateRequest instance without data loss.
      test('should support round-trip serialization', () {
        final Map<String, dynamic> json = validRequest.toJson();
        final FamilyUpdateRequest deserializedRequest = FamilyUpdateRequest.fromJson(json);

        expect(deserializedRequest.name, equals(validRequest.name));
        expect(deserializedRequest.settings, equals(validRequest.settings));
      });
    });

    group('validation', () {
      /// Tests that validate method returns empty list for valid requests.
      ///
      /// This test verifies that the validate method correctly identifies valid requests and returns no errors.
      test('should return empty list for valid request', () {
        final List<String> errors = validRequest.validate();

        expect(errors, isEmpty);
      });

      /// Tests that validate method returns error for empty requests.
      ///
      /// This test ensures that the validate method properly detects and reports requests with no updates.
      test('should return error for empty request', () {
        const FamilyUpdateRequest emptyRequest = FamilyUpdateRequest();

        final List<String> errors = emptyRequest.validate();

        expect(errors, isNotEmpty);
        expect(errors.first, contains('At least one field must be provided for update'));
      });

      /// Tests that validate method identifies empty names.
      ///
      /// This test ensures that the validate method properly detects and reports empty family names.
      test('should return error for empty name', () {
        const FamilyUpdateRequest invalidRequest = FamilyUpdateRequest(
          name: '',
        );

        final List<String> errors = invalidRequest.validate();

        expect(errors, isNotEmpty);
        expect(errors.any((String error) => error.contains('Family name cannot be empty')), isTrue);
      });

      /// Tests that validate method identifies names that are too long.
      ///
      /// This test ensures that the validate method properly detects and reports family names that exceed the maximum
      /// length.
      test('should return error for name exceeding maximum length', () {
        final String longName = 'A' * 101; // 101 characters
        final FamilyUpdateRequest invalidRequest = FamilyUpdateRequest(
          name: longName,
        );

        final List<String> errors = invalidRequest.validate();

        expect(errors, isNotEmpty);
        expect(errors.any((String error) => error.contains('Family name cannot exceed 100 characters')), isTrue);
      });

      /// Tests that validate method handles whitespace-only names.
      ///
      /// This test ensures that the validate method properly detects names consisting only of whitespace.
      test('should return error for whitespace-only name', () {
        const FamilyUpdateRequest invalidRequest = FamilyUpdateRequest(
          name: '   ',
        );

        final List<String> errors = invalidRequest.validate();

        expect(errors, isNotEmpty);
        expect(errors.any((String error) => error.contains('Family name cannot be empty')), isTrue);
      });

      /// Tests that validate method accepts valid individual fields.
      ///
      /// This test verifies that the validate method correctly handles requests with only one valid field.
      test('should accept valid individual fields', () {
        const FamilyUpdateRequest nameOnlyRequest = FamilyUpdateRequest(
          name: 'Valid Name',
        );

        final FamilyUpdateRequest settingsOnlyRequest = FamilyUpdateRequest(
          settings: FamilySettings(),
        );

        expect(nameOnlyRequest.validate(), isEmpty);
        expect(settingsOnlyRequest.validate(), isEmpty);
      });
    });

    group('isValid property', () {
      /// Tests that isValid returns true for valid requests.
      ///
      /// This test verifies that the isValid getter correctly identifies valid requests.
      test('should return true for valid request', () {
        expect(validRequest.isValid, isTrue);
      });

      /// Tests that isValid returns false for invalid requests.
      ///
      /// This test verifies that the isValid getter correctly identifies invalid requests.
      test('should return false for invalid request', () {
        const FamilyUpdateRequest emptyRequest = FamilyUpdateRequest();

        expect(emptyRequest.isValid, isFalse);
      });

      /// Tests that isValid returns false for requests with invalid names.
      ///
      /// This test verifies that the isValid getter correctly identifies requests with invalid name values.
      test('should return false for request with invalid name', () {
        const FamilyUpdateRequest invalidRequest = FamilyUpdateRequest(
          name: '',
        );

        expect(invalidRequest.isValid, isFalse);
      });
    });

    group('applyTo method', () {
      /// Tests that applyTo correctly applies name updates.
      ///
      /// This test verifies that the applyTo method properly updates the family name while preserving other fields.
      test('should apply name update to existing family', () {
        const FamilyUpdateRequest nameUpdateRequest = FamilyUpdateRequest(
          name: 'New Family Name',
        );

        final Family updatedFamily = nameUpdateRequest.applyTo(existingFamily);

        expect(updatedFamily.name, equals('New Family Name'));
        expect(updatedFamily.id, equals(existingFamily.id));
        expect(updatedFamily.primaryUserId, equals(existingFamily.primaryUserId));
        expect(updatedFamily.settings, equals(existingFamily.settings));
        expect(updatedFamily.createdAt, equals(existingFamily.createdAt));
        expect(updatedFamily.updatedAt, isNot(equals(existingFamily.updatedAt)));
      });

      /// Tests that applyTo correctly applies settings updates.
      ///
      /// This test verifies that the applyTo method properly updates the family settings while preserving other fields.
      test('should apply settings update to existing family', () {
        final FamilySettings newSettings = FamilySettings.fromJson(validSettingsJson);
        final FamilyUpdateRequest settingsUpdateRequest = FamilyUpdateRequest(
          settings: newSettings,
        );

        final Family updatedFamily = settingsUpdateRequest.applyTo(existingFamily);

        expect(updatedFamily.name, equals(existingFamily.name));
        expect(updatedFamily.id, equals(existingFamily.id));
        expect(updatedFamily.primaryUserId, equals(existingFamily.primaryUserId));
        expect(updatedFamily.settings, equals(newSettings));
        expect(updatedFamily.createdAt, equals(existingFamily.createdAt));
        expect(updatedFamily.updatedAt, isNot(equals(existingFamily.updatedAt)));
      });

      /// Tests that applyTo correctly applies multiple updates.
      ///
      /// This test verifies that the applyTo method properly updates multiple fields simultaneously.
      test('should apply multiple updates to existing family', () {
        final Family updatedFamily = validRequest.applyTo(existingFamily);

        expect(updatedFamily.name, equals('Updated Smith Family'));
        expect(updatedFamily.settings, equals(validRequest.settings));
        expect(updatedFamily.id, equals(existingFamily.id));
        expect(updatedFamily.primaryUserId, equals(existingFamily.primaryUserId));
        expect(updatedFamily.createdAt, equals(existingFamily.createdAt));
        expect(updatedFamily.updatedAt, isNot(equals(existingFamily.updatedAt)));
      });

      /// Tests that applyTo preserves original values when no updates provided.
      ///
      /// This test verifies that the applyTo method preserves all original values when given an empty update request,
      /// but still updates the updatedAt timestamp.
      test('should preserve original values when no updates provided', () {
        const FamilyUpdateRequest emptyRequest = FamilyUpdateRequest();

        final Family updatedFamily = emptyRequest.applyTo(existingFamily);

        expect(updatedFamily.name, equals(existingFamily.name));
        expect(updatedFamily.settings, equals(existingFamily.settings));
        expect(updatedFamily.id, equals(existingFamily.id));
        expect(updatedFamily.primaryUserId, equals(existingFamily.primaryUserId));
        expect(updatedFamily.createdAt, equals(existingFamily.createdAt));
        expect(updatedFamily.updatedAt, isNot(equals(existingFamily.updatedAt)));
      });

      /// Tests that applyTo always updates the updatedAt timestamp.
      ///
      /// This test verifies that the applyTo method always sets a new updatedAt timestamp, regardless of what fields
      /// are being updated.
      test('should always update the updatedAt timestamp', () {
        final DateTime beforeUpdate = DateTime.now();

        const FamilyUpdateRequest nameUpdateRequest = FamilyUpdateRequest(
          name: 'New Name',
        );

        final Family updatedFamily = nameUpdateRequest.applyTo(existingFamily);

        expect(updatedFamily.updatedAt, isNotNull);
        expect(updatedFamily.updatedAt!.isAfter(beforeUpdate), isTrue);
        expect(updatedFamily.updatedAt, isNot(equals(existingFamily.updatedAt)));
      });
    });

    group('equality and hashCode', () {
      /// Tests that identical FamilyUpdateRequest instances are considered equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyUpdateRequest instances with
      /// identical field values as equal.
      test('should consider FamilyUpdateRequests with identical values as equal', () {
        final FamilySettings settings = FamilySettings.fromJson(validSettingsJson);

        final FamilyUpdateRequest request1 = FamilyUpdateRequest(
          name: 'Test Family',
          settings: settings,
        );

        final FamilyUpdateRequest request2 = FamilyUpdateRequest(
          name: 'Test Family',
          settings: settings,
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      /// Tests that FamilyUpdateRequest instances with different values are not equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyUpdateRequest instances with
      /// different field values as not equal.
      test('should consider FamilyUpdateRequests with different values as not equal', () {
        final FamilyUpdateRequest request1 = validRequest;
        const FamilyUpdateRequest request2 = FamilyUpdateRequest(
          name: 'Different Family Name',
        );

        expect(request1, isNot(equals(request2)));
        expect(request1.hashCode, isNot(equals(request2.hashCode)));
      });

      /// Tests that a FamilyUpdateRequest instance is equal to itself.
      ///
      /// This test verifies the reflexive property of equality, ensuring that any FamilyUpdateRequest instance is equal
      /// to itself.
      test('should be equal to itself', () {
        expect(validRequest, equals(validRequest));
        expect(validRequest.hashCode, equals(validRequest.hashCode));
      });

      /// Tests that FamilyUpdateRequest instances with null fields handle equality correctly.
      ///
      /// This test ensures that equality comparison works correctly when fields are null in one or both instances.
      test('should handle null fields in equality comparison', () {
        const FamilyUpdateRequest requestWithNulls = FamilyUpdateRequest();

        const FamilyUpdateRequest anotherRequestWithNulls = FamilyUpdateRequest();

        expect(requestWithNulls, equals(anotherRequestWithNulls));
        expect(requestWithNulls.hashCode, equals(anotherRequestWithNulls.hashCode));
      });
    });

    group('toString', () {
      /// Tests that toString produces a readable string representation.
      ///
      /// This test verifies that the toString method produces a properly formatted string containing all field values
      /// for debugging purposes.
      test('should produce readable string representation', () {
        final String stringRepresentation = validRequest.toString();

        expect(stringRepresentation, contains('FamilyUpdateRequest('));
        expect(stringRepresentation, contains('name: Updated Smith Family'));
        expect(stringRepresentation, contains('settings: '));
      });

      /// Tests that toString handles null fields correctly.
      ///
      /// This test ensures that the toString method properly displays null values for fields without causing errors.
      test('should handle null fields in string representation', () {
        const FamilyUpdateRequest requestWithNulls = FamilyUpdateRequest();

        final String stringRepresentation = requestWithNulls.toString();

        expect(stringRepresentation, contains('name: null'));
        expect(stringRepresentation, contains('settings: null'));
      });
    });

    group('partial update scenarios', () {
      /// Tests various partial update scenarios to ensure they work correctly.
      ///
      /// This test verifies that the FamilyUpdateRequest correctly handles different combinations of field updates.
      test('should handle various partial update scenarios', () {
        // Name only update
        const FamilyUpdateRequest nameOnly = FamilyUpdateRequest(
          name: 'Name Only Update',
        );
        expect(nameOnly.hasUpdates, isTrue);
        expect(nameOnly.isValid, isTrue);

        final Family nameUpdated = nameOnly.applyTo(existingFamily);
        expect(nameUpdated.name, equals('Name Only Update'));
        expect(nameUpdated.settings, equals(existingFamily.settings));

        // Settings only update
        const FamilySettings newSettings = FamilySettings(
          maxFamilyMembers: 15,
        );
        final FamilyUpdateRequest settingsOnly = FamilyUpdateRequest(
          settings: newSettings,
        );
        expect(settingsOnly.hasUpdates, isTrue);
        expect(settingsOnly.isValid, isTrue);

        final Family settingsUpdated = settingsOnly.applyTo(existingFamily);
        expect(settingsUpdated.name, equals(existingFamily.name));
        expect(settingsUpdated.settings, equals(newSettings));
      });
    });
  });
}
