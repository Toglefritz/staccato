import 'package:staccato_api_server/models/family.dart';
import 'package:staccato_api_server/models/family_create_request.dart';
import 'package:test/test.dart';

void main() {
  group('FamilyCreateRequest', () {
    /// Sample valid family create request data for testing successful operations.
    ///
    /// This data represents a typical family creation request with all fields populated. Used as a baseline for most
    /// tests.
    late Map<String, dynamic> validRequestJson;

    /// Sample FamilyCreateRequest instance created from valid data.
    ///
    /// This instance is used for testing methods that operate on existing FamilyCreateRequest objects, such as
    /// validation and toJson.
    late FamilyCreateRequest validRequest;

    /// Sample valid family settings data for testing.
    ///
    /// This data represents typical family settings that can be included in creation requests.
    late Map<String, dynamic> validSettingsJson;

    /// Set up test data before each test.
    ///
    /// Creates fresh instances of test data to ensure test isolation and prevent interference between tests. All test
    /// data represents valid request information unless specifically testing error conditions.
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

      validRequestJson = <String, dynamic>{
        'name': 'The Smith Family',
        'settings': validSettingsJson,
      };

      validRequest = FamilyCreateRequest(
        name: 'The Smith Family',
        settings: FamilySettings.fromJson(validSettingsJson),
      );
    });

    group('constructor', () {
      /// Verifies that the FamilyCreateRequest constructor properly assigns all provided values.
      ///
      /// This test ensures that all constructor parameters are correctly stored as instance fields and that the object
      /// is properly initialized with the expected values.
      test('should create FamilyCreateRequest with all provided values', () {
        final FamilySettings settings = FamilySettings.fromJson(validSettingsJson);

        final FamilyCreateRequest request = FamilyCreateRequest(
          name: 'Test Family',
          settings: settings,
        );

        expect(request.name, equals('Test Family'));
        expect(request.settings, equals(settings));
      });

      /// Verifies that optional fields can be omitted during construction.
      ///
      /// This test ensures that the FamilyCreateRequest constructor works correctly when only required fields are
      /// provided, with optional fields defaulting to null as expected.
      test('should create FamilyCreateRequest with only required fields', () {
        const FamilyCreateRequest request = FamilyCreateRequest(
          name: 'Test Family',
        );

        expect(request.name, equals('Test Family'));
        expect(request.settings, isNull);
      });
    });

    group('fromJson', () {
      /// Tests successful JSON deserialization with all fields present.
      ///
      /// This test verifies that the fromJson factory constructor correctly parses a complete JSON object and creates a
      /// FamilyCreateRequest instance with all fields properly populated and typed.
      test('should create FamilyCreateRequest from valid JSON with all fields', () {
        final FamilyCreateRequest request = FamilyCreateRequest.fromJson(validRequestJson);

        expect(request.name, equals('The Smith Family'));
        expect(request.settings, isNotNull);
        expect(request.settings!.timezone, equals('America/New_York'));
        expect(request.settings!.maxFamilyMembers, equals(8));
      });

      /// Tests JSON deserialization with only required fields present.
      ///
      /// This test ensures that the fromJson constructor works correctly when optional fields are missing from the
      /// JSON, setting them to null as expected.
      test('should create FamilyCreateRequest from JSON with only required fields', () {
        final Map<String, dynamic> minimalJson = <String, dynamic>{
          'name': 'The Johnson Family',
        };

        final FamilyCreateRequest request = FamilyCreateRequest.fromJson(minimalJson);

        expect(request.name, equals('The Johnson Family'));
        expect(request.settings, isNull);
      });

      /// Tests JSON deserialization with name trimming.
      ///
      /// This test verifies that the fromJson constructor properly trims whitespace from the family name.
      test('should trim whitespace from family name', () {
        final Map<String, dynamic> jsonWithWhitespace = <String, dynamic>{
          'name': '  The Trimmed Family  ',
        };

        final FamilyCreateRequest request = FamilyCreateRequest.fromJson(jsonWithWhitespace);

        expect(request.name, equals('The Trimmed Family'));
      });

      group('error handling', () {
        /// Tests that missing required fields throw appropriate errors.
        ///
        /// This test ensures that the fromJson constructor validates all required fields and throws descriptive
        /// ArgumentError exceptions when required data is missing.
        test('should throw ArgumentError for missing name field', () {
          final Map<String, dynamic> incompleteJson = <String, dynamic>{
            'settings': validSettingsJson,
          };

          expect(
            () => FamilyCreateRequest.fromJson(incompleteJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Missing or empty required field: name'),
              ),
            ),
          );
        });

        /// Tests that empty string values for required fields throw errors.
        ///
        /// This test ensures that required fields cannot be empty strings, which would be invalid for family
        /// identification and display purposes.
        test('should throw ArgumentError for empty name field', () {
          final Map<String, dynamic> invalidJson = <String, dynamic>{
            'name': '',
            'settings': validSettingsJson,
          };

          expect(
            () => FamilyCreateRequest.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Missing or empty required field: name'),
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
            'settings': validSettingsJson,
          };

          expect(
            () => FamilyCreateRequest.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Missing or empty required field: name'),
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
            'settings': validSettingsJson,
          };

          expect(
            () => FamilyCreateRequest.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Family name cannot exceed 100 characters'),
              ),
            ),
          );
        });

        /// Tests that null values for required fields throw errors.
        ///
        /// This test verifies that explicitly null values for required fields are properly detected and result in
        /// appropriate error messages.
        test('should throw ArgumentError for null name field', () {
          final Map<String, dynamic> nullJson = <String, dynamic>{
            'name': null,
            'settings': validSettingsJson,
          };

          expect(
            () => FamilyCreateRequest.fromJson(nullJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Missing or empty required field: name'),
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
            () => FamilyCreateRequest.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Failed to parse FamilyCreateRequest from JSON'),
              ),
            ),
          );
        });
      });
    });

    group('toJson', () {
      /// Tests successful JSON serialization with all fields present.
      ///
      /// This test verifies that the toJson method correctly converts a FamilyCreateRequest instance to a JSON map
      /// with all fields properly formatted and typed.
      test('should convert FamilyCreateRequest to JSON with all fields', () {
        final Map<String, dynamic> json = validRequest.toJson();

        expect(json['name'], equals('The Smith Family'));
        expect(json['settings'], isA<Map<String, dynamic>>());

        // Verify settings are properly serialized
        final Map<String, dynamic> settingsJson = json['settings'] as Map<String, dynamic>;
        expect(settingsJson['timezone'], equals('America/New_York'));
        expect(settingsJson['maxFamilyMembers'], equals(8));
      });

      /// Tests JSON serialization with null optional fields.
      ///
      /// This test ensures that the toJson method properly handles null values for optional fields, including them in
      /// the JSON with null values.
      test('should convert FamilyCreateRequest to JSON with null optional fields', () {
        const FamilyCreateRequest requestWithNulls = FamilyCreateRequest(
          name: 'Test Family',
        );

        final Map<String, dynamic> json = requestWithNulls.toJson();

        expect(json['name'], equals('Test Family'));
        expect(json['settings'], isNull);
      });

      /// Tests that JSON serialization produces expected structure.
      ///
      /// This test verifies that the JSON output contains all expected fields with correct types and can be used for
      /// round-trip serialization.
      test('should produce expected JSON structure', () {
        final Map<String, dynamic> json = validRequest.toJson();

        // Verify all expected fields are present
        expect(json, containsPair('name', 'The Smith Family'));
        expect(json, contains('settings'));

        // Verify data types
        expect(json['name'], isA<String>());
        expect(json['settings'], isA<Map<String, dynamic>>());
      });

      /// Tests round-trip serialization (toJson -> fromJson).
      ///
      /// This test verifies that a FamilyCreateRequest instance can be serialized to JSON and then deserialized back
      /// to an equivalent FamilyCreateRequest instance without data loss.
      test('should support round-trip serialization', () {
        final Map<String, dynamic> json = validRequest.toJson();
        final FamilyCreateRequest deserializedRequest = FamilyCreateRequest.fromJson(json);

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

      /// Tests that validate method identifies empty names.
      ///
      /// This test ensures that the validate method properly detects and reports empty family names.
      test('should return error for empty name', () {
        const FamilyCreateRequest invalidRequest = FamilyCreateRequest(
          name: '',
        );

        final List<String> errors = invalidRequest.validate();

        expect(errors, isNotEmpty);
        expect(errors.first, contains('Family name cannot be empty'));
      });

      /// Tests that validate method identifies names that are too long.
      ///
      /// This test ensures that the validate method properly detects and reports family names that exceed the maximum
      /// length.
      test('should return error for name exceeding maximum length', () {
        final String longName = 'A' * 101; // 101 characters
        final FamilyCreateRequest invalidRequest = FamilyCreateRequest(
          name: longName,
        );

        final List<String> errors = invalidRequest.validate();

        expect(errors, isNotEmpty);
        expect(errors.first, contains('Family name cannot exceed 100 characters'));
      });

      /// Tests that validate method handles whitespace-only names.
      ///
      /// This test ensures that the validate method properly detects names consisting only of whitespace.
      test('should return error for whitespace-only name', () {
        const FamilyCreateRequest invalidRequest = FamilyCreateRequest(
          name: '   ',
        );

        final List<String> errors = invalidRequest.validate();

        expect(errors, isNotEmpty);
        expect(errors.first, contains('Family name cannot be empty'));
      });

      /// Tests that validate method accepts names at boundary lengths.
      ///
      /// This test verifies that the validate method correctly handles names at the minimum and maximum allowed
      /// lengths.
      test('should accept names at boundary lengths', () {
        // Test minimum length (1 character)
        const FamilyCreateRequest minRequest = FamilyCreateRequest(
          name: 'A',
        );
        expect(minRequest.validate(), isEmpty);

        // Test maximum length (100 characters)
        final String maxName = 'A' * 100;
        final FamilyCreateRequest maxRequest = FamilyCreateRequest(
          name: maxName,
        );
        expect(maxRequest.validate(), isEmpty);
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
        const FamilyCreateRequest invalidRequest = FamilyCreateRequest(
          name: '',
        );

        expect(invalidRequest.isValid, isFalse);
      });

      /// Tests that isValid handles edge cases correctly.
      ///
      /// This test verifies that the isValid getter works correctly for boundary conditions.
      test('should handle edge cases correctly', () {
        // Valid edge case: exactly 100 characters
        final String maxName = 'A' * 100;
        final FamilyCreateRequest maxRequest = FamilyCreateRequest(
          name: maxName,
        );
        expect(maxRequest.isValid, isTrue);

        // Invalid edge case: 101 characters
        final String tooLongName = 'A' * 101;
        final FamilyCreateRequest tooLongRequest = FamilyCreateRequest(
          name: tooLongName,
        );
        expect(tooLongRequest.isValid, isFalse);
      });
    });

    group('equality and hashCode', () {
      /// Tests that identical FamilyCreateRequest instances are considered equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyCreateRequest instances with
      /// identical field values as equal.
      test('should consider FamilyCreateRequests with identical values as equal', () {
        final FamilySettings settings = FamilySettings.fromJson(validSettingsJson);

        final FamilyCreateRequest request1 = FamilyCreateRequest(
          name: 'Test Family',
          settings: settings,
        );

        final FamilyCreateRequest request2 = FamilyCreateRequest(
          name: 'Test Family',
          settings: settings,
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      /// Tests that FamilyCreateRequest instances with different values are not equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyCreateRequest instances with
      /// different field values as not equal.
      test('should consider FamilyCreateRequests with different values as not equal', () {
        final FamilyCreateRequest request1 = validRequest;
        const FamilyCreateRequest request2 = FamilyCreateRequest(
          name: 'Different Family Name',
        );

        expect(request1, isNot(equals(request2)));
        expect(request1.hashCode, isNot(equals(request2.hashCode)));
      });

      /// Tests that a FamilyCreateRequest instance is equal to itself.
      ///
      /// This test verifies the reflexive property of equality, ensuring that any FamilyCreateRequest instance is
      /// equal to itself.
      test('should be equal to itself', () {
        expect(validRequest, equals(validRequest));
        expect(validRequest.hashCode, equals(validRequest.hashCode));
      });

      /// Tests that FamilyCreateRequest instances with null optional fields handle equality correctly.
      ///
      /// This test ensures that equality comparison works correctly when optional fields are null in one or both
      /// instances.
      test('should handle null optional fields in equality comparison', () {
        const FamilyCreateRequest requestWithNulls = FamilyCreateRequest(
          name: 'Test Family',
        );

        const FamilyCreateRequest anotherRequestWithNulls = FamilyCreateRequest(
          name: 'Test Family',
        );

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

        expect(stringRepresentation, contains('FamilyCreateRequest('));
        expect(stringRepresentation, contains('name: The Smith Family'));
        expect(stringRepresentation, contains('settings: '));
      });

      /// Tests that toString handles null optional fields correctly.
      ///
      /// This test ensures that the toString method properly displays null values for optional fields without causing
      /// errors.
      test('should handle null optional fields in string representation', () {
        const FamilyCreateRequest requestWithNulls = FamilyCreateRequest(
          name: 'Test Family',
        );

        final String stringRepresentation = requestWithNulls.toString();

        expect(stringRepresentation, contains('settings: null'));
      });
    });

    group('name validation edge cases', () {
      /// Tests various edge cases for name validation.
      ///
      /// This test ensures that the validation logic correctly handles various edge cases and special characters.
      test('should handle various name formats correctly', () {
        final List<String> validNames = [
          'Smith Family',
          'The Johnson-Williams Household',
          "Family O'Connor",
          'Casa de García',
          'Müller Familie',
          '123 Main Street Family',
          'A', // Minimum length
          'A' * 100, // Maximum length
        ];

        for (final String name in validNames) {
          final FamilyCreateRequest request = FamilyCreateRequest(name: name);
          expect(
            request.isValid,
            isTrue,
            reason: 'Name "$name" should be valid',
          );
        }
      });

      /// Tests that special characters in names are handled correctly.
      ///
      /// This test verifies that family names with various special characters are properly accepted or rejected.
      test('should handle special characters in names', () {
        final List<String> namesWithSpecialChars = [
          'Family & Friends',
          'Smith-Jones Family',
          "The O'Malley Clan",
          'Café Family',
          'Family #1',
          'Family @ Home',
        ];

        for (final String name in namesWithSpecialChars) {
          final FamilyCreateRequest request = FamilyCreateRequest(name: name);
          // All these should be valid as we don't restrict special characters
          expect(
            request.isValid,
            isTrue,
            reason: 'Name "$name" should be valid',
          );
        }
      });
    });
  });
}
