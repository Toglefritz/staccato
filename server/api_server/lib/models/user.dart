/// User model representing a family member in the Staccato system.
///
/// This model contains all user information including profile data, family relationships, and permission levels. It
/// handles JSON serialization for API communication and database storage.
library;

import 'package:meta/meta.dart';

// Parts
part 'user_permission_level.dart';

/// Represents a user (family member) in the Staccato system.
///
/// Each user belongs to exactly one family group and has a specific permission level that determines their access
/// rights and capabilities within the system.
///
/// The [User] model is immutable and contains all necessary information for authentication, authorization, and profile
/// management.
@immutable
class User {
  /// Creates a new [User] instance with the specified properties.
  ///
  /// All parameters except [updatedAt] and [profileImageUrl] are required. The [updatedAt] field is automatically set
  /// when the user is modified, and [profileImageUrl] is optional for users without profile pictures.
  const User({
    required this.id,
    required this.displayName,
    required this.familyId,
    required this.permissionLevel,
    required this.createdAt,
    this.updatedAt,
    this.profileImageUrl,
  });

  /// Unique identifier for this user.
  ///
  /// This ID is generated when the user is created and remains constant throughout the user's lifetime. It's used for
  /// database references, API endpoints, and internal system operations.
  final String id;

  /// User's display name shown throughout the application.
  ///
  /// This is the human-readable name displayed in the UI, task assignments, calendar events, and other user-facing
  /// contexts. It can be changed by the user or family administrators.
  final String displayName;

  /// ID of the family group this user belongs to.
  ///
  /// Every user must belong to exactly one family group. This field establishes the relationship between users and
  /// families, enabling data isolation and permission management at the family level.
  final String familyId;

  /// Permission level determining the user's access rights.
  ///
  /// This field controls what features and data the user can access within their family group. See
  /// [UserPermissionLevel] for details about each permission level's capabilities.
  final UserPermissionLevel permissionLevel;

  /// Timestamp when this user account was created.
  ///
  /// This field is set once during user creation and never changes. It's used for auditing, analytics, and determining
  /// user tenure within the family group.
  final DateTime createdAt;

  /// Timestamp when this user was last updated.
  ///
  /// This field is automatically updated whenever any user property is modified. It's used for synchronization,
  /// caching, and conflict resolution in distributed systems.
  final DateTime? updatedAt;

  /// URL to the user's profile image.
  ///
  /// This optional field contains a URL pointing to the user's profile picture stored in Firebase Storage or another
  /// CDN. If null, the UI should display a default avatar.
  final String? profileImageUrl;

  /// Whether this user has administrative privileges.
  ///
  /// Returns `true` if the user's permission level allows administrative actions such as managing other users or family
  /// settings.
  bool get isAdmin => permissionLevel.isAdmin;

  /// Whether this user has adult-level access.
  ///
  /// Returns `true` if the user's permission level grants access to adult features and content. Returns `false` for
  /// child users.
  bool get isAdult => permissionLevel.isAdult;

  /// Whether this user can manage other family members.
  ///
  /// Returns `true` if the user's permission level allows adding, removing, or modifying other users in the family
  /// group.
  bool get canManageUsers => permissionLevel.canManageUsers;

  /// Creates a User instance from a JSON map.
  ///
  /// This factory constructor is used for deserializing user data from API responses, database queries, and other JSON
  /// sources.
  ///
  /// Parameters:
  /// * [json] - Map containing user data with string keys
  ///
  /// Returns a new [User] instance with data from the JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed or missing required fields.
  ///
  /// Throws [ArgumentError] if field values are invalid (e.g., invalid permission level, malformed timestamps).
  ///
  /// Example:
  /// ```dart
  /// final Map<String, dynamic> json = {
  /// 'id': 'user_123',
  /// 'email': 'john@example.com',
  /// 'displayName': 'John Doe',
  /// 'familyId': 'family_456',
  /// 'permissionLevel': 'primary',
  /// 'createdAt': '2025-01-10T14:30:00.000Z',
  /// };
  ///
  /// final User user = User.fromJson(json);
  /// ```
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and extract required fields
      final String? id = json['id'] as String?;
      if (id == null || id.isEmpty) {
        throw ArgumentError('Missing or empty required field: id');
      }

      final String? email = json['email'] as String?;
      if (email == null || email.isEmpty) {
        throw ArgumentError('Missing or empty required field: email');
      }

      final String? displayName = json['displayName'] as String?;
      if (displayName == null || displayName.isEmpty) {
        throw ArgumentError('Missing or empty required field: displayName');
      }

