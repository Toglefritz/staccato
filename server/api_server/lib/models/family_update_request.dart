import 'package:meta/meta.dart';
import 'package:staccato_api_server/models/family.dart';

/// Request data for updating an existing family group.
///
/// This model contains the fields that can be updated for an existing family group. All fields are optional, allowing
/// for partial updates where only specific properties need to be changed.
///
/// The [FamilyUpdateRequest] is used in API endpoints for family modification and validates that any provided
/// information is valid before processing.
@immutable
class FamilyUpdateRequest {
  /// Creates a new [FamilyUpdateRequest] instance with the specified properties.
  ///
  /// All parameters are optional, allowing for partial updates. At least one field should be provided for the update to
  /// be meaningful.
  const FamilyUpdateRequest({
    this.name,
    this.settings,
  });

  /// New display name for the family group (optional).
  ///
  /// If provided, this will replace the current family name. The name should be descriptive and help family members
  /// identify their group.
  ///
  /// Constraints:
  /// - Must be between 1 and 100 characters if provided
  /// - Cannot be empty or contain only whitespace
  /// - Should be appropriate for display in UI components
  final String? name;

  /// New settings configuration for the family group (optional).
  ///
  /// If provided, these settings will replace the current family settings. This allows administrators to modify family
  /// configuration such as timezone, permissions, and feature toggles.
  final FamilySettings? settings;

  /// Whether this request contains any updates.
  ///
  /// Returns `true` if at least one field is provided for update, `false` if all fields are null. This helps identify
  /// empty update requests that should be rejected.
  bool get hasUpdates => name != null || settings != null;

  /// Creates a FamilyUpdateRequest instance from a JSON map.
  ///
  /// This factory constructor is used for deserializing request data from API calls and other JSON sources.
  ///
  /// Parameters:
  /// * [json] - Map containing family update request data with string keys
  ///
  /// Returns a new [FamilyUpdateRequest] instance with data from the JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed.
  ///
  /// Throws [ArgumentError] if field values are invalid (e.g., empty name, invalid settings).
  factory FamilyUpdateRequest.fromJson(Map<String, dynamic> json) {
    try {
      // Extract optional fields
      String? name;
      final String? nameValue = json['name'] as String?;
      if (nameValue != null) {
        final String trimmedName = nameValue.trim();
        if (trimmedName.isEmpty) {
          throw ArgumentError('Family name cannot be empty');
        }
        if (trimmedName.length > 100) {
          throw ArgumentError('Family name cannot exceed 100 characters');
        }
        name = trimmedName;
      }

      final Map<String, dynamic>? settingsJson = json['settings'] as Map<String, dynamic>?;
      final FamilySettings? settings = settingsJson != null ? FamilySettings.fromJson(settingsJson) : null;

      return FamilyUpdateRequest(
        name: name,
        settings: settings,
      );
    } catch (e) {
      throw FormatException('Failed to parse FamilyUpdateRequest from JSON: $e');
    }
  }

  /// Converts this FamilyUpdateRequest instance to a JSON map.
  ///
  /// This method is used for serializing request data for API calls, logging, and other JSON-based operations.
  ///
  /// Returns a [Map<String, dynamic>] containing all request properties with appropriate JSON-compatible types. Null
  /// values are excluded from the output.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};

    if (name != null) {
      json['name'] = name;
    }

    if (settings != null) {
      json['settings'] = settings!.toJson();
    }

    return json;
  }

  /// Validates this request and returns a list of validation errors.
  ///
  /// This method performs comprehensive validation of the request data and returns a list of error messages for any
  /// validation failures. An empty list indicates the request is valid.
  ///
  /// Returns a [List<String>] containing validation error messages, or an empty list if validation passes.
  ///
  /// Validation rules:
  /// - At least one field must be provided for update
  /// - Name (if provided) must not be empty or contain only whitespace
  /// - Name (if provided) must not exceed 100 characters
  /// - Settings (if provided) must be valid
  List<String> validate() {
    final List<String> errors = <String>[];

    // Check if any updates are provided
    if (!hasUpdates) {
      errors.add('At least one field must be provided for update');
      return errors;
    }

    // Validate name if provided
    if (name != null) {
      if (name!.trim().isEmpty) {
        errors.add('Family name cannot be empty');
      } else if (name!.trim().length > 100) {
        errors.add('Family name cannot exceed 100 characters');
      }
    }

    // Note: FamilySettings validation is handled in its own fromJson method
    // Additional business rule validations can be added here

    return errors;
  }

  /// Whether this request is valid and can be processed.
  ///
  /// Returns `true` if the request passes all validation rules, `false` otherwise. This is a convenience method that
  /// checks if the validate() method returns an empty list.
  bool get isValid => validate().isEmpty;

  /// Applies this update request to an existing family, returning a new family instance.
  ///
  /// This method creates a new Family instance with the current family's data updated with the values from this
  /// request. Only non-null fields from the request are applied.
  ///
  /// Parameters:
  /// * [currentFamily] - The existing family to update
  ///
  /// Returns a new [Family] instance with the updates applied and the updatedAt timestamp set to the current time.
  Family applyTo(Family currentFamily) {
    return currentFamily.copyWith(
      name: name ?? currentFamily.name,
      settings: settings ?? currentFamily.settings,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FamilyUpdateRequest && other.name == name && other.settings == settings;
  }

  @override
  int get hashCode {
    return Object.hash(name, settings);
  }

  @override
  String toString() {
    return 'FamilyUpdateRequest('
        'name: $name, '
        'settings: $settings'
        ')';
  }
}
