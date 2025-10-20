/// Family invitation model for managing family member invitations in the Staccato system.
///
/// This model handles the invitation process for adding new members to family groups, including invitation codes,
/// expiration dates, and permission levels for invited users.
library;

import 'package:meta/meta.dart';
import 'package:staccato_api_server/models/user.dart';

// Parts
part 'family_invitation_status.dart';

/// Represents an invitation for a user to join a family group.
///
/// Family invitations are created by primary administrators or adult users (depending on family settings) to invite new
/// members to join their family group. Each invitation contains a unique code, expiration date, and pre-configured
/// permission level for the invited user.
///
/// The [FamilyInvitation] model is immutable and tracks the complete lifecycle of an invitation from creation through
/// acceptance or expiration.
@immutable
class FamilyInvitation {
  /// Creates a new [FamilyInvitation] instance with the specified properties.
  ///
  /// All parameters except [acceptedAt], [acceptedByUserId], and [updatedAt] are required. The acceptance fields are
  /// set when the invitation is accepted, and [updatedAt] is automatically set when the invitation is modified.
  const FamilyInvitation({
    required this.id,
    required this.familyId,
    required this.invitedByUserId,
    required this.invitationCode,
    required this.targetPermissionLevel,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.invitedEmail,
    this.invitedDisplayName,
    this.acceptedAt,
    this.acceptedByUserId,
    this.updatedAt,
  });

  /// Unique identifier for this invitation.
  ///
  /// This ID is generated when the invitation is created and remains constant throughout the invitation's lifetime.
  /// It's used for database references, API endpoints, and tracking invitation status.
  final String id;

  /// ID of the family group this invitation is for.
  ///
  /// This establishes the relationship between the invitation and the target family group. When accepted, the invited
  /// user will become a member of this family.
  final String familyId;

  /// ID of the user who created this invitation.
  ///
  /// This tracks which family member sent the invitation for auditing and permission validation purposes. Only users
  /// with appropriate permissions can create invitations.
  final String invitedByUserId;

  /// Unique invitation code used for accepting the invitation.
  ///
  /// This code is shared with the invited person and allows them to join the family group. The code should be
  /// cryptographically secure and difficult to guess to prevent unauthorized access.
  final String invitationCode;

  /// Permission level that will be assigned to the user when they accept this invitation.
  ///
  /// This pre-configures the access rights the invited user will have within the family group. The permission level
  /// cannot be higher than what the inviting user is authorized to grant.
  final UserPermissionLevel targetPermissionLevel;

  /// Current status of this invitation.
  ///
  /// Tracks whether the invitation is pending, accepted, expired, or cancelled. See [FamilyInvitationStatus] for
  /// details about each status and their meanings.
  final FamilyInvitationStatus status;

  /// Timestamp when this invitation expires and can no longer be accepted.
  ///
  /// Invitations have a limited lifetime to prevent security issues with long-lived invitation codes. Expired
  /// invitations are automatically marked as expired and cannot be used.
  final DateTime expiresAt;

  /// Timestamp when this invitation was created.
  ///
  /// This field is set once during invitation creation and never changes. It's used for auditing, analytics, and
  /// calculating invitation age.
  final DateTime createdAt;

  /// Email address of the invited person (optional).
  ///
  /// When provided, this email can be used to send invitation notifications and to validate that the correct person is
  /// accepting the invitation. This field is optional for privacy reasons.
  final String? invitedEmail;

  /// Display name for the invited person (optional).
  ///
  /// This can be used to personalize invitation messages and to help family members identify who was invited. This
  /// field is optional and can be provided by the inviting user.
  final String? invitedDisplayName;

  /// Timestamp when this invitation was accepted (if applicable).
  ///
  /// This field is set when the invitation status changes to accepted. It's used for auditing and determining when
  /// users joined the family group.
  final DateTime? acceptedAt;

  /// ID of the user who accepted this invitation (if applicable).
  ///
  /// This field is set when the invitation is accepted and creates the link between the invitation and the resulting
  /// user account. It's used for tracking and preventing duplicate acceptances.
  final String? acceptedByUserId;

