import 'package:staccato_api_server/models/family_invitation_create_request.dart';
import 'package:staccato_api_server/models/user.dart';
import 'package:test/test.dart';

void main() {
  group('FamilyInvitationCreateRequest', () {
    /// Sample valid family invitation create request data for testing successful operations.
    ///
    /// This data represents a typical invitation creation request with all fields populated. Used as a baseline for
    /// most tests.
    late Map<String, dynamic> validRequestJson;

    /// Sample FamilyInvitationCreateRequest instance created from valid data.
    ///
    /// This instance is used for testing methods that operate on existing FamilyInvitationCreateRequest objects, such
    /// as validation and toJson.
    late FamilyInvitationCreateRequest validRequest;

    /// Set up test data before each test.
    ///
    /// Creates fresh instances of test data to ensure test isolation and prevent interference between tests. All test
    /// data represents valid request information unless specifically testing error conditions.
    setUp(() {
      validRequestJson = <String, dynamic>{
        'targetPermissionLevel': 'child',
        'invitedEmail': 'child@example.com',
        'invitedDisplayName': 'Little Johnny',
        'expirationDays': 7,
      };

      validRequest = const FamilyInvitationCreateRequest(
        targetPermissionLevel: UserPermissionLevel.child,
        invitedEmail: 'child@example.com',
        invitedDisplayName: 'Little Johnny',
      );
    });

    group('constructor', () {
      /// Verifies that the FamilyInvitationCreateRequest constructor properly assigns all provided values.
      ///
      /// This test ensures that all constructor parameters are correctly stored as instance fields and that the object
      /// is properly initialized with the expected values.
      test('should create FamilyInvitationCreateRequest with all provided values', () {
        const FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.adult,
          invitedEmail: 'test@example.com',
          invitedDisplayName: 'Test User',
          expirationDays: 14,
        );

        expect(request.targetPermissionLevel, equals(UserPermissionLevel.adult));
        expect(request.invitedEmail, equals('test@example.com'));
        expect(request.invitedDisplayName, equals('Test User'));
        expect(request.expirationDays, equals(14));
      });

      /// Verifies that optional fields can be omitted during construction.
      ///
      /// This test ensures that the FamilyInvitationCreateRequest constructor works correctly when only required fields
      /// are provided, with optional fields using their default values.
      test('should create FamilyInvitationCreateRequest with only required fields', () {
        const FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.child,
        );

        expect(request.targetPermissionLevel, equals(UserPermissionLevel.child));
        expect(request.invitedEmail, isNull);
        expect(request.invitedDisplayName, isNull);
        expect(request.expirationDays, equals(7)); // Default value
      });

      /// Verifies that default values are properly applied.
      ///
      /// This test ensures that the constructor applies the correct default value for expirationDays.
      test('should apply default values correctly', () {
        const FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.adult,
        );

        expect(request.expirationDays, equals(7));
      });
    });

    group('fromJson', () {
      /// Tests successful JSON deserialization with all fields present.
      ///
      /// This test verifies that the fromJson factory constructor correctly parses a complete JSON object and creates a
      /// FamilyInvitationCreateRequest instance with all fields properly populated and typed.
      test('should create FamilyInvitationCreateRequest from valid JSON with all fields', () {
        final FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest.fromJson(validRequestJson);

        expect(request.targetPermissionLevel, equals(UserPermissionLevel.child));
        expect(request.invitedEmail, equals('child@example.com'));
        expect(request.invitedDisplayName, equals('Little Johnny'));
        expect(request.expirationDays, equals(7));
      });

      /// Tests JSON deserialization with only required fields present.
      ///
      /// This test ensures that the fromJson constructor works correctly when optional fields are missing from the
      /// JSON, applying default values as expected.
      test('should create FamilyInvitationCreateRequest from JSON with only required fields', () {
        final Map<String, dynamic> minimalJson = <String, dynamic>{
          'targetPermissionLevel': 'adult',
        };

        final FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest.fromJson(minimalJson);

        expect(request.targetPermissionLevel, equals(UserPermissionLevel.adult));
        expect(request.invitedEmail, isNull);
        expect(request.invitedDisplayName, isNull);
        expect(request.expirationDays, equals(7)); // Default value
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
          final Map<String, dynamic> json = <String, dynamic>{
            'targetPermissionLevel': permissionLevels[i],
          };

          final FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest.fromJson(json);
          expect(request.targetPermissionLevel, equals(expectedLevels[i]));
        }
      });

      /// Tests JSON deserialization with custom expiration days.
      ///
      /// This test verifies that custom expiration day values are properly parsed and validated.
      test('should handle custom expiration days correctly', () {
        final List<int> validExpirationDays = [1, 7, 14, 30];

        for (final int days in validExpirationDays) {
          final Map<String, dynamic> json = <String, dynamic>{
            'targetPermissionLevel': 'child',
            'expirationDays': days,
          };

          final FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest.fromJson(json);
          expect(request.expirationDays, equals(days));
        }
      });

      group('error handling', () {
        /// Tests that missing required fields throw appropriate errors.
        ///
        /// This test ensures that the fromJson constructor validates all required fields and throws descriptive
        /// ArgumentError exceptions when required data is missing.
        test('should throw ArgumentError for missing targetPermissionLevel field', () {
          final Map<String, dynamic> incompleteJson = <String, dynamic>{
            'invitedEmail': 'test@example.com',
          };

          expect(
            () => FamilyInvitationCreateRequest.fromJson(incompleteJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Missing or empty required field: targetPermissionLevel'),
              ),
            ),
          );
        });

        /// Tests that empty string values for required fields throw errors.
        ///
        /// This test ensures that required fields cannot be empty strings.
        test('should throw ArgumentError for empty targetPermissionLevel field', () {
          final Map<String, dynamic> invalidJson = <String, dynamic>{
            'targetPermissionLevel': '',
          };

          expect(
            () => FamilyInvitationCreateRequest.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Missing or empty required field: targetPermissionLevel'),
              ),
            ),
          );
        });

        /// Tests that invalid permission levels throw appropriate errors.
        ///
        /// This test verifies that the fromJson constructor properly validates permission level values and throws
        /// descriptive errors for invalid values.
        test('should throw ArgumentError for invalid permission level', () {
          final Map<String, dynamic> invalidJson = <String, dynamic>{
            'targetPermissionLevel': 'invalid_level',
          };

          expect(
            () => FamilyInvitationCreateRequest.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Invalid permission level: invalid_level'),
              ),
            ),
          );
        });

        /// Tests that invalid expiration days throw appropriate errors.
        ///
        /// This test ensures that expiration days must be within the valid range of 1-30 days.
        test('should throw ArgumentError for invalid expiration days', () {
          final List<int> invalidDays = [0, -1, 31, 100];

          for (final int days in invalidDays) {
            final Map<String, dynamic> invalidJson = <String, dynamic>{
              'targetPermissionLevel': 'child',
              'expirationDays': days,
            };

            expect(
              () => FamilyInvitationCreateRequest.fromJson(invalidJson),
              throwsA(
                isA<FormatException>().having(
                  (FormatException e) => e.message,
                  'message',
                  contains('Expiration days must be between 1 and 30'),
                ),
              ),
              reason: 'Should throw FormatException for expiration days: $days',
            );
          }
        });

        /// Tests that invalid email formats throw appropriate errors.
        ///
        /// This test verifies that the fromJson constructor validates email format when provided.
        test('should throw ArgumentError for invalid email format', () {
          final List<String> invalidEmails = [
            'invalid-email',
            '@example.com',
            'test@',
            'test..test@example.com',
            'test@example',
          ];

          for (final String email in invalidEmails) {
            final Map<String, dynamic> invalidJson = <String, dynamic>{
              'targetPermissionLevel': 'child',
              'invitedEmail': email,
            };

            expect(
              () => FamilyInvitationCreateRequest.fromJson(invalidJson),
              throwsA(
                isA<FormatException>().having(
                  (FormatException e) => e.message,
                  'message',
                  contains('Invalid email format: $email'),
                ),
              ),
              reason: 'Should throw FormatException for invalid email: $email',
            );
          }
        });

        /// Tests that null values for required fields throw errors.
        ///
        /// This test verifies that explicitly null values for required fields are properly detected and result in
        /// appropriate error messages.
        test('should throw ArgumentError for null targetPermissionLevel field', () {
          final Map<String, dynamic> nullJson = <String, dynamic>{
            'targetPermissionLevel': null,
          };

          expect(
            () => FamilyInvitationCreateRequest.fromJson(nullJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Missing or empty required field: targetPermissionLevel'),
              ),
            ),
          );
        });
      });
    });

    group('toJson', () {
      /// Tests successful JSON serialization with all fields present.
      ///
      /// This test verifies that the toJson method correctly converts a FamilyInvitationCreateRequest instance to a
      /// JSON map with all fields properly formatted and typed.
      test('should convert FamilyInvitationCreateRequest to JSON with all fields', () {
        final Map<String, dynamic> json = validRequest.toJson();

        expect(json['targetPermissionLevel'], equals('child'));
        expect(json['invitedEmail'], equals('child@example.com'));
        expect(json['invitedDisplayName'], equals('Little Johnny'));
        expect(json['expirationDays'], equals(7));
      });

      /// Tests JSON serialization with null optional fields.
      ///
      /// This test ensures that the toJson method properly handles null values for optional fields, including them in
      /// the JSON with null values.
      test('should convert FamilyInvitationCreateRequest to JSON with null optional fields', () {
        const FamilyInvitationCreateRequest requestWithNulls = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.adult,
          expirationDays: 14,
        );

        final Map<String, dynamic> json = requestWithNulls.toJson();

        expect(json['targetPermissionLevel'], equals('adult'));
        expect(json['invitedEmail'], isNull);
        expect(json['invitedDisplayName'], isNull);
        expect(json['expirationDays'], equals(14));
      });

      /// Tests that JSON serialization produces expected structure.
      ///
      /// This test verifies that the JSON output contains all expected fields with correct types and can be used for
      /// round-trip serialization.
      test('should produce expected JSON structure', () {
        final Map<String, dynamic> json = validRequest.toJson();

        // Verify all expected fields are present
        expect(json, containsPair('targetPermissionLevel', 'child'));
        expect(json, containsPair('invitedEmail', 'child@example.com'));
        expect(json, containsPair('invitedDisplayName', 'Little Johnny'));
        expect(json, containsPair('expirationDays', 7));

        // Verify data types
        expect(json['targetPermissionLevel'], isA<String>());
        expect(json['invitedEmail'], isA<String>());
        expect(json['invitedDisplayName'], isA<String>());
        expect(json['expirationDays'], isA<int>());
      });

      /// Tests round-trip serialization (toJson -> fromJson).
      ///
      /// This test verifies that a FamilyInvitationCreateRequest instance can be serialized to JSON and then
      /// deserialized back to an equivalent FamilyInvitationCreateRequest instance without data loss.
      test('should support round-trip serialization', () {
        final Map<String, dynamic> json = validRequest.toJson();
        final FamilyInvitationCreateRequest deserializedRequest = FamilyInvitationCreateRequest.fromJson(json);

        expect(deserializedRequest.targetPermissionLevel, equals(validRequest.targetPermissionLevel));
        expect(deserializedRequest.invitedEmail, equals(validRequest.invitedEmail));
        expect(deserializedRequest.invitedDisplayName, equals(validRequest.invitedDisplayName));
        expect(deserializedRequest.expirationDays, equals(validRequest.expirationDays));
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

      /// Tests that validate method identifies invalid expiration days.
      ///
      /// This test ensures that the validate method properly detects and reports invalid expiration day values.
      test('should return error for invalid expiration days', () {
        const FamilyInvitationCreateRequest invalidRequest = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.child,
          expirationDays: 0,
        );

        final List<String> errors = invalidRequest.validate();

        expect(errors, isNotEmpty);
        expect(errors.first, contains('Expiration days must be between 1 and 30'));
      });

      /// Tests that validate method identifies invalid email formats.
      ///
      /// This test ensures that the validate method properly detects and reports invalid email formats.
      test('should return error for invalid email format', () {
        const FamilyInvitationCreateRequest invalidRequest = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.child,
          invitedEmail: 'invalid-email',
        );

        final List<String> errors = invalidRequest.validate();

        expect(errors, isNotEmpty);
        expect(errors.first, contains('Invalid email format'));
      });

      /// Tests that validate method identifies display names that are too long.
      ///
      /// This test ensures that the validate method properly detects and reports display names that exceed the maximum
      /// length.
      test('should return error for display name exceeding maximum length', () {
        final String longName = 'A' * 101; // 101 characters
        final FamilyInvitationCreateRequest invalidRequest = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.child,
          invitedDisplayName: longName,
        );

        final List<String> errors = invalidRequest.validate();

        expect(errors, isNotEmpty);
        expect(errors.first, contains('Display name cannot exceed 100 characters'));
      });

      /// Tests that validate method accepts valid boundary values.
      ///
      /// This test verifies that the validate method correctly handles values at the minimum and maximum allowed
      /// boundaries.
      test('should accept valid boundary values', () {
        // Test minimum expiration days
        const FamilyInvitationCreateRequest minRequest = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.child,
          expirationDays: 1,
        );
        expect(minRequest.validate(), isEmpty);

        // Test maximum expiration days
        const FamilyInvitationCreateRequest maxRequest = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.child,
          expirationDays: 30,
        );
        expect(maxRequest.validate(), isEmpty);

        // Test maximum display name length
        final String maxName = 'A' * 100;
        final FamilyInvitationCreateRequest maxNameRequest = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.child,
          invitedDisplayName: maxName,
        );
        expect(maxNameRequest.validate(), isEmpty);
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
        const FamilyInvitationCreateRequest invalidRequest = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.child,
          expirationDays: 0,
        );

        expect(invalidRequest.isValid, isFalse);
      });
    });

    group('calculateExpirationDate', () {
      /// Tests that calculateExpirationDate returns correct future date.
      ///
      /// This test verifies that the calculateExpirationDate method correctly calculates the expiration date based on
      /// the expiration days.
      test('should calculate correct expiration date', () {
        const FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.child,
        );

        final DateTime beforeCalculation = DateTime.now();
        final DateTime expirationDate = request.calculateExpirationDate();
        final DateTime afterCalculation = DateTime.now();

        // The expiration date should be approximately 7 days from now
        const Duration expectedDuration = Duration(days: 7);
        final DateTime expectedMinDate = beforeCalculation.add(expectedDuration);
        final DateTime expectedMaxDate = afterCalculation.add(expectedDuration);

        expect(expirationDate.isAfter(expectedMinDate.subtract(const Duration(seconds: 1))), isTrue);
        expect(expirationDate.isBefore(expectedMaxDate.add(const Duration(seconds: 1))), isTrue);
      });

      /// Tests that calculateExpirationDate works with different expiration days.
      ///
      /// This test verifies that the calculateExpirationDate method correctly handles different expiration day values.
      test('should calculate correct expiration date for different days', () {
        final List<int> expirationDays = [1, 7, 14, 30];

        for (final int days in expirationDays) {
          final FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest(
            targetPermissionLevel: UserPermissionLevel.child,
            expirationDays: days,
          );

          final DateTime beforeCalculation = DateTime.now();
          final DateTime expirationDate = request.calculateExpirationDate();

          final Duration expectedDuration = Duration(days: days);
          final DateTime expectedDate = beforeCalculation.add(expectedDuration);

          // Allow for small time differences due to execution time
          final Duration difference = expirationDate.difference(expectedDate).abs();
          expect(difference.inSeconds, lessThan(2));
        }
      });
    });

    group('canBeCreatedBy', () {
      /// Tests that canBeCreatedBy correctly validates permission hierarchies.
      ///
      /// This test verifies that the canBeCreatedBy method correctly enforces permission level hierarchies for
      /// invitation creation.
      test('should correctly validate permission hierarchies', () {
        // Primary users can invite anyone
        const FamilyInvitationCreateRequest primaryInvite = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.primary,
        );
        const FamilyInvitationCreateRequest adultInvite = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.adult,
        );
        const FamilyInvitationCreateRequest childInvite = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.child,
        );

        // Primary user creating invitations
        expect(primaryInvite.canBeCreatedBy(UserPermissionLevel.primary), isFalse); // Can't invite equal level
        expect(adultInvite.canBeCreatedBy(UserPermissionLevel.primary), isTrue);
        expect(childInvite.canBeCreatedBy(UserPermissionLevel.primary), isTrue);

        // Adult user creating invitations
        expect(primaryInvite.canBeCreatedBy(UserPermissionLevel.adult), isFalse); // Can't invite higher level
        expect(adultInvite.canBeCreatedBy(UserPermissionLevel.adult), isFalse); // Can't invite equal level
        expect(childInvite.canBeCreatedBy(UserPermissionLevel.adult), isTrue);

        // Child user creating invitations
        expect(primaryInvite.canBeCreatedBy(UserPermissionLevel.child), isFalse);
        expect(adultInvite.canBeCreatedBy(UserPermissionLevel.child), isFalse);
        expect(childInvite.canBeCreatedBy(UserPermissionLevel.child), isFalse); // Children can't create invitations
      });

      /// Tests that canBeCreatedBy rejects child users from creating invitations.
      ///
      /// This test verifies that child users are never allowed to create invitations, regardless of the target
      /// permission level.
      test('should reject child users from creating invitations', () {
        final List<UserPermissionLevel> targetLevels = [
          UserPermissionLevel.primary,
          UserPermissionLevel.adult,
          UserPermissionLevel.child,
        ];

        for (final UserPermissionLevel targetLevel in targetLevels) {
          final FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest(
            targetPermissionLevel: targetLevel,
          );

          expect(
            request.canBeCreatedBy(UserPermissionLevel.child),
            isFalse,
            reason: 'Child users should not be able to create invitations for $targetLevel',
          );
        }
      });
    });

    group('equality and hashCode', () {
      /// Tests that identical FamilyInvitationCreateRequest instances are considered equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyInvitationCreateRequest instances
      /// with identical field values as equal.
      test('should consider FamilyInvitationCreateRequests with identical values as equal', () {
        const FamilyInvitationCreateRequest request1 = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.adult,
          invitedEmail: 'test@example.com',
          invitedDisplayName: 'Test User',
          expirationDays: 14,
        );

        const FamilyInvitationCreateRequest request2 = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.adult,
          invitedEmail: 'test@example.com',
          invitedDisplayName: 'Test User',
          expirationDays: 14,
        );

        expect(request1, equals(request2));
        expect(request1.hashCode, equals(request2.hashCode));
      });

      /// Tests that FamilyInvitationCreateRequest instances with different values are not equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyInvitationCreateRequest instances
      /// with different field values as not equal.
      test('should consider FamilyInvitationCreateRequests with different values as not equal', () {
        final FamilyInvitationCreateRequest request1 = validRequest;
        const FamilyInvitationCreateRequest request2 = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.adult,
        );

        expect(request1, isNot(equals(request2)));
        expect(request1.hashCode, isNot(equals(request2.hashCode)));
      });

      /// Tests that a FamilyInvitationCreateRequest instance is equal to itself.
      ///
      /// This test verifies the reflexive property of equality, ensuring that any FamilyInvitationCreateRequest
      /// instance is equal to itself.
      test('should be equal to itself', () {
        expect(validRequest, equals(validRequest));
        expect(validRequest.hashCode, equals(validRequest.hashCode));
      });

      /// Tests that FamilyInvitationCreateRequest instances with null optional fields handle equality correctly.
      ///
      /// This test ensures that equality comparison works correctly when optional fields are null in one or both
      /// instances.
      test('should handle null optional fields in equality comparison', () {
        const FamilyInvitationCreateRequest requestWithNulls = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.adult,
        );

        const FamilyInvitationCreateRequest anotherRequestWithNulls = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.adult,
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

        expect(stringRepresentation, contains('FamilyInvitationCreateRequest('));
        expect(stringRepresentation, contains('targetPermissionLevel: child'));
        expect(stringRepresentation, contains('invitedEmail: child@example.com'));
        expect(stringRepresentation, contains('invitedDisplayName: Little Johnny'));
        expect(stringRepresentation, contains('expirationDays: 7'));
      });

      /// Tests that toString handles null optional fields correctly.
      ///
      /// This test ensures that the toString method properly displays null values for optional fields without causing
      /// errors.
      test('should handle null optional fields in string representation', () {
        const FamilyInvitationCreateRequest requestWithNulls = FamilyInvitationCreateRequest(
          targetPermissionLevel: UserPermissionLevel.adult,
        );

        final String stringRepresentation = requestWithNulls.toString();

        expect(stringRepresentation, contains('invitedEmail: null'));
        expect(stringRepresentation, contains('invitedDisplayName: null'));
      });
    });

    group('email validation', () {
      /// Tests various valid email formats.
      ///
      /// This test ensures that the email validation correctly accepts various valid email formats.
      test('should accept valid email formats', () {
        final List<String> validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
          'user_name@example-domain.com',
          'a@b.co',
          '123@456.com',
        ];

        for (final String email in validEmails) {
          final FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest(
            targetPermissionLevel: UserPermissionLevel.child,
            invitedEmail: email,
          );

          expect(
            request.isValid,
            isTrue,
            reason: 'Email "$email" should be valid',
          );
        }
      });

      /// Tests various invalid email formats.
      ///
      /// This test ensures that the email validation correctly rejects various invalid email formats.
      test('should reject invalid email formats', () {
        final List<String> invalidEmails = [
          'invalid-email',
          '@example.com',
          'test@',
          'test..test@example.com',
          'test@example',
          'test@.com',
          'test@example.',
          '',
          ' ',
        ];

        for (final String email in invalidEmails) {
          final FamilyInvitationCreateRequest request = FamilyInvitationCreateRequest(
            targetPermissionLevel: UserPermissionLevel.child,
            invitedEmail: email,
          );

          expect(
            request.isValid,
            isFalse,
            reason: 'Email "$email" should be invalid',
          );
        }
      });
    });
  });
}
