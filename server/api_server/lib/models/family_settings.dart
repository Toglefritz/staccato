part of 'family.dart';

/// Configuration settings and preferences for a family group.
///
/// This class contains all customizable family-level settings including privacy preferences, notification settings,
/// feature toggles, and other configuration options that affect the entire family group.
///
/// Settings are managed by the primary family administrator and apply to all family members unless overridden by
/// individual user preferences.
@immutable
class FamilySettings {
  /// Creates a new [FamilySettings] instance with the specified configuration.
  ///
  /// All parameters have sensible defaults that provide a good out-of-the-box experience for new families.
  const FamilySettings({
    this.timezone = 'UTC',
    this.allowChildRegistration = true,
    this.requireTaskApproval = false,
    this.enableNotifications = true,
    this.allowGuestAccess = false,
    this.maxFamilyMembers = 10,
    this.defaultChildPermissions = const <String>[],
    this.enableLocationSharing = false,
    this.requireParentalApproval = true,
  });

  /// Timezone identifier for the family group.
  ///
  /// This setting determines the default timezone used for displaying dates, times, and scheduling events throughout
  /// the application. It should be a valid IANA timezone identifier (e.g., 'America/New_York', 'Europe/London').
  ///
  /// All family members will see times displayed in this timezone unless they have individually configured a different
  /// preference.
  final String timezone;

  /// Whether children can register new accounts within this family.
  ///
  /// When `true`, child users can create their own accounts and join the family using an invitation code or link. When
  /// `false`, only the primary administrator can create child accounts.
  ///
  /// This setting helps families control how new members are added and ensures appropriate oversight of child account
  /// creation.
  final bool allowChildRegistration;

  /// Whether tasks assigned to children require adult approval before completion.
  ///
  /// When `true`, tasks completed by child users will be marked as "pending approval" and require an adult family
  /// member to review and approve the completion. When `false`, child users can mark tasks as complete independently.
  ///
  /// This setting is useful for families who want to maintain oversight of chore completion and ensure quality
  /// standards.
  final bool requireTaskApproval;

  /// Whether push notifications are enabled for this family.
  ///
  /// When `true`, family members will receive push notifications for task assignments, calendar reminders, and other
  /// family activities. When `false`, notifications are disabled family-wide.
  ///
  /// Individual users can still override this setting in their personal preferences.
  final bool enableNotifications;

  /// Whether guest users can access limited family information.
  ///
  /// When `true`, the family can generate temporary guest access codes that allow non-family members to view certain
  /// information like public calendar events or shared shopping lists. When `false`, all family data is restricted to
  /// registered family members only.
  ///
  /// This feature is useful for coordinating with extended family, babysitters, or other trusted individuals.
  final bool allowGuestAccess;

  /// Maximum number of family members allowed in this family group.
  ///
  /// This setting enforces a limit on the total number of users who can join the family. The default limit of 10
  /// members should accommodate most families while preventing abuse.
  ///
  /// The primary administrator can adjust this limit up to the system maximum based on their subscription plan.
  final int maxFamilyMembers;

  /// Default permissions granted to new child users.
  ///
  /// This list contains permission identifiers that are automatically granted to child users when they join the family.
  /// Common permissions might include 'view_calendar', 'complete_tasks', 'access_games', etc.
  ///
  /// These permissions can be individually modified for each child user after account creation.
  final List<String> defaultChildPermissions;

  /// Whether family members can share their location with each other.
  ///
  /// When `true`, family members can opt-in to location sharing features that allow other family members to see their
  /// current location. When `false`, all location sharing features are disabled family-wide.
  ///
  /// This setting is particularly useful for families with teenagers or for coordinating pickups and activities.
  final bool enableLocationSharing;

  /// Whether actions by child users require parental approval.
  ///
  /// When `true`, certain actions performed by child users (such as making purchases, changing settings, or accessing
  /// restricted content) will require approval from an adult family member. When `false`, child users have more
  /// autonomy within their permission level.
  ///
  /// This setting provides an additional layer of parental control beyond the basic permission system.
  final bool requireParentalApproval;

  /// Creates a FamilySettings instance from a JSON map.
  ///
  /// This factory constructor is used for deserializing family settings from API responses, database queries, and other
  /// JSON sources.
  ///
  /// Parameters:
  /// * [json] - Map containing family settings data with string keys
  ///
  /// Returns a new [FamilySettings] instance with data from the JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed.
  ///
  /// Throws [ArgumentError] if field values are invalid (e.g., negative maxFamilyMembers, invalid timezone).
  factory FamilySettings.fromJson(Map<String, dynamic> json) {
    try {
      // Extract settings with defaults
      final String timezone = json['timezone'] as String? ?? 'UTC';
      final bool allowChildRegistration = json['allowChildRegistration'] as bool? ?? true;
      final bool requireTaskApproval = json['requireTaskApproval'] as bool? ?? false;
      final bool enableNotifications = json['enableNotifications'] as bool? ?? true;
      final bool allowGuestAccess = json['allowGuestAccess'] as bool? ?? false;
      final int maxFamilyMembers = json['maxFamilyMembers'] as int? ?? 10;
      final bool enableLocationSharing = json['enableLocationSharing'] as bool? ?? false;
      final bool requireParentalApproval = json['requireParentalApproval'] as bool? ?? true;

      // Handle list fields
      final List<dynamic>? defaultChildPermissionsList = json['defaultChildPermissions'] as List<dynamic>?;
      final List<String> defaultChildPermissions =
          defaultChildPermissionsList?.map((dynamic item) => item.toString()).toList() ?? <String>[];

      // Validate constraints
      if (maxFamilyMembers < 1) {
        throw ArgumentError('maxFamilyMembers must be at least 1');
      }

      if (maxFamilyMembers > 50) {
        throw ArgumentError('maxFamilyMembers cannot exceed 50');
      }

      return FamilySettings(
        timezone: timezone,
        allowChildRegistration: allowChildRegistration,
        requireTaskApproval: requireTaskApproval,
        enableNotifications: enableNotifications,
        allowGuestAccess: allowGuestAccess,
        maxFamilyMembers: maxFamilyMembers,
        defaultChildPermissions: defaultChildPermissions,
        enableLocationSharing: enableLocationSharing,
        requireParentalApproval: requireParentalApproval,
      );
    } catch (e) {
      throw FormatException('Failed to parse FamilySettings from JSON: $e');
    }
  }