  /// Timestamp when this invitation was last updated.
  ///
  /// This field is automatically updated whenever any invitation property is modified. It's used for synchronization,
  /// caching, and conflict resolution.
  final DateTime? updatedAt;

  /// Whether this invitation is still valid and can be accepted.
  ///
  /// Returns `true` if the invitation is in pending status and has not expired. Returns `false` for accepted, expired,
  /// or cancelled invitations.
  bool get isValid => status == FamilyInvitationStatus.pending && DateTime.now().isBefore(expiresAt);

  /// Whether this invitation has expired based on the current time.
  ///
  /// Returns `true` if the current time is past the expiration date. Expired invitations should be automatically marked
  /// as expired by background processes.
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Whether this invitation has been accepted by a user.
  ///
  /// Returns `true` if the invitation status is accepted and there is an accepted user ID. This indicates that the
  /// invitation was successfully used to add a new family member.
  bool get isAccepted => status == FamilyInvitationStatus.accepted && acceptedByUserId != null;

  /// Creates a FamilyInvitation instance from a JSON map.
  ///
  /// This factory constructor is used for deserializing invitation data from API responses, database queries, and other
  /// JSON sources.
  ///
  /// Parameters:
  /// * [json] - Map containing invitation data with string keys
  ///
  /// Returns a new [FamilyInvitation] instance with data from the JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed or missing required fields.
  ///
  /// Throws [ArgumentError] if field values are invalid (e.g., invalid permission level, malformed timestamps).
  factory FamilyInvitation.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and extract required fields
      final String? id = json['id'] as String?;
      if (id == null || id.isEmpty) {
        throw ArgumentError('Missing or empty required field: id');
      }

      final String? familyId = json['familyId'] as String?;
      if (familyId == null || familyId.isEmpty) {
        throw ArgumentError('Missing or empty required field: familyId');
      }

      final String? invitedByUserId = json['invitedByUserId'] as String?;
      if (invitedByUserId == null || invitedByUserId.isEmpty) {
        throw ArgumentError('Missing or empty required field: invitedByUserId');
      }

      final String? invitationCode = json['invitationCode'] as String?;
      if (invitationCode == null || invitationCode.isEmpty) {
        throw ArgumentError('Missing or empty required field: invitationCode');
      }

      final String? targetPermissionLevelString = json['targetPermissionLevel'] as String?;
      if (targetPermissionLevelString == null || targetPermissionLevelString.isEmpty) {
        throw ArgumentError('Missing or empty required field: targetPermissionLevel');
      }

      final String? statusString = json['status'] as String?;
      if (statusString == null || statusString.isEmpty) {
        throw ArgumentError('Missing or empty required field: status');
      }

      final String? expiresAtString = json['expiresAt'] as String?;
      if (expiresAtString == null || expiresAtString.isEmpty) {
        throw ArgumentError('Missing or empty required field: expiresAt');
      }

      final String? createdAtString = json['createdAt'] as String?;
      if (createdAtString == null || createdAtString.isEmpty) {
        throw ArgumentError('Missing or empty required field: createdAt');
      }

      // Parse enum values
      final UserPermissionLevel targetPermissionLevel = UserPermissionLevel.fromString(targetPermissionLevelString);
      final FamilyInvitationStatus status = FamilyInvitationStatus.fromString(statusString);

      // Parse timestamps
      final DateTime expiresAt = DateTime.parse(expiresAtString);
      final DateTime createdAt = DateTime.parse(createdAtString);

      final String? acceptedAtString = json['acceptedAt'] as String?;
      final DateTime? acceptedAt =
          acceptedAtString != null && acceptedAtString.isNotEmpty ? DateTime.parse(acceptedAtString) : null;

      final String? updatedAtString = json['updatedAt'] as String?;
      final DateTime? updatedAt =
          updatedAtString != null && updatedAtString.isNotEmpty ? DateTime.parse(updatedAtString) : null;

      // Extract optional fields
      final String? invitedEmail = json['invitedEmail'] as String?;
      final String? invitedDisplayName = json['invitedDisplayName'] as String?;
      final String? acceptedByUserId = json['acceptedByUserId'] as String?;

