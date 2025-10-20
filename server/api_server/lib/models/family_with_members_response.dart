import 'package:meta/meta.dart';
import 'package:staccato_api_server/models/family.dart';
import 'package:staccato_api_server/models/family_member_summary.dart';

/// Response data containing family information along with member details.
///
/// This model provides a complete view of a family group including its configuration, settings, and all current
/// members. It's typically used in API responses for family dashboard views, member management screens, and other
/// contexts where comprehensive family information is needed.
///
/// The [FamilyWithMembersResponse] combines the full family data with lightweight member summaries to balance
/// completeness with performance.
@immutable
class FamilyWithMembersResponse {
  /// Creates a new [FamilyWithMembersResponse] instance with the specified properties.
  ///
  /// Both [family] and [members] parameters are required to provide complete family information.
  const FamilyWithMembersResponse({
    required this.family,
    required this.members,
  });

  /// Complete family group information.
  ///
  /// This contains all family metadata including name, settings, creation date, and other configuration details.
  final Family family;

  /// List of family members with summary information.
  ///
  /// This list contains lightweight member data including names, permission levels, and profile images. Members are
  /// typically sorted by permission level (primary first, then adults, then children) and then by display name.
  final List<FamilyMemberSummary> members;

  /// Total number of family members.
  ///
  /// Returns the count of members in the family group. This is a convenience getter that returns the length of the
  /// members list.
  int get memberCount => members.length;

  /// Whether the family has reached its maximum member limit.
  ///
  /// Returns `true` if the current member count equals or exceeds the maximum allowed members as configured in the
  /// family settings. This can be used to determine if new invitations should be allowed.
  bool get isAtMemberLimit => memberCount >= family.settings.maxFamilyMembers;

  /// List of adult members (primary and adult permission levels).
  ///
  /// Returns a filtered list containing only members with adult-level permissions. This is useful for displaying
  /// administrative contacts or determining who can perform certain actions.
  List<FamilyMemberSummary> get adultMembers => members.where((FamilyMemberSummary member) => member.isAdult).toList();

  /// List of child members.
  ///
  /// Returns a filtered list containing only members with child permission level. This is useful for parental controls,
  /// task assignments, and other child-specific features.
  List<FamilyMemberSummary> get childMembers => members.where((FamilyMemberSummary member) => !member.isAdult).toList();

  /// The primary administrator of the family.
  ///
  /// Returns the family member who serves as the primary administrator, or null if the primary user is not found in the
  /// members list (which would indicate a data consistency issue).
  FamilyMemberSummary? get primaryMember {
    try {
      return members.firstWhere((FamilyMemberSummary member) => member.id == family.primaryUserId);
    } catch (e) {
      return null;
    }
  }

  /// Creates a FamilyWithMembersResponse instance from a JSON map.
  ///
  /// This factory constructor is used for deserializing response data from API calls and other JSON sources.
  ///
  /// Parameters:
  /// * [json] - Map containing family and members data with string keys
  ///
  /// Returns a new [FamilyWithMembersResponse] instance with data from the JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed or missing required fields.
  ///
  /// Throws [ArgumentError] if field values are invalid.
  factory FamilyWithMembersResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and extract required fields
      final Map<String, dynamic>? familyJson = json['family'] as Map<String, dynamic>?;
      if (familyJson == null) {
        throw ArgumentError('Missing required field: family');
      }

      final List<dynamic>? membersJson = json['members'] as List<dynamic>?;
      if (membersJson == null) {
        throw ArgumentError('Missing required field: members');
      }

      // Parse nested objects
      final Family family = Family.fromJson(familyJson);

      final List<FamilyMemberSummary> members = membersJson
          .map((dynamic memberJson) => FamilyMemberSummary.fromJson(memberJson as Map<String, dynamic>))
          .toList();

      return FamilyWithMembersResponse(
        family: family,
        members: members,
      );
    } catch (e) {
      throw FormatException('Failed to parse FamilyWithMembersResponse from JSON: $e');
    }
  }

  /// Converts this FamilyWithMembersResponse instance to a JSON map.
  ///
  /// This method is used for serializing response data for API calls and other JSON-based operations.
  ///
  /// Returns a [Map<String, dynamic>] containing all response properties with appropriate JSON-compatible types.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'family': family.toJson(),
      'members': members.map((FamilyMemberSummary member) => member.toJson()).toList(),
      'memberCount': memberCount,
      'isAtMemberLimit': isAtMemberLimit,
    };
  }

  /// Creates a copy of this FamilyWithMembersResponse with the specified fields updated.
  ///
  /// This method returns a new FamilyWithMembersResponse instance with the same values as the current instance, except
  /// for the fields explicitly provided as parameters. This is useful for updating response data while maintaining
  /// immutability.
  ///
  /// Parameters:
  /// * [family] - New family data (optional)
  /// * [members] - New members list (optional)
  ///
  /// Returns a new [FamilyWithMembersResponse] instance with updated values.
  FamilyWithMembersResponse copyWith({
    Family? family,
    List<FamilyMemberSummary>? members,
  }) {
    return FamilyWithMembersResponse(
      family: family ?? this.family,
      members: members ?? this.members,
    );
  }

  /// Sorts members by permission level and display name.
  ///
  /// Returns a new [FamilyWithMembersResponse] with members sorted in the following order:
  /// 1. Primary administrator first
  /// 2. Adult members (sorted alphabetically by display name)
  /// 3. Child members (sorted alphabetically by display name)
  ///
  /// This sorting provides a consistent and logical ordering for display in UI components.
  FamilyWithMembersResponse withSortedMembers() {
    final List<FamilyMemberSummary> sortedMembers = List<FamilyMemberSummary>.from(members)

    ..sort((FamilyMemberSummary a, FamilyMemberSummary b) {
      // Primary user always comes first
      if (a.id == family.primaryUserId) return -1;
      if (b.id == family.primaryUserId) return 1;

      // Then sort by permission level (adults before children)
      if (a.isAdult && !b.isAdult) return -1;
      if (!a.isAdult && b.isAdult) return 1;

      // Within the same permission category, sort alphabetically by display name
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });

    return copyWith(members: sortedMembers);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FamilyWithMembersResponse && other.family == family && _listEquals(other.members, members);
  }

  @override
  int get hashCode {
    return Object.hash(
      family,
      Object.hashAll(members),
    );
  }

  @override
  String toString() {
    return 'FamilyWithMembersResponse('
        'family: $family, '
        'members: $members, '
        'memberCount: $memberCount'
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