      final String? familyId = json['familyId'] as String?;
      if (familyId == null || familyId.isEmpty) {
        throw ArgumentError('Missing or empty required field: familyId');
      }

      final String? permissionLevelString = json['permissionLevel'] as String?;
      if (permissionLevelString == null || permissionLevelString.isEmpty) {
        throw ArgumentError('Missing or empty required field: permissionLevel');
      }

      final String? createdAtString = json['createdAt'] as String?;
      if (createdAtString == null || createdAtString.isEmpty) {
        throw ArgumentError('Missing or empty required field: createdAt');
      }

      // Parse permission level
      final UserPermissionLevel permissionLevel =
          UserPermissionLevel.fromString(permissionLevelString);

      // Parse timestamps
      final DateTime createdAt = DateTime.parse(createdAtString);

      final String? updatedAtString = json['updatedAt'] as String?;
      final DateTime? updatedAt =
          updatedAtString != null && updatedAtString.isNotEmpty
              ? DateTime.parse(updatedAtString)
              : null;

      // Extract optional fields
      final String? profileImageUrl = json['profileImageUrl'] as String?;

      return User(
        id: id,
        displayName: displayName,
        familyId: familyId,
        permissionLevel: permissionLevel,
        createdAt: createdAt,
        updatedAt: updatedAt,
        profileImageUrl: profileImageUrl,
      );
    } catch (e) {
      throw FormatException('Failed to parse User from JSON: $e');
    }
  }

  /// Converts this User instance to a JSON map.
  ///
  /// This method is used for serializing user data for API requests, database storage, and other JSON-based operations.
  ///
  /// Returns a [Map<String, dynamic>] containing all user properties with appropriate JSON-compatible types.
  ///
  /// Example:
  /// ```dart
  /// final User user = User(
  /// id: 'user_123',
  /// email: 'john@example.com',
  /// displayName: 'John Doe',
  /// familyId: 'family_456',
  /// permissionLevel: UserPermissionLevel.primary,
  /// createdAt: DateTime.now(),
  /// );
  ///
  /// final Map<String, dynamic> json = user.toJson();
  /// // Result: {
  /// //   'id': 'user_123',
  /// //   'email': 'john@example.com',
  /// //   'displayName': 'John Doe',
  /// //   'familyId': 'family_456',
  /// //   'permissionLevel': 'primary',
  /// //   'createdAt': '2025-01-10T14:30:00.000Z',
  /// //   'updatedAt': null,
  /// //   'profileImageUrl': null
  /// // }
  /// ```
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'displayName': displayName,
      'familyId': familyId,
      'permissionLevel': permissionLevel.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Creates a copy of this User with the specified fields updated.
  ///
  /// This method returns a new User instance with the same values as the current instance, except for the fields
  /// explicitly provided as parameters. This is useful for updating user properties while maintaining immutability.
  ///
  /// Parameters:
  /// * [email] - New email address (optional)
  /// * [displayName] - New display name (optional)
  /// * [familyId] - New family ID (optional)
  /// * [permissionLevel] - New permission level (optional)
  /// * [updatedAt] - New update timestamp (optional)
  /// * [profileImageUrl] - New profile image URL (optional)
  ///
  /// Returns a new [User] instance with updated values.
  ///
  /// Note: The [id] and [createdAt] fields cannot be changed as they are immutable identifiers.
  ///
  /// Example:
  /// ```dart
  /// final User originalUser = User(...);
  /// final User updatedUser = originalUser.copyWith(
  /// displayName: 'New Name',
  /// updatedAt: DateTime.now(),
  /// );
  /// ```
  User copyWith({
    String? email,
    String? displayName,
    String? familyId,
    UserPermissionLevel? permissionLevel,
    DateTime? updatedAt,
    String? profileImageUrl,
  }) {
    return User(
      id: id,
      displayName: displayName ?? this.displayName,
      familyId: familyId ?? this.familyId,
      permissionLevel: permissionLevel ?? this.permissionLevel,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.displayName == displayName &&
        other.familyId == familyId &&
        other.permissionLevel == permissionLevel &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.profileImageUrl == profileImageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      displayName,
      familyId,
      permissionLevel,
      createdAt,
      updatedAt,
      profileImageUrl,
    );
  }

  @override
  String toString() {
    return 'User('
        'id: $id, '
        'displayName: $displayName, '
        'familyId: $familyId, '
        'permissionLevel: $permissionLevel, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'profileImageUrl: $profileImageUrl'
        ')';
  }
}
