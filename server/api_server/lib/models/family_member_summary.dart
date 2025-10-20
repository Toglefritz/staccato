import 'package:meta/meta.dart';
import 'package:staccato_api_server/models/user.dart';

/// Lightweight representation of a family member for use in family contexts.
///
/// This model contains only the essential user information needed for most family-related operations, reducing payload
/// size and improving performance when dealing with lists of family members.
///
/// The [FamilyMemberSummary] is typically used in:
/// - Family member lists and overviews
/// - Task assignment dropdowns
/// - Calendar event attendee lists
/// - Quick member identification in UI components
@immutable
class FamilyMemberSummary {
  /// Creates a new [FamilyMemberSummary] instance with the specified properties.
  ///
  /// All parameters are required as they represent the minimal information needed to identify and display a family
  /// member in most contexts.
  const FamilyMemberSummary({
    required this.id,
    required this.displayName,
    required this.permissionLevel,
    this.profileImageUrl,
  });

  /// Unique identifier for this family member.
  ///
  /// This ID corresponds to the user's ID in the full User model and is used for references, API calls, and database
  /// operations.
  final String id;

  /// Display name of the family member.
  ///
  /// This is the human-readable name shown in UI components, task assignments, and other user-facing contexts.
  final String displayName;

  /// Permission level of the family member.
  ///
  /// This determines the member's access rights and capabilities within the family group. It's included in the summary
  /// to enable permission-based UI decisions without requiring full user data.
  final UserPermissionLevel permissionLevel;

  /// URL to the member's profile image (optional).
  ///
  /// This optional field contains a URL pointing to the member's profile picture. If null, UI components should display
  /// a default avatar.
  final String? profileImageUrl;

  /// Whether this family member has administrative privileges.
  ///
  /// Returns `true` if the member's permission level allows administrative actions. This is a convenience getter that
  /// delegates to the permission level's isAdmin property.
  bool get isAdmin => permissionLevel.isAdmin;

  /// Whether this family member has adult-level access.
  ///
  /// Returns `true` if the member's permission level grants access to adult features. This is a convenience getter that
  /// delegates to the permission level's isAdult property.
  bool get isAdult => permissionLevel.isAdult;

  /// Whether this family member can manage other users.
  ///
  /// Returns `true` if the member's permission level allows user management operations. This is a convenience getter
  /// that delegates to the permission level's canManageUsers property.
  bool get canManageUsers => permissionLevel.canManageUsers;

  /// Creates a FamilyMemberSummary from a full User instance.
  ///
  /// This factory constructor extracts the essential information from a complete User model to create a lightweight
  /// summary. This is useful when you have full user data but need to create summary objects for performance reasons.
  ///
  /// Parameters:
  /// * [user] - The complete User instance to summarize
  ///
  /// Returns a new [FamilyMemberSummary] with data extracted from the user.
  factory FamilyMemberSummary.fromUser(User user) {
    return FamilyMemberSummary(
      id: user.id,
      displayName: user.displayName,
      permissionLevel: user.permissionLevel,
      profileImageUrl: user.profileImageUrl,
    );
  }

  /// Creates a FamilyMemberSummary instance from a JSON map.
  ///
  /// This factory constructor is used for deserializing member summary data from API responses, database queries, and
  /// other JSON sources.
  ///
  /// Parameters:
  /// * [json] - Map containing member summary data with string keys
  ///
  /// Returns a new [FamilyMemberSummary] instance with data from the JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed or missing required fields.
  ///
  /// Throws [ArgumentError] if field values are invalid (e.g., invalid permission level).
  factory FamilyMemberSummary.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and extract required fields
      final String? id = json['id'] as String?;
      if (id == null || id.isEmpty) {
        throw ArgumentError('Missing or empty required field: id');
      }

      final String? displayName = json['displayName'] as String?;
      if (displayName == null || displayName.isEmpty) {
        throw ArgumentError('Missing or empty required field: displayName');
      }

      final String? permissionLevelString = json['permissionLevel'] as String?;
      if (permissionLevelString == null || permissionLevelString.isEmpty) {
        throw ArgumentError('Missing or empty required field: permissionLevel');
      }

      // Parse permission level
      final UserPermissionLevel permissionLevel = UserPermissionLevel.fromString(permissionLevelString);

      // Extract optional fields
      final String? profileImageUrl = json['profileImageUrl'] as String?;

      return FamilyMemberSummary(
        id: id,
        displayName: displayName,
        permissionLevel: permissionLevel,
        profileImageUrl: profileImageUrl,
      );
    } catch (e) {
      throw FormatException('Failed to parse FamilyMemberSummary from JSON: $e');
    }
  }

  /// Converts this FamilyMemberSummary instance to a JSON map.
  ///
  /// This method is used for serializing member summary data for API requests, database storage, and other JSON-based
  /// operations.
  ///
  /// Returns a [Map<String, dynamic>] containing all summary properties with appropriate JSON-compatible types.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'displayName': displayName,
      'permissionLevel': permissionLevel.value,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Creates a copy of this FamilyMemberSummary with the specified fields updated.
  ///
  /// This method returns a new FamilyMemberSummary instance with the same values as the current instance, except for
  /// the fields explicitly provided as parameters. This is useful for updating summary properties while maintaining
  /// immutability.
  ///
  /// Parameters:
  /// * [displayName] - New display name (optional)
  /// * [permissionLevel] - New permission level (optional)
  /// * [profileImageUrl] - New profile image URL (optional)
  ///
  /// Returns a new [FamilyMemberSummary] instance with updated values.
  ///
  /// Note: The [id] field cannot be changed as it is an immutable identifier.
  FamilyMemberSummary copyWith({
    String? displayName,
    UserPermissionLevel? permissionLevel,
    String? profileImageUrl,
  }) {
    return FamilyMemberSummary(
      id: id,
      displayName: displayName ?? this.displayName,
      permissionLevel: permissionLevel ?? this.permissionLevel,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FamilyMemberSummary &&
        other.id == id &&
        other.displayName == displayName &&
        other.permissionLevel == permissionLevel &&
        other.profileImageUrl == profileImageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      displayName,
      permissionLevel,
      profileImageUrl,
    );
  }

  @override
  String toString() {
    return 'FamilyMemberSummary('
        'id: $id, '
        'displayName: $displayName, '
        'permissionLevel: $permissionLevel, '
        'profileImageUrl: $profileImageUrl'
        ')';
  }
}
