import 'package:meta/meta.dart';
import 'package:staccato_api_server/models/user.dart';

/// Request data for creating a new family invitation.
///
/// This model contains all the information needed to create a family invitation, including the permission level that
/// will be assigned to the invited user and optional recipient details for personalization.
///
/// The [FamilyInvitationCreateRequest] is used in API endpoints for invitation creation and validates that all required
/// information is provided and that the requesting user has appropriate permissions.
@immutable
class FamilyInvitationCreateRequest {
  /// Creates a new [FamilyInvitationCreateRequest] instance with the specified properties.
  ///
  /// The [targetPermissionLevel] parameter is required and determines the access rights the invited user will have. The
  /// optional parameters allow for personalization and notification of the invitation.
  const FamilyInvitationCreateRequest({
    required this.targetPermissionLevel,
    this.invitedEmail,
    this.invitedDisplayName,
    this.expirationDays = 7,
  });

  /// Permission level that will be assigned to the invited user.
  ///
  /// This determines the access rights and capabilities the invited user will have within the family group. The
  /// requesting user must have sufficient authority to grant this permission level.
  ///
  /// Common scenarios:
  /// - Primary users can invite adult or child users
  /// - Adult users can typically only invite child users (depending on family settings)
  /// - Child users cannot create invitations
  final UserPermissionLevel targetPermissionLevel;

  /// Email address of the person being invited (optional).
  ///
  /// When provided, this email can be used to send invitation notifications and to validate that the correct person is
  /// accepting the invitation. This field is optional for privacy reasons but recommended for security.
  final String? invitedEmail;

  /// Display name for the person being invited (optional).
  ///
  /// This can be used to personalize invitation messages and to help family members identify who was invited. This
  /// field is optional and can be provided by the inviting user for better organization.
  final String? invitedDisplayName;

  /// Number of days until the invitation expires.
  ///
  /// This determines how long the invitation remains valid before it automatically expires. The default is 7 days,
  /// which provides a reasonable balance between security and convenience.
  ///
  /// Constraints:
  /// - Must be between 1 and 30 days
  /// - Shorter expiration times improve security
  /// - Longer expiration times improve convenience
  final int expirationDays;

  /// Creates a FamilyInvitationCreateRequest instance from a JSON map.
  ///
  /// This factory constructor is used for deserializing request data from API calls and other JSON sources.
  ///
  /// Parameters:
  /// * [json] - Map containing invitation creation request data with string keys
  ///
  /// Returns a new [FamilyInvitationCreateRequest] instance with data from the JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed or missing required fields.
  ///
  /// Throws [ArgumentError] if field values are invalid (e.g., invalid permission level, invalid expiration days).
  factory FamilyInvitationCreateRequest.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and extract required fields
      final String? targetPermissionLevelString = json['targetPermissionLevel'] as String?;
      if (targetPermissionLevelString == null || targetPermissionLevelString.isEmpty) {
        throw ArgumentError('Missing or empty required field: targetPermissionLevel');
      }

      // Parse permission level
      final UserPermissionLevel targetPermissionLevel = UserPermissionLevel.fromString(targetPermissionLevelString);

      // Extract optional fields
      final String? invitedEmail = json['invitedEmail'] as String?;
      final String? invitedDisplayName = json['invitedDisplayName'] as String?;

      // Extract and validate expiration days
      final int expirationDays = json['expirationDays'] as int? ?? 7;
      if (expirationDays < 1 || expirationDays > 30) {
        throw ArgumentError('Expiration days must be between 1 and 30');
      }

      // Validate email format if provided
      if (invitedEmail != null && invitedEmail.isNotEmpty && !_isValidEmail(invitedEmail)) {
        throw ArgumentError('Invalid email format: $invitedEmail');
      }

