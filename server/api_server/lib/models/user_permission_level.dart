part of 'user.dart';

/// Enumeration of user permission levels within a family group.
///
/// Each permission level grants specific capabilities and access rights:
///
/// - **Primary**: The family administrator with full control over all
/// family settings, member management, and system configuration. Only one primary user per family group is allowed.
///
/// - **Adult**: Standard adult user with access to most features including
/// task management, calendar editing, and viewing family information. Cannot modify family settings or manage other
/// users.
///
/// - **Child**: Limited user appropriate for children with restricted
/// access to age-appropriate features and content. Cannot modify family settings or access administrative functions.
enum UserPermissionLevel {
  /// Primary family administrator with full system access.
  ///
  /// Capabilities:
  /// - Manage all family members and their permissions
  /// - Configure family settings and preferences
  /// - Access all administrative functions
  /// - View and modify all family data
  /// - Delete or modify the family group
  primary('primary'),

  /// Standard adult user with most features enabled.
  ///
  /// Capabilities:
  /// - Create and manage tasks and calendar events
  /// - View family information and member profiles
  /// - Access age-appropriate content and features
  /// - Modify their own profile and preferences
  /// - Cannot manage other users or family settings
  adult('adult'),

  /// Limited user appropriate for children.
  ///
  /// Capabilities:
  /// - View assigned tasks and calendar events
  /// - Access child-appropriate content and games
  /// - Complete assigned tasks and activities
  /// - View limited family information
  /// - Cannot modify family data or access admin functions
  child('child');

  /// Creates a permission level with the specified string value.
  ///
  /// The [value] parameter represents the string representation used for JSON serialization and database storage.
  const UserPermissionLevel(this.value);

  /// String representation of the permission level.
  ///
  /// This value is used for JSON serialization, database storage, and API communication. It matches the enum name in
  /// lowercase.
  final String value;

  /// Creates a [UserPermissionLevel] from its string representation.
  ///
  /// This factory constructor is used for JSON deserialization and converting string values back to enum instances.
  ///
  /// Parameters:
  /// * [value] - The string representation of the permission level
  ///
  /// Returns the corresponding [UserPermissionLevel] enum value.
  ///
  /// Throws [ArgumentError] if the provided value doesn't match any valid permission level.
  factory UserPermissionLevel.fromString(String value) {
    return UserPermissionLevel.values.firstWhere(
      (UserPermissionLevel level) => level.value == value.toLowerCase(),
      orElse: () => throw ArgumentError(
        'Invalid permission level: $value. '
        'Valid values are: ${UserPermissionLevel.values.map((UserPermissionLevel e) => e.value).join(', ')}',
      ),
    );
  }

  /// Whether this permission level has administrative privileges.
  ///
  /// Returns `true` for [primary] users who can manage family settings and other users. Returns `false` for [adult] and
  /// [child] users.
  bool get isAdmin => this == UserPermissionLevel.primary;

  /// Whether this permission level has adult-level access.
  ///
  /// Returns `true` for [primary] and [adult] users who can access most features. Returns `false` for [child] users
  /// with limited access.
  bool get isAdult =>
      this == UserPermissionLevel.primary || this == UserPermissionLevel.adult;

  /// Whether this permission level can manage other users.
  ///
  /// Returns `true` only for [primary] users who can add, remove, and modify other family members. Returns `false` for
  /// all other levels.
  bool get canManageUsers => this == UserPermissionLevel.primary;

  /// Whether this permission level can modify family settings.
  ///
  /// Returns `true` only for [primary] users who can change family configuration, preferences, and administrative
  /// settings.
  bool get canModifyFamilySettings => this == UserPermissionLevel.primary;

  /// Compares this permission level with another for authorization checks.
  ///
  /// Returns `true` if this permission level has equal or higher authority than the [other] permission level. Used for
  /// authorization logic where higher-level users can perform actions on lower-level users.
  ///
  /// Permission hierarchy (highest to lowest):
  /// 1. primary
  /// 2. adult
  /// 3. child
  bool hasAuthorityOver(UserPermissionLevel other) {
    const List<UserPermissionLevel> hierarchy = [
      UserPermissionLevel.primary,
      UserPermissionLevel.adult,
      UserPermissionLevel.child,
    ];

    final int thisIndex = hierarchy.indexOf(this);
    final int otherIndex = hierarchy.indexOf(other);

    return thisIndex <= otherIndex;
  }

  @override
  String toString() => value;
}
