/// Enumeration of user permission levels within a family group.
///
/// This enum defines the different access levels that users can have within their family group. Each level grants
/// specific capabilities and access rights, with higher levels including all permissions from lower levels.
///
/// The permission system is designed to provide appropriate access control while maintaining simplicity for family use.
enum UserPermissionLevel {
  /// Child user with restricted access to age-appropriate features.
  ///
  /// Child users have limited access to the system with parental controls and content filtering. They can view and
  /// interact with content deemed appropriate for their age group but cannot modify family settings or manage other
  /// users.
  ///
  /// Capabilities:
  /// * View assigned tasks and chores
  /// * Mark tasks as complete
  /// * View family calendar events
  /// * Access age-appropriate content
  /// * Cannot manage other users
  /// * Cannot modify family settings
  child('child'),

  /// Adult user with full access to family features.
  ///
  /// Adult users have comprehensive access to all family management features. They can create and manage tasks, view
  /// all content, and participate fully in family activities without restrictions.
  ///
  /// Capabilities:
  /// * All child capabilities
  /// * Create and assign tasks
  /// * Manage family calendar
  /// * Access all content without restrictions
  /// * View family reports and analytics
  /// * Cannot manage other users (except children)
  /// * Cannot modify critical family settings
  adult('adult'),

  /// Primary administrator with full system access.
  ///
  /// The primary user has complete administrative control over the family group. This level is typically assigned to
  /// the family head or primary account holder and includes all system capabilities.
  ///
  /// Capabilities:
  /// * All adult capabilities
  /// * Add and remove family members
  /// * Modify user permission levels
  /// * Configure family settings
  /// * Access billing and subscription management
  /// * Delete family data
  /// * Transfer primary ownership
  primary('primary');

  /// Creates a UserPermissionLevel with the specified string value.
  ///
  /// The [value] parameter represents the string representation of this permission level used in JSON serialization
  /// and API communication.
  const UserPermissionLevel(this.value);

  /// String representation of this permission level.
  ///
  /// This value is used for JSON serialization, API requests, and database storage. It provides a stable string
  /// identifier that remains consistent across system versions.
  final String value;

  /// Whether this permission level has administrative privileges.
  ///
  /// Returns `true` for permission levels that can perform administrative actions such as managing other users or
  /// modifying family settings.
  bool get isAdmin => this == UserPermissionLevel.primary;

  /// Whether this permission level represents an adult user.
  ///
  /// Returns `true` for permission levels that grant access to adult features and content. Returns `false` for child
  /// users who have restricted access.
  bool get isAdult =>
      this == UserPermissionLevel.adult || this == UserPermissionLevel.primary;

  /// Whether this permission level can manage other family members.
  ///
  /// Returns `true` for permission levels that can add, remove, or modify other users in the family group.
  bool get canManageUsers => this == UserPermissionLevel.primary;

  /// Creates a UserPermissionLevel from its string representation.
  ///
  /// This factory method is used for deserializing permission levels from JSON data, API responses, and database
  /// queries.
  ///
  /// Parameters:
  /// * [value] - String representation of the permission level
  ///
  /// Returns the corresponding [UserPermissionLevel] enum value.
  ///
  /// Throws [ArgumentError] if the provided value doesn't match any known permission level.
  factory UserPermissionLevel.fromString(String value) {
    for (final UserPermissionLevel level in UserPermissionLevel.values) {
      if (level.value == value) {
        return level;
      }
    }
    throw ArgumentError('Invalid permission level: $value');
  }

  @override
  String toString() => value;
}
