import 'user_permission_level.dart';

/// Request model for creating new users in the Staccato system.
///
/// This immutable class encapsulates all the information needed to create a new user account. It's designed to be used
/// for user creation while excluding system-generated fields like ID and timestamps.
class UserCreateRequest {
  /// Creates a new user creation request with the specified data.
  ///
  /// Parameters:
  /// * [displayName] - User's display name
  /// * [familyId] - ID of the family this user will belong to
  /// * [permissionLevel] - Permission level for the user
  /// * [profileImageUrl] - Optional URL to the user's profile image
  const UserCreateRequest({
    required this.displayName,
    required this.familyId,
    required this.permissionLevel,
    this.profileImageUrl,
  });

  /// User's display name shown throughout the application.
  ///
  /// This is the human-readable name that will be displayed in the UI, task assignments, calendar events, and other
  /// user-facing contexts.
  final String displayName;

  /// ID of the family group this user will belong to.
  ///
  /// Every user must belong to exactly one family group. This field establishes the relationship between the new user
  /// and their family group.
  final String familyId;

  /// Permission level for the new user.
  ///
  /// This field determines what features and data the user can access within their family group. See
  /// [UserPermissionLevel] for details about each permission level's capabilities.
  final UserPermissionLevel permissionLevel;

  /// Optional URL to the user's profile image.
  ///
  /// This field contains a URL pointing to the user's profile picture. If null, the UI should display a default
  /// avatar.
  final String? profileImageUrl;

  /// Creates a UserCreateRequest from a JSON map.
  ///
  /// This factory constructor is used for deserializing request data from HTTP requests and other JSON sources.
  ///
  /// Parameters:
  /// * [json] - Map containing request data with string keys
  ///
  /// Returns a new [UserCreateRequest] instance with data from the JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed or missing required fields.
  ///
  /// Throws [ArgumentError] if field values are invalid.
  factory UserCreateRequest.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and extract required fields
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

      // Parse permission level
      final UserPermissionLevel permissionLevel =
          UserPermissionLevel.fromString(permissionLevelString);

      // Extract optional fields
      final String? profileImageUrl = json['profileImageUrl'] as String?;

      return UserCreateRequest(
        displayName: displayName,
        familyId: familyId,
        permissionLevel: permissionLevel,
        profileImageUrl: profileImageUrl,
      );
    } catch (e) {
      throw FormatException('Failed to parse UserCreateRequest from JSON: $e');
    }
  }

  /// Converts this [UserCreateRequest] to a JSON map.
  ///
  /// This method is used for serializing request data for API calls and other JSON-based operations.
  ///
  /// Returns a [Map<String, dynamic>] containing all request properties with appropriate JSON-compatible types.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'displayName': displayName,
      'familyId': familyId,
      'permissionLevel': permissionLevel.value,
      'profileImageUrl': profileImageUrl,
    };
  }

  @override
  String toString() {
    return 'UserCreateRequest('
        'displayName: $displayName, '
        'familyId: $familyId, '
        'permissionLevel: $permissionLevel, '
        'profileImageUrl: $profileImageUrl'
        ')';
  }
}
