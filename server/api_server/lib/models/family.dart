/// Family model representing a family group in the Staccato system.
///
/// This model contains all family information including metadata, settings, and member relationships. It handles JSON
/// serialization for API communication and database storage.
///
/// Each family group serves as the primary organizational unit for users, tasks, calendar events, and other shared data
/// within the Staccato system.
library;

import 'package:meta/meta.dart';

// Parts
part 'family_settings.dart';

/// Represents a family group in the Staccato system.
///
/// A family group is the primary organizational unit that contains multiple users (family members) and serves as the
/// boundary for data sharing and permissions. Each family has exactly one primary administrator and can have multiple
/// adult and child members.
///
/// The [Family] model is immutable and contains all necessary information for family management, member organization,
/// and system configuration.
@immutable
class Family {
  /// Creates a new [Family] instance with the specified properties.
  ///
  /// All parameters except [updatedAt] are required. The [updatedAt] field is automatically set when the family is
  /// modified.
  const Family({
    required this.id,
    required this.name,
    required this.primaryUserId,
    required this.settings,
    required this.createdAt,
    this.updatedAt,
  });

  /// Unique identifier for this family group.
  ///
  /// This ID is generated when the family is created and remains constant throughout the family's lifetime. It's used
  /// for database references, API endpoints, and establishing relationships with users and other entities.
  final String id;

  /// Display name for the family group.
  ///
  /// This is the human-readable name shown throughout the application, such as "The Smith Family" or "Johnson
  /// Household". It can be changed by the primary administrator.
  final String name;

  /// ID of the primary administrator for this family.
  ///
  /// The primary user has full administrative privileges including the ability to manage other family members, modify
  /// family settings, and delete the family group. There must always be exactly one primary user per family.
  final String primaryUserId;

  /// Configuration settings and preferences for this family.
  ///
  /// Contains all customizable family-level settings including privacy preferences, notification settings, feature
  /// toggles, and other configuration options. See [FamilySettings] for detailed information.
  final FamilySettings settings;

  /// Timestamp when this family group was created.
  ///
  /// This field is set once during family creation and never changes. It's used for auditing, analytics, and
  /// determining family tenure within the system.
  final DateTime createdAt;

  /// Timestamp when this family was last updated.
  ///
  /// This field is automatically updated whenever any family property is modified. It's used for synchronization,
  /// caching, and conflict resolution in distributed systems.
  final DateTime? updatedAt;

  /// Creates a Family instance from a JSON map.
  ///
  /// This factory constructor is used for deserializing family data from API responses, database queries, and other
  /// JSON sources.
  ///
  /// Parameters:
  /// * [json] - Map containing family data with string keys
  ///
  /// Returns a new [Family] instance with data from the JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed or missing required fields.
  ///
  /// Throws [ArgumentError] if field values are invalid (e.g., malformed timestamps, invalid settings).
  factory Family.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and extract required fields
      final String? id = json['id'] as String?;
      if (id == null || id.isEmpty) {
        throw ArgumentError('Missing or empty required field: id');
      }

      final String? name = json['name'] as String?;
      if (name == null || name.isEmpty) {
        throw ArgumentError('Missing or empty required field: name');
      }

      final String? primaryUserId = json['primaryUserId'] as String?;
      if (primaryUserId == null || primaryUserId.isEmpty) {
        throw ArgumentError('Missing or empty required field: primaryUserId');
      }

      final Map<String, dynamic>? settingsJson = json['settings'] as Map<String, dynamic>?;
      if (settingsJson == null) {
        throw ArgumentError('Missing required field: settings');
      }

      final String? createdAtString = json['createdAt'] as String?;
      if (createdAtString == null || createdAtString.isEmpty) {
        throw ArgumentError('Missing or empty required field: createdAt');
      }

      // Parse nested objects
      final FamilySettings settings = FamilySettings.fromJson(settingsJson);

      // Parse timestamps
      final DateTime createdAt = DateTime.parse(createdAtString);

      final String? updatedAtString = json['updatedAt'] as String?;
      final DateTime? updatedAt =
          updatedAtString != null && updatedAtString.isNotEmpty ? DateTime.parse(updatedAtString) : null;

      return Family(
        id: id,
        name: name,
        primaryUserId: primaryUserId,
        settings: settings,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      throw FormatException('Failed to parse Family from JSON: $e');
    }
  }

  /// Converts this Family instance to a JSON map.
  ///
  /// This method is used for serializing family data for API requests, database storage, and other JSON-based
  /// operations.
  ///
  /// Returns a [Map<String, dynamic>] containing all family properties with appropriate JSON-compatible types.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'primaryUserId': primaryUserId,
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this Family with the specified fields updated.
  ///
  /// This method returns a new Family instance with the same values as the current instance, except for the fields
  /// explicitly provided as parameters. This is useful for updating family properties while maintaining immutability.
  ///
  /// Parameters:
  /// * [name] - New family name (optional)
  /// * [primaryUserId] - New primary user ID (optional)
  /// * [settings] - New family settings (optional)
  /// * [updatedAt] - New update timestamp (optional)
  ///
  /// Returns a new [Family] instance with updated values.
  ///
  /// Note: The [id] and [createdAt] fields cannot be changed as they are immutable identifiers.
  Family copyWith({
    String? name,
    String? primaryUserId,
    FamilySettings? settings,
    DateTime? updatedAt,
  }) {
    return Family(
      id: id,
      name: name ?? this.name,
      primaryUserId: primaryUserId ?? this.primaryUserId,
      settings: settings ?? this.settings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Family &&
        other.id == id &&
        other.name == name &&
        other.primaryUserId == primaryUserId &&
        other.settings == settings &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      primaryUserId,
      settings,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'Family('
        'id: $id, '
        'name: $name, '
        'primaryUserId: $primaryUserId, '
        'settings: $settings, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