  /// Converts this FamilySettings instance to a JSON map.
  ///
  /// This method is used for serializing family settings for API requests, database storage, and other JSON-based
  /// operations.
  ///
  /// Returns a [Map<String, dynamic>] containing all settings with appropriate JSON-compatible types.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'timezone': timezone,
      'allowChildRegistration': allowChildRegistration,
      'requireTaskApproval': requireTaskApproval,
      'enableNotifications': enableNotifications,
      'allowGuestAccess': allowGuestAccess,
      'maxFamilyMembers': maxFamilyMembers,
      'defaultChildPermissions': defaultChildPermissions,
      'enableLocationSharing': enableLocationSharing,
      'requireParentalApproval': requireParentalApproval,
    };
  }

  /// Creates a copy of this FamilySettings with the specified fields updated.
  ///
  /// This method returns a new FamilySettings instance with the same values as the current instance, except for the
  /// fields explicitly provided as parameters. This is useful for updating settings while maintaining immutability.
  ///
  /// Parameters:
  /// * [timezone] - New timezone identifier (optional)
  /// * [allowChildRegistration] - New child registration setting (optional)
  /// * [requireTaskApproval] - New task approval requirement (optional)
  /// * [enableNotifications] - New notification setting (optional)
  /// * [allowGuestAccess] - New guest access setting (optional)
  /// * [maxFamilyMembers] - New maximum member limit (optional)
  /// * [defaultChildPermissions] - New default child permissions (optional)
  /// * [enableLocationSharing] - New location sharing setting (optional)
  /// * [requireParentalApproval] - New parental approval requirement (optional)
  ///
  /// Returns a new [FamilySettings] instance with updated values.
  FamilySettings copyWith({
    String? timezone,
    bool? allowChildRegistration,
    bool? requireTaskApproval,
    bool? enableNotifications,
    bool? allowGuestAccess,
    int? maxFamilyMembers,
    List<String>? defaultChildPermissions,
    bool? enableLocationSharing,
    bool? requireParentalApproval,
  }) {
    return FamilySettings(
      timezone: timezone ?? this.timezone,
      allowChildRegistration: allowChildRegistration ?? this.allowChildRegistration,
      requireTaskApproval: requireTaskApproval ?? this.requireTaskApproval,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      allowGuestAccess: allowGuestAccess ?? this.allowGuestAccess,
      maxFamilyMembers: maxFamilyMembers ?? this.maxFamilyMembers,
      defaultChildPermissions: defaultChildPermissions ?? this.defaultChildPermissions,
      enableLocationSharing: enableLocationSharing ?? this.enableLocationSharing,
      requireParentalApproval: requireParentalApproval ?? this.requireParentalApproval,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FamilySettings &&
        other.timezone == timezone &&
        other.allowChildRegistration == allowChildRegistration &&
        other.requireTaskApproval == requireTaskApproval &&
        other.enableNotifications == enableNotifications &&
        other.allowGuestAccess == allowGuestAccess &&
        other.maxFamilyMembers == maxFamilyMembers &&
        _listEquals(other.defaultChildPermissions, defaultChildPermissions) &&
        other.enableLocationSharing == enableLocationSharing &&
        other.requireParentalApproval == requireParentalApproval;
  }

  @override
  int get hashCode {
    return Object.hash(
      timezone,
      allowChildRegistration,
      requireTaskApproval,
      enableNotifications,
      allowGuestAccess,
      maxFamilyMembers,
      Object.hashAll(defaultChildPermissions),
      enableLocationSharing,
      requireParentalApproval,
    );
  }

  @override
  String toString() {
    return 'FamilySettings('
        'timezone: $timezone, '
        'allowChildRegistration: $allowChildRegistration, '
        'requireTaskApproval: $requireTaskApproval, '
        'enableNotifications: $enableNotifications, '
        'allowGuestAccess: $allowGuestAccess, '
        'maxFamilyMembers: $maxFamilyMembers, '
        'defaultChildPermissions: $defaultChildPermissions, '
        'enableLocationSharing: $enableLocationSharing, '
        'requireParentalApproval: $requireParentalApproval'
        ')';
  }

  /// Helper method to compare two lists for equality.
  ///
  /// This is needed because Dart's default list equality comparison checks reference equality, not content equality.
  bool _listEquals<T>(List<T>? a, List<T>? b) {
    if (a == null) return b == null;
    if (b == null || a.length != b.length) return false;
    for (int index = 0; index < a.length; index += 1) {
      if (a[index] != b[index]) return false;
    }
    return true;
  }
}