      return FamilyInvitation(
        id: id,
        familyId: familyId,
        invitedByUserId: invitedByUserId,
        invitationCode: invitationCode,
        targetPermissionLevel: targetPermissionLevel,
        status: status,
        expiresAt: expiresAt,
        createdAt: createdAt,
        invitedEmail: invitedEmail,
        invitedDisplayName: invitedDisplayName,
        acceptedAt: acceptedAt,
        acceptedByUserId: acceptedByUserId,
        updatedAt: updatedAt,
      );
    } catch (e) {
      throw FormatException('Failed to parse FamilyInvitation from JSON: $e');
    }
  }

  /// Converts this FamilyInvitation instance to a JSON map.
  ///
  /// This method is used for serializing invitation data for API requests, database storage, and other JSON-based
  /// operations.
  ///
  /// Returns a [Map<String, dynamic>] containing all invitation properties with appropriate JSON-compatible types.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'familyId': familyId,
      'invitedByUserId': invitedByUserId,
      'invitationCode': invitationCode,
      'targetPermissionLevel': targetPermissionLevel.value,
      'status': status.value,
      'expiresAt': expiresAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'invitedEmail': invitedEmail,
      'invitedDisplayName': invitedDisplayName,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'acceptedByUserId': acceptedByUserId,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this FamilyInvitation with the specified fields updated.
  ///
  /// This method returns a new FamilyInvitation instance with the same values as the current instance, except for the
  /// fields explicitly provided as parameters. This is useful for updating invitation properties while maintaining
  /// immutability.
  ///
  /// Parameters:
  /// * [status] - New invitation status (optional)
  /// * [acceptedAt] - New acceptance timestamp (optional)
  /// * [acceptedByUserId] - New accepted user ID (optional)
  /// * [updatedAt] - New update timestamp (optional)
  ///
  /// Returns a new [FamilyInvitation] instance with updated values.
  ///
  /// Note: Core invitation details like [id], [familyId], [invitationCode], and [createdAt] cannot be changed.
  FamilyInvitation copyWith({
    FamilyInvitationStatus? status,
    DateTime? acceptedAt,
    String? acceptedByUserId,
    DateTime? updatedAt,
  }) {
    return FamilyInvitation(
      id: id,
      familyId: familyId,
      invitedByUserId: invitedByUserId,
      invitationCode: invitationCode,
      targetPermissionLevel: targetPermissionLevel,
      status: status ?? this.status,
      expiresAt: expiresAt,
      createdAt: createdAt,
      invitedEmail: invitedEmail,
      invitedDisplayName: invitedDisplayName,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      acceptedByUserId: acceptedByUserId ?? this.acceptedByUserId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FamilyInvitation &&
        other.id == id &&
        other.familyId == familyId &&
        other.invitedByUserId == invitedByUserId &&
        other.invitationCode == invitationCode &&
        other.targetPermissionLevel == targetPermissionLevel &&
        other.status == status &&
        other.expiresAt == expiresAt &&
        other.createdAt == createdAt &&
        other.invitedEmail == invitedEmail &&
        other.invitedDisplayName == invitedDisplayName &&
        other.acceptedAt == acceptedAt &&
        other.acceptedByUserId == acceptedByUserId &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      familyId,
      invitedByUserId,
      invitationCode,
      targetPermissionLevel,
      status,
      expiresAt,
      createdAt,
      invitedEmail,
      invitedDisplayName,
      acceptedAt,
      acceptedByUserId,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'FamilyInvitation('
        'id: $id, '
        'familyId: $familyId, '
        'invitedByUserId: $invitedByUserId, '
        'invitationCode: $invitationCode, '
        'targetPermissionLevel: $targetPermissionLevel, '
        'status: $status, '
        'expiresAt: $expiresAt, '
        'createdAt: $createdAt, '
        'invitedEmail: $invitedEmail, '
        'invitedDisplayName: $invitedDisplayName, '
        'acceptedAt: $acceptedAt, '
        'acceptedByUserId: $acceptedByUserId, '
        'updatedAt: $updatedAt'
        ')';
  }
}
