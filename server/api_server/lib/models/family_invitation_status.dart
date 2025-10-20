part of 'family_invitation.dart';

/// Enumeration of family invitation statuses.
///
/// Each status represents a different stage in the invitation lifecycle:
///
/// - **Pending**: The invitation has been created and is waiting for acceptance
/// - **Accepted**: The invitation has been successfully accepted and the user has joined the family
/// - **Expired**: The invitation has passed its expiration date and can no longer be used
/// - **Cancelled**: The invitation has been manually cancelled by a family administrator
enum FamilyInvitationStatus {
  /// The invitation is active and waiting for acceptance.
  ///
  /// This is the initial status when an invitation is created. The invitation can be accepted using the invitation code
  /// until it expires or is cancelled.
  pending('pending'),

  /// The invitation has been successfully accepted.
  ///
  /// This status indicates that someone has used the invitation code to join the family group. The invitation cannot be
  /// used again and the acceptedAt and acceptedByUserId fields should be populated.
  accepted('accepted'),

  /// The invitation has expired and can no longer be used.
  ///
  /// This status is automatically set when the invitation passes its expiration date. Expired invitations cannot be
  /// accepted and should be cleaned up by background processes.
  expired('expired'),

  /// The invitation has been manually cancelled.
  ///
  /// This status is set when a family administrator cancels the invitation before it expires or is accepted. Cancelled
  /// invitations cannot be used and provide a way to revoke access before acceptance.
  cancelled('cancelled');

  /// Creates an invitation status with the specified string value.
  ///
  /// The [value] parameter represents the string representation used for JSON serialization and database storage.
  const FamilyInvitationStatus(this.value);

  /// String representation of the invitation status.
  ///
  /// This value is used for JSON serialization, database storage, and API communication. It matches the enum name in
  /// lowercase.
  final String value;

  /// Creates a [FamilyInvitationStatus] from its string representation.
  ///
  /// This factory constructor is used for JSON deserialization and converting string values back to enum instances.
  ///
  /// Parameters:
  /// * [value] - The string representation of the invitation status
  ///
  /// Returns the corresponding [FamilyInvitationStatus] enum value.
  ///
  /// Throws [ArgumentError] if the provided value doesn't match any valid invitation status.
  factory FamilyInvitationStatus.fromString(String value) {
    return FamilyInvitationStatus.values.firstWhere(
      (FamilyInvitationStatus status) => status.value == value.toLowerCase(),
      orElse: () => throw ArgumentError(
        'Invalid invitation status: $value. '
        'Valid values are: ${FamilyInvitationStatus.values.map((FamilyInvitationStatus e) => e.value).join(', ')}',
      ),
    );
  }

  /// Whether this status indicates the invitation is still usable.
  ///
  /// Returns `true` only for [pending] status. All other statuses indicate the invitation cannot be used.
  bool get isActive => this == FamilyInvitationStatus.pending;

  /// Whether this status indicates the invitation has been completed successfully.
  ///
  /// Returns `true` only for [accepted] status, indicating the invitation achieved its purpose.
  bool get isCompleted => this == FamilyInvitationStatus.accepted;

  /// Whether this status indicates the invitation is no longer valid.
  ///
  /// Returns `true` for [expired] and [cancelled] statuses, indicating the invitation cannot be used and should be
  /// cleaned up.
  bool get isInvalid => this == FamilyInvitationStatus.expired || this == FamilyInvitationStatus.cancelled;

  @override
  String toString() => value;
}
