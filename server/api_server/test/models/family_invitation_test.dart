import 'package:staccato_api_server/models/family_invitation.dart';
import 'package:staccato_api_server/models/user.dart';
import 'package:test/test.dart';

void main() {
  group('FamilyInvitation', () {
    /// Sample valid family invitation data for testing successful operations.
    ///
    /// This data represents a typical invitation with all required fields and some optional fields populated. Used as a
    /// baseline for most tests.
    late Map<String, dynamic> validInvitationJson;

    /// Sample FamilyInvitation instance created from valid data.
    ///
    /// This instance is used for testing methods that operate on existing FamilyInvitation objects, such as copyWith
    /// and toJson.
    late FamilyInvitation validInvitation;

    /// Set up test data before each test.
    ///
    /// Creates fresh instances of test data to ensure test isolation and prevent interference between tests. All test
    /// data represents valid invitation information unless specifically testing error conditions.
    setUp(() {
      validInvitationJson = <String, dynamic>{
        'id': 'invitation_123',
        'familyId': 'family_456',
        'invitedByUserId': 'user_789',
        'invitationCode': 'ABC123XYZ',
        'targetPermissionLevel': 'child',
        'status': 'pending',
        'expiresAt': '2025-01-17T14:30:00.000Z',
        'createdAt': '2025-01-10T14:30:00.000Z',
        'invitedEmail': 'child@example.com',
        'invitedDisplayName': 'Little Johnny',
        'acceptedAt': null,
        'acceptedByUserId': null,
        'updatedAt': '2025-01-10T15:00:00.000Z',
      };

      validInvitation = FamilyInvitation(
        id: 'invitation_123',
        familyId: 'family_456',
        invitedByUserId: 'user_789',
        invitationCode: 'ABC123XYZ',
        targetPermissionLevel: UserPermissionLevel.child,
        status: FamilyInvitationStatus.pending,
        expiresAt: DateTime.parse('2025-01-17T14:30:00.000Z'),
        createdAt: DateTime.parse('2025-01-10T14:30:00.000Z'),
        invitedEmail: 'child@example.com',
        invitedDisplayName: 'Little Johnny',
        updatedAt: DateTime.parse('2025-01-10T15:00:00.000Z'),
      );
    });

    group('constructor', () {
      /// Verifies that the FamilyInvitation constructor properly assigns all provided values.
      ///
      /// This test ensures that all constructor parameters are correctly stored as instance fields and that the object
      /// is properly initialized with the expected values.
      test('should create FamilyInvitation with all provided values', () {
        final DateTime createdAt = DateTime.now();
        final DateTime expiresAt = DateTime.now().add(const Duration(days: 7));
        final DateTime acceptedAt = DateTime.now().add(const Duration(hours: 1));
        final DateTime updatedAt = DateTime.now().add(const Duration(hours: 2));

        final FamilyInvitation invitation = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.adult,
          status: FamilyInvitationStatus.accepted,
          expiresAt: expiresAt,
          createdAt: createdAt,
          invitedEmail: 'test@example.com',
          invitedDisplayName: 'Test User',
          acceptedAt: acceptedAt,
          acceptedByUserId: 'accepted_user',
          updatedAt: updatedAt,
        );

        expect(invitation.id, equals('test_id'));
        expect(invitation.familyId, equals('test_family'));
        expect(invitation.invitedByUserId, equals('test_user'));
        expect(invitation.invitationCode, equals('TEST123'));
        expect(invitation.targetPermissionLevel, equals(UserPermissionLevel.adult));
        expect(invitation.status, equals(FamilyInvitationStatus.accepted));
        expect(invitation.expiresAt, equals(expiresAt));
        expect(invitation.createdAt, equals(createdAt));
        expect(invitation.invitedEmail, equals('test@example.com'));
        expect(invitation.invitedDisplayName, equals('Test User'));
        expect(invitation.acceptedAt, equals(acceptedAt));
        expect(invitation.acceptedByUserId, equals('accepted_user'));
        expect(invitation.updatedAt, equals(updatedAt));
      });

      /// Verifies that optional fields can be omitted during construction.
      ///
      /// This test ensures that the FamilyInvitation constructor works correctly when only required fields are
      /// provided, with optional fields defaulting to null as expected.
      test('should create FamilyInvitation with only required fields', () {
        final DateTime createdAt = DateTime.now();
        final DateTime expiresAt = DateTime.now().add(const Duration(days: 7));

        final FamilyInvitation invitation = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.child,
          status: FamilyInvitationStatus.pending,
          expiresAt: expiresAt,
          createdAt: createdAt,
        );

        expect(invitation.id, equals('test_id'));
        expect(invitation.familyId, equals('test_family'));
        expect(invitation.invitedByUserId, equals('test_user'));
        expect(invitation.invitationCode, equals('TEST123'));
        expect(invitation.targetPermissionLevel, equals(UserPermissionLevel.child));
        expect(invitation.status, equals(FamilyInvitationStatus.pending));
        expect(invitation.expiresAt, equals(expiresAt));
        expect(invitation.createdAt, equals(createdAt));
        expect(invitation.invitedEmail, isNull);
        expect(invitation.invitedDisplayName, isNull);
        expect(invitation.acceptedAt, isNull);
        expect(invitation.acceptedByUserId, isNull);
        expect(invitation.updatedAt, isNull);
      });
    });

    group('computed properties', () {
      /// Tests the isValid property for different invitation states.
      ///
      /// This test verifies that the isValid getter correctly identifies invitations that can still be accepted based
      /// on their status and expiration date.
      test('should return correct isValid value for different states', () {
        final DateTime pastDate = DateTime.now().subtract(const Duration(days: 1));

        // Valid pending invitation with future expiration
        final DateTime futureDate = DateTime.now().add(const Duration(days: 1));
        final FamilyInvitation validPending = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.child,
          status: FamilyInvitationStatus.pending,
          expiresAt: futureDate,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        expect(validPending.isValid, isTrue);

        // Expired pending invitation
        final FamilyInvitation expiredPending = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.child,
          status: FamilyInvitationStatus.pending,
          expiresAt: pastDate,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );
        expect(expiredPending.isValid, isFalse);

        // Accepted invitation
        final FamilyInvitation accepted = validInvitation.copyWith(
          status: FamilyInvitationStatus.accepted,
        );
        expect(accepted.isValid, isFalse);

        // Cancelled invitation
        final FamilyInvitation cancelled = validInvitation.copyWith(
          status: FamilyInvitationStatus.cancelled,
        );
        expect(cancelled.isValid, isFalse);
      });

      /// Tests the isExpired property for different expiration dates.
      ///
      /// This test verifies that the isExpired getter correctly identifies invitations that have passed their
      /// expiration date.
      test('should return correct isExpired value for different dates', () {
        final DateTime futureDate = DateTime.now().add(const Duration(days: 1));
        final DateTime pastDate = DateTime.now().subtract(const Duration(days: 1));

        final FamilyInvitation futureInvitation = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.child,
          status: FamilyInvitationStatus.pending,
          expiresAt: futureDate,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );

        final FamilyInvitation pastInvitation = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.child,
          status: FamilyInvitationStatus.pending,
          expiresAt: pastDate,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        );

        expect(futureInvitation.isExpired, isFalse);
        expect(pastInvitation.isExpired, isTrue);
      });

      /// Tests the isAccepted property for different invitation states.
      ///
      /// This test verifies that the isAccepted getter correctly identifies invitations that have been successfully
      /// accepted.
      test('should return correct isAccepted value for different states', () {
        // Accepted invitation with user ID
        final FamilyInvitation accepted = validInvitation.copyWith(
          status: FamilyInvitationStatus.accepted,
          acceptedByUserId: 'user_123',
        );
        expect(accepted.isAccepted, isTrue);

        // Accepted status but no user ID (inconsistent state)
        final FamilyInvitation acceptedNoUser = validInvitation.copyWith(
          status: FamilyInvitationStatus.accepted,
        );
        expect(acceptedNoUser.isAccepted, isFalse);

        // Pending invitation
        final FamilyInvitation pending = validInvitation.copyWith(
          status: FamilyInvitationStatus.pending,
        );
        expect(pending.isAccepted, isFalse);

        // Cancelled invitation
        final FamilyInvitation cancelled = validInvitation.copyWith(
          status: FamilyInvitationStatus.cancelled,
        );
        expect(cancelled.isAccepted, isFalse);
      });
    });

    group('fromJson', () {
      /// Tests successful JSON deserialization with all fields present.
      ///
      /// This test verifies that the fromJson factory constructor correctly parses a complete JSON object and creates a
      /// FamilyInvitation instance with all fields properly populated and typed.
      test('should create FamilyInvitation from valid JSON with all fields', () {
        final FamilyInvitation invitation = FamilyInvitation.fromJson(validInvitationJson);

        expect(invitation.id, equals('invitation_123'));
        expect(invitation.familyId, equals('family_456'));
        expect(invitation.invitedByUserId, equals('user_789'));
        expect(invitation.invitationCode, equals('ABC123XYZ'));
        expect(invitation.targetPermissionLevel, equals(UserPermissionLevel.child));
        expect(invitation.status, equals(FamilyInvitationStatus.pending));
        expect(
          invitation.expiresAt,
          equals(DateTime.parse('2025-01-17T14:30:00.000Z')),
        );
        expect(
          invitation.createdAt,
          equals(DateTime.parse('2025-01-10T14:30:00.000Z')),
        );
        expect(invitation.invitedEmail, equals('child@example.com'));
        expect(invitation.invitedDisplayName, equals('Little Johnny'));
        expect(invitation.acceptedAt, isNull);
        expect(invitation.acceptedByUserId, isNull);
        expect(
          invitation.updatedAt,
          equals(DateTime.parse('2025-01-10T15:00:00.000Z')),
        );
      });

      /// Tests JSON deserialization with only required fields present.
      ///
      /// This test ensures that the fromJson constructor works correctly when optional fields are missing from the
      /// JSON, setting them to null as expected.
      test('should create FamilyInvitation from JSON with only required fields', () {
        final Map<String, dynamic> minimalJson = <String, dynamic>{
          'id': 'invitation_456',
          'familyId': 'family_789',
          'invitedByUserId': 'user_123',
          'invitationCode': 'XYZ789ABC',
          'targetPermissionLevel': 'adult',
          'status': 'pending',
          'expiresAt': '2025-01-20T16:00:00.000Z',
          'createdAt': '2025-01-10T16:00:00.000Z',
        };

        final FamilyInvitation invitation = FamilyInvitation.fromJson(minimalJson);

        expect(invitation.id, equals('invitation_456'));
        expect(invitation.familyId, equals('family_789'));
        expect(invitation.invitedByUserId, equals('user_123'));
        expect(invitation.invitationCode, equals('XYZ789ABC'));
        expect(invitation.targetPermissionLevel, equals(UserPermissionLevel.adult));
        expect(invitation.status, equals(FamilyInvitationStatus.pending));
        expect(
          invitation.expiresAt,
          equals(DateTime.parse('2025-01-20T16:00:00.000Z')),
        );
        expect(
          invitation.createdAt,
          equals(DateTime.parse('2025-01-10T16:00:00.000Z')),
        );
        expect(invitation.invitedEmail, isNull);
        expect(invitation.invitedDisplayName, isNull);
        expect(invitation.acceptedAt, isNull);
        expect(invitation.acceptedByUserId, isNull);
        expect(invitation.updatedAt, isNull);
      });

      /// Tests JSON deserialization with different permission levels and statuses.
      ///
      /// This test verifies that all valid permission level and status strings are correctly parsed and converted to
      /// the appropriate enum values.
      test('should handle different permission levels and statuses correctly', () {
        final List<String> permissionLevels = ['primary', 'adult', 'child'];
        final List<UserPermissionLevel> expectedPermissions = [
          UserPermissionLevel.primary,
          UserPermissionLevel.adult,
          UserPermissionLevel.child,
        ];

        final List<String> statuses = ['pending', 'accepted', 'expired', 'cancelled'];
        final List<FamilyInvitationStatus> expectedStatuses = [
          FamilyInvitationStatus.pending,
          FamilyInvitationStatus.accepted,
          FamilyInvitationStatus.expired,
          FamilyInvitationStatus.cancelled,
        ];

        for (int i = 0; i < permissionLevels.length; i++) {
          final Map<String, dynamic> json = Map<String, dynamic>.from(validInvitationJson);
          json['targetPermissionLevel'] = permissionLevels[i];

          final FamilyInvitation invitation = FamilyInvitation.fromJson(json);
          expect(invitation.targetPermissionLevel, equals(expectedPermissions[i]));
        }

        for (int i = 0; i < statuses.length; i++) {
          final Map<String, dynamic> json = Map<String, dynamic>.from(validInvitationJson);
          json['status'] = statuses[i];

          final FamilyInvitation invitation = FamilyInvitation.fromJson(json);
          expect(invitation.status, equals(expectedStatuses[i]));
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
            'familyId',
            'invitedByUserId',
            'invitationCode',
            'targetPermissionLevel',
            'status',
            'expiresAt',
            'createdAt',
          ];

          for (final String field in requiredFields) {
            final Map<String, dynamic> incompleteJson = Map<String, dynamic>.from(validInvitationJson)..remove(field);

            expect(
              () => FamilyInvitation.fromJson(incompleteJson),
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
        /// This test ensures that required fields cannot be empty strings, which would be invalid for invitation
        /// identification and processing.
        test('should throw ArgumentError for empty required fields', () {
          final List<String> stringFields = [
            'id',
            'familyId',
            'invitedByUserId',
            'invitationCode',
            'targetPermissionLevel',
            'status',
            'expiresAt',
            'createdAt',
          ];

          for (final String field in stringFields) {
            final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validInvitationJson);
            invalidJson[field] = '';

            expect(
              () => FamilyInvitation.fromJson(invalidJson),
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
          final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validInvitationJson);
          invalidJson['targetPermissionLevel'] = 'invalid_level';

          expect(
            () => FamilyInvitation.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Invalid permission level: invalid_level'),
              ),
            ),
          );
        });

        /// Tests that invalid invitation statuses throw appropriate errors.
        ///
        /// This test verifies that the fromJson constructor properly validates status values and throws descriptive
        /// errors for invalid values.
        test('should throw ArgumentError for invalid status', () {
          final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validInvitationJson);
          invalidJson['status'] = 'invalid_status';

          expect(
            () => FamilyInvitation.fromJson(invalidJson),
            throwsA(
              isA<FormatException>().having(
                (FormatException e) => e.message,
                'message',
                contains('Invalid invitation status: invalid_status'),
              ),
            ),
          );
        });

        /// Tests that malformed timestamp strings throw appropriate errors.
        ///
        /// This test ensures that invalid date/time strings are properly handled and result in descriptive
        /// FormatException errors.
        test('should throw FormatException for invalid timestamp format', () {
          final List<String> timestampFields = ['expiresAt', 'createdAt', 'acceptedAt', 'updatedAt'];

          for (final String field in timestampFields) {
            final Map<String, dynamic> invalidJson = Map<String, dynamic>.from(validInvitationJson);
            invalidJson[field] = 'invalid-timestamp';

            expect(
              () => FamilyInvitation.fromJson(invalidJson),
              throwsA(
                isA<FormatException>().having(
                  (FormatException e) => e.message,
                  'message',
                  contains('Failed to parse FamilyInvitation from JSON'),
                ),
              ),
              reason: 'Should throw FormatException for invalid $field timestamp',
            );
          }
        });

        /// Tests that null values for required fields throw errors.
        ///
        /// This test verifies that explicitly null values for required fields are properly detected and result in
        /// appropriate error messages.
        test('should throw ArgumentError for null required fields', () {
          final List<String> requiredFields = [
            'id',
            'familyId',
            'invitedByUserId',
            'invitationCode',
            'targetPermissionLevel',
            'status',
            'expiresAt',
            'createdAt',
          ];

          for (final String field in requiredFields) {
            final Map<String, dynamic> nullJson = Map<String, dynamic>.from(validInvitationJson);
            nullJson[field] = null;

            expect(
              () => FamilyInvitation.fromJson(nullJson),
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
      /// This test verifies that the toJson method correctly converts a FamilyInvitation instance to a JSON map with
      /// all fields properly formatted and typed.
      test('should convert FamilyInvitation to JSON with all fields', () {
        final Map<String, dynamic> json = validInvitation.toJson();

        expect(json['id'], equals('invitation_123'));
        expect(json['familyId'], equals('family_456'));
        expect(json['invitedByUserId'], equals('user_789'));
        expect(json['invitationCode'], equals('ABC123XYZ'));
        expect(json['targetPermissionLevel'], equals('child'));
        expect(json['status'], equals('pending'));
        expect(json['expiresAt'], equals('2025-01-17T14:30:00.000Z'));
        expect(json['createdAt'], equals('2025-01-10T14:30:00.000Z'));
        expect(json['invitedEmail'], equals('child@example.com'));
        expect(json['invitedDisplayName'], equals('Little Johnny'));
        expect(json['acceptedAt'], isNull);
        expect(json['acceptedByUserId'], isNull);
        expect(json['updatedAt'], equals('2025-01-10T15:00:00.000Z'));
      });

      /// Tests JSON serialization with null optional fields.
      ///
      /// This test ensures that the toJson method properly handles null values for optional fields, including them in
      /// the JSON with null values.
      test('should convert FamilyInvitation to JSON with null optional fields', () {
        final FamilyInvitation invitationWithNulls = FamilyInvitation(
          id: 'invitation_789',
          familyId: 'family_123',
          invitedByUserId: 'user_456',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.adult,
          status: FamilyInvitationStatus.pending,
          expiresAt: DateTime.parse('2025-01-20T12:00:00.000Z'),
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final Map<String, dynamic> json = invitationWithNulls.toJson();

        expect(json['id'], equals('invitation_789'));
        expect(json['familyId'], equals('family_123'));
        expect(json['invitedByUserId'], equals('user_456'));
        expect(json['invitationCode'], equals('TEST123'));
        expect(json['targetPermissionLevel'], equals('adult'));
        expect(json['status'], equals('pending'));
        expect(json['expiresAt'], equals('2025-01-20T12:00:00.000Z'));
        expect(json['createdAt'], equals('2025-01-10T12:00:00.000Z'));
        expect(json['invitedEmail'], isNull);
        expect(json['invitedDisplayName'], isNull);
        expect(json['acceptedAt'], isNull);
        expect(json['acceptedByUserId'], isNull);
        expect(json['updatedAt'], isNull);
      });

      /// Tests that JSON serialization produces expected structure.
      ///
      /// This test verifies that the JSON output contains all expected fields with correct types and can be used for
      /// round-trip serialization.
      test('should produce expected JSON structure', () {
        final Map<String, dynamic> json = validInvitation.toJson();

        // Verify all expected fields are present
        expect(json, containsPair('id', 'invitation_123'));
        expect(json, containsPair('familyId', 'family_456'));
        expect(json, containsPair('invitedByUserId', 'user_789'));
        expect(json, containsPair('invitationCode', 'ABC123XYZ'));
        expect(json, containsPair('targetPermissionLevel', 'child'));
        expect(json, containsPair('status', 'pending'));
        expect(json, containsPair('expiresAt', '2025-01-17T14:30:00.000Z'));
        expect(json, containsPair('createdAt', '2025-01-10T14:30:00.000Z'));
        expect(json, containsPair('invitedEmail', 'child@example.com'));
        expect(json, containsPair('invitedDisplayName', 'Little Johnny'));
        expect(json, contains('acceptedAt'));
        expect(json, contains('acceptedByUserId'));
        expect(json, containsPair('updatedAt', '2025-01-10T15:00:00.000Z'));
      });

      /// Tests round-trip serialization (toJson -> fromJson).
      ///
      /// This test verifies that a FamilyInvitation instance can be serialized to JSON and then deserialized back to an
      /// equivalent FamilyInvitation instance without data loss.
      test('should support round-trip serialization', () {
        final Map<String, dynamic> json = validInvitation.toJson();
        final FamilyInvitation deserializedInvitation = FamilyInvitation.fromJson(json);

        expect(deserializedInvitation, equals(validInvitation));
      });
    });

    group('copyWith', () {
      /// Tests that copyWith creates a new instance with updated fields.
      ///
      /// This test verifies that the copyWith method correctly creates a new FamilyInvitation instance with specified
      /// fields updated while preserving all other field values.
      test('should create new FamilyInvitation with updated fields', () {
        final DateTime newAcceptedAt = DateTime.now();
        final DateTime newUpdatedAt = DateTime.now().add(const Duration(hours: 1));

        final FamilyInvitation updatedInvitation = validInvitation.copyWith(
          status: FamilyInvitationStatus.accepted,
          acceptedAt: newAcceptedAt,
          acceptedByUserId: 'user_123',
          updatedAt: newUpdatedAt,
        );

        expect(updatedInvitation.id, equals(validInvitation.id));
        expect(updatedInvitation.familyId, equals(validInvitation.familyId));
        expect(updatedInvitation.invitedByUserId, equals(validInvitation.invitedByUserId));
        expect(updatedInvitation.invitationCode, equals(validInvitation.invitationCode));
        expect(updatedInvitation.targetPermissionLevel, equals(validInvitation.targetPermissionLevel));
        expect(updatedInvitation.status, equals(FamilyInvitationStatus.accepted));
        expect(updatedInvitation.expiresAt, equals(validInvitation.expiresAt));
        expect(updatedInvitation.createdAt, equals(validInvitation.createdAt));
        expect(updatedInvitation.invitedEmail, equals(validInvitation.invitedEmail));
        expect(updatedInvitation.invitedDisplayName, equals(validInvitation.invitedDisplayName));
        expect(updatedInvitation.acceptedAt, equals(newAcceptedAt));
        expect(updatedInvitation.acceptedByUserId, equals('user_123'));
        expect(updatedInvitation.updatedAt, equals(newUpdatedAt));
      });

      /// Tests that copyWith preserves original values when no updates provided.
      ///
      /// This test ensures that calling copyWith without parameters creates an identical copy of the original
      /// FamilyInvitation instance.
      test('should preserve original values when no updates provided', () {
        final FamilyInvitation copiedInvitation = validInvitation.copyWith();

        expect(copiedInvitation, equals(validInvitation));
        expect(identical(copiedInvitation, validInvitation), isFalse);
      });

      /// Tests that copyWith can update individual fields independently.
      ///
      /// This test verifies that each field can be updated independently without affecting other fields, ensuring
      /// proper isolation of changes.
      test('should update individual fields independently', () {
        final FamilyInvitation updatedStatus = validInvitation.copyWith(
          status: FamilyInvitationStatus.cancelled,
        );
        final FamilyInvitation updatedAcceptedBy = validInvitation.copyWith(
          acceptedByUserId: 'user_999',
        );
        final DateTime newAcceptedAt = DateTime.now();
        final FamilyInvitation updatedAcceptedAt = validInvitation.copyWith(
          acceptedAt: newAcceptedAt,
        );

        expect(updatedStatus.status, equals(FamilyInvitationStatus.cancelled));
        expect(updatedStatus.acceptedByUserId, equals(validInvitation.acceptedByUserId));

        expect(updatedAcceptedBy.acceptedByUserId, equals('user_999'));
        expect(updatedAcceptedBy.status, equals(validInvitation.status));

        expect(updatedAcceptedAt.acceptedAt, equals(newAcceptedAt));
        expect(updatedAcceptedAt.status, equals(validInvitation.status));
      });

      /// Tests that copyWith preserves null values when not explicitly set.
      ///
      /// This test verifies that the copyWith method correctly handles cases where optional fields are already null and
      /// should remain null.
      test('should preserve null values for optional fields', () {
        final FamilyInvitation invitationWithNulls = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.child,
          status: FamilyInvitationStatus.pending,
          expiresAt: DateTime.now().add(const Duration(days: 7)),
          createdAt: DateTime.now(),
        );

        final FamilyInvitation copiedInvitation = invitationWithNulls.copyWith(
          status: FamilyInvitationStatus.cancelled,
        );

        expect(copiedInvitation.invitedEmail, isNull);
        expect(copiedInvitation.invitedDisplayName, isNull);
        expect(copiedInvitation.acceptedAt, isNull);
        expect(copiedInvitation.acceptedByUserId, isNull);
        expect(copiedInvitation.updatedAt, isNull);
        expect(copiedInvitation.status, equals(FamilyInvitationStatus.cancelled));
      });
    });

    group('equality and hashCode', () {
      /// Tests that identical FamilyInvitation instances are considered equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyInvitation instances with identical
      /// field values as equal.
      test('should consider FamilyInvitations with identical values as equal', () {
        final DateTime createdAt = DateTime.parse('2025-01-10T12:00:00.000Z');
        final DateTime expiresAt = DateTime.parse('2025-01-17T12:00:00.000Z');
        final DateTime updatedAt = DateTime.parse('2025-01-10T13:00:00.000Z');

        final FamilyInvitation invitation1 = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.adult,
          status: FamilyInvitationStatus.pending,
          expiresAt: expiresAt,
          createdAt: createdAt,
          invitedEmail: 'test@example.com',
          invitedDisplayName: 'Test User',
          updatedAt: updatedAt,
        );

        final FamilyInvitation invitation2 = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.adult,
          status: FamilyInvitationStatus.pending,
          expiresAt: expiresAt,
          createdAt: createdAt,
          invitedEmail: 'test@example.com',
          invitedDisplayName: 'Test User',
          updatedAt: updatedAt,
        );

        expect(invitation1, equals(invitation2));
        expect(invitation1.hashCode, equals(invitation2.hashCode));
      });

      /// Tests that FamilyInvitation instances with different values are not equal.
      ///
      /// This test verifies that the equality operator correctly identifies FamilyInvitation instances with different
      /// field values as not equal.
      test('should consider FamilyInvitations with different values as not equal', () {
        final FamilyInvitation invitation1 = validInvitation;
        final FamilyInvitation invitation2 = validInvitation.copyWith(
          status: FamilyInvitationStatus.accepted,
        );

        expect(invitation1, isNot(equals(invitation2)));
        expect(invitation1.hashCode, isNot(equals(invitation2.hashCode)));
      });

      /// Tests that a FamilyInvitation instance is equal to itself.
      ///
      /// This test verifies the reflexive property of equality, ensuring that any FamilyInvitation instance is equal to
      /// itself.
      test('should be equal to itself', () {
        expect(validInvitation, equals(validInvitation));
        expect(validInvitation.hashCode, equals(validInvitation.hashCode));
      });

      /// Tests that FamilyInvitation instances with null optional fields handle equality correctly.
      ///
      /// This test ensures that equality comparison works correctly when optional fields are null in one or both
      /// instances.
      test('should handle null optional fields in equality comparison', () {
        final FamilyInvitation invitationWithNulls = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.adult,
          status: FamilyInvitationStatus.pending,
          expiresAt: DateTime.parse('2025-01-17T12:00:00.000Z'),
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final FamilyInvitation anotherInvitationWithNulls = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.adult,
          status: FamilyInvitationStatus.pending,
          expiresAt: DateTime.parse('2025-01-17T12:00:00.000Z'),
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        expect(invitationWithNulls, equals(anotherInvitationWithNulls));
        expect(invitationWithNulls.hashCode, equals(anotherInvitationWithNulls.hashCode));
      });
    });

    group('toString', () {
      /// Tests that toString produces a readable string representation.
      ///
      /// This test verifies that the toString method produces a properly formatted string containing all field values
      /// for debugging purposes.
      test('should produce readable string representation', () {
        final String stringRepresentation = validInvitation.toString();

        expect(stringRepresentation, contains('FamilyInvitation('));
        expect(stringRepresentation, contains('id: invitation_123'));
        expect(stringRepresentation, contains('familyId: family_456'));
        expect(stringRepresentation, contains('invitedByUserId: user_789'));
        expect(stringRepresentation, contains('invitationCode: ABC123XYZ'));
        expect(stringRepresentation, contains('targetPermissionLevel: child'));
        expect(stringRepresentation, contains('status: pending'));
        expect(stringRepresentation, contains('expiresAt: 2025-01-17 14:30:00.000Z'));
        expect(stringRepresentation, contains('createdAt: 2025-01-10 14:30:00.000Z'));
        expect(stringRepresentation, contains('invitedEmail: child@example.com'));
        expect(stringRepresentation, contains('invitedDisplayName: Little Johnny'));
        expect(stringRepresentation, contains('acceptedAt: null'));
        expect(stringRepresentation, contains('acceptedByUserId: null'));
        expect(stringRepresentation, contains('updatedAt: 2025-01-10 15:00:00.000Z'));
      });

      /// Tests that toString handles null optional fields correctly.
      ///
      /// This test ensures that the toString method properly displays null values for optional fields without causing
      /// errors.
      test('should handle null optional fields in string representation', () {
        final FamilyInvitation invitationWithNulls = FamilyInvitation(
          id: 'test_id',
          familyId: 'test_family',
          invitedByUserId: 'test_user',
          invitationCode: 'TEST123',
          targetPermissionLevel: UserPermissionLevel.child,
          status: FamilyInvitationStatus.pending,
          expiresAt: DateTime.parse('2025-01-17T12:00:00.000Z'),
          createdAt: DateTime.parse('2025-01-10T12:00:00.000Z'),
        );

        final String stringRepresentation = invitationWithNulls.toString();

        expect(stringRepresentation, contains('invitedEmail: null'));
        expect(stringRepresentation, contains('invitedDisplayName: null'));
        expect(stringRepresentation, contains('acceptedAt: null'));
        expect(stringRepresentation, contains('acceptedByUserId: null'));
        expect(stringRepresentation, contains('updatedAt: null'));
      });
    });
  });
}