      return FamilyInvitationCreateRequest(
        targetPermissionLevel: targetPermissionLevel,
        invitedEmail: invitedEmail,
        invitedDisplayName: invitedDisplayName,
        expirationDays: expirationDays,
      );
    } catch (e) {
      throw FormatException('Failed to parse FamilyInvitationCreateRequest from JSON: $e');
    }
  }

  /// Converts this FamilyInvitationCreateRequest instance to a JSON map.
  ///
  /// This method is used for serializing request data for API calls, logging, and other JSON-based operations.
  ///
  /// Returns a [Map<String, dynamic>] containing all request properties with appropriate JSON-compatible types.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'targetPermissionLevel': targetPermissionLevel.value,
      'invitedEmail': invitedEmail,
      'invitedDisplayName': invitedDisplayName,
      'expirationDays': expirationDays,
    };
  }

  /// Validates this request and returns a list of validation errors.
  ///
  /// This method performs comprehensive validation of the request data and returns a list of error messages for any
  /// validation failures. An empty list indicates the request is valid.
  ///
  /// Returns a [List<String>] containing validation error messages, or an empty list if validation passes.
  ///
  /// Validation rules:
  /// - Target permission level must be valid
  /// - Expiration days must be between 1 and 30
  /// - Email (if provided) must be in valid format
  /// - Display name (if provided) must not exceed 100 characters
  List<String> validate() {
    final List<String> errors = <String>[];

    // Validate expiration days
    if (expirationDays < 1 || expirationDays > 30) {
      errors.add('Expiration days must be between 1 and 30');
    }

    // Validate email format if provided
    if (invitedEmail != null && !_isValidEmail(invitedEmail!)) {
      errors.add('Invalid email format');
    }

    // Validate display name length if provided
    if (invitedDisplayName != null && invitedDisplayName!.length > 100) {
      errors.add('Display name cannot exceed 100 characters');
    }

    return errors;
  }

  /// Whether this request is valid and can be processed.
  ///
  /// Returns `true` if the request passes all validation rules, `false` otherwise. This is a convenience method that
  /// checks if the validate() method returns an empty list.
  bool get isValid => validate().isEmpty;

  /// Calculates the expiration date for the invitation based on the expiration days.
  ///
  /// Returns a [DateTime] representing when the invitation should expire. This is calculated as the current time plus
  /// the specified number of expiration days.
  DateTime calculateExpirationDate() {
    return DateTime.now().add(Duration(days: expirationDays));
  }

  /// Validates whether the requesting user can invite someone with the target permission level.
  ///
  /// This method checks if the requesting user has sufficient authority to create an invitation for the specified
  /// permission level based on the permission hierarchy.
  ///
  /// Parameters:
  /// * [requestingUserPermissionLevel] - The permission level of the user creating the invitation
  ///
  /// Returns `true` if the requesting user can create this invitation, `false` otherwise.
  ///
  /// Authorization rules:
  /// - Primary users can invite adult or child users (but not other primary users)
  /// - Adult users can invite child users (but not other adults or primary users)
  /// - Child users cannot create invitations
  /// - Users cannot invite someone with equal or higher permissions than themselves
  bool canBeCreatedBy(UserPermissionLevel requestingUserPermissionLevel) {
    // Only primary and adult users can create invitations
    if (!requestingUserPermissionLevel.isAdult) {
      return false;
    }

    // Users cannot invite someone with equal or higher permissions than themselves
    // We need to check that the requesting user has STRICTLY higher authority
    const List<UserPermissionLevel> hierarchy = [
      UserPermissionLevel.primary,
      UserPermissionLevel.adult,
      UserPermissionLevel.child,
    ];

    final int requestingIndex = hierarchy.indexOf(requestingUserPermissionLevel);
    final int targetIndex = hierarchy.indexOf(targetPermissionLevel);

    // Requesting user must have strictly higher authority (lower index in hierarchy)
    return requestingIndex < targetIndex;
  }

  /// Simple email validation helper method.
  ///
  /// This method performs basic email format validation using a simple regex pattern. It's not comprehensive but
  /// catches most common format errors.
  ///
  /// Parameters:
  /// * [email] - The email address to validate
  ///
  /// Returns `true` if the email appears to be in a valid format, `false` otherwise.
  static bool _isValidEmail(String email) {
    // Basic email validation that rejects common invalid patterns
    if (email.isEmpty) return false;
    if (email.startsWith('.') || email.endsWith('.')) return false;
    if (email.startsWith('@') || email.endsWith('@')) return false;
    if (email.contains('..')) return false; // No consecutive dots
    if (!email.contains('@')) return false;

    final List<String> parts = email.split('@');
    if (parts.length != 2) return false; // Exactly one @ symbol
    if (parts[0].isEmpty || parts[1].isEmpty) return false;
    if (!parts[1].contains('.')) return false; // Domain must have a dot
    if (parts[1].startsWith('.') || parts[1].endsWith('.')) return false;

    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FamilyInvitationCreateRequest &&
        other.targetPermissionLevel == targetPermissionLevel &&
        other.invitedEmail == invitedEmail &&
        other.invitedDisplayName == invitedDisplayName &&
        other.expirationDays == expirationDays;
  }

  @override
  int get hashCode {
    return Object.hash(
      targetPermissionLevel,
      invitedEmail,
      invitedDisplayName,
      expirationDays,
    );
  }

  @override
  String toString() {
    return 'FamilyInvitationCreateRequest('
        'targetPermissionLevel: $targetPermissionLevel, '
        'invitedEmail: $invitedEmail, '
        'invitedDisplayName: $invitedDisplayName, '
        'expirationDays: $expirationDays'
        ')';
  }
}
