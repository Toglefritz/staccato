import 'package:meta/meta.dart';
import 'package:staccato_api_server/models/family.dart';

/// Request data for creating a new family group.
///
/// This model contains all the information needed to create a new family group, including the family name and optional
/// initial settings. The requesting user automatically becomes the primary administrator of the new family.
///
/// The [FamilyCreateRequest] is used in API endpoints for family creation and validates that all required information
/// is provided before processing.
@immutable
class FamilyCreateRequest {
  /// Creates a new [FamilyCreateRequest] instance with the specified properties.
  ///
  /// The [name] parameter is required and represents the display name for the new family group. The [settings]
  /// parameter is optional and allows customization of the initial family configuration.
  const FamilyCreateRequest({
    required this.name,
    this.settings,
  });

  /// Display name for the new family group.
  ///
  /// This is the human-readable name that will be shown throughout the application, such as "The Smith Family" or
  /// "Johnson Household". The name should be descriptive and help family members identify their group.
  ///
  /// Constraints:
  /// - Must be between 1 and 100 characters
  /// - Cannot be empty or contain only whitespace
  /// - Should be appropriate for display in UI components
  final String name;

  /// Optional initial settings for the new family group.
  ///
  /// If provided, these settings will be used to configure the family group upon creation. If not provided, default
  /// settings will be applied. This allows families to customize their configuration during the creation process.
  final FamilySettings? settings;

  /// Creates a FamilyCreateRequest instance from a JSON map.
  ///
  /// This factory constructor is used for deserializing request data from API calls and other JSON sources.
  ///
  /// Parameters:
  /// * [json] - Map containing family creation request data with string keys
  ///
  /// Returns a new [FamilyCreateRequest] instance with data from the JSON map.
  ///
  /// Throws [FormatException] if the JSON is malformed or missing required fields.
  ///
  /// Throws [ArgumentError] if field values are invalid (e.g., empty name, invalid settings).
  factory FamilyCreateRequest.fromJson(Map<String, dynamic> json) {
    try {
      // Validate and extract required fields
      final String? name = json['name'] as String?;
      if (name == null || name.trim().isEmpty) {
        throw ArgumentError('Missing or empty required field: name');
      }

      // Validate name constraints
      final String trimmedName = name.trim();
      if (trimmedName.length > 100) {
        throw ArgumentError('Family name cannot exceed 100 characters');
      }

      // Extract optional settings
      final Map<String, dynamic>? settingsJson = json['settings'] as Map<String, dynamic>?;
      final FamilySettings? settings = settingsJson != null ? FamilySettings.fromJson(settingsJson) : null;

      return FamilyCreateRequest(
        name: trimmedName,
        settings: settings,
      );
    } catch (e) {
      throw FormatException('Failed to parse FamilyCreateRequest from JSON: $e');
    }
  }

  /// Converts this FamilyCreateRequest instance to a JSON map.
  ///
  /// This method is used for serializing request data for API calls, logging, and other JSON-based operations.
  ///
  /// Returns a [Map<String, dynamic>] containing all request properties with appropriate JSON-compatible types.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'settings': settings?.toJson(),
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
  /// - Name must not be empty or contain only whitespace
  /// - Name must not exceed 100 characters
  /// - Settings (if provided) must be valid
  List<String> validate() {
    final List<String> errors = <String>[];

    // Validate name
    if (name.trim().isEmpty) {
      errors.add('Family name cannot be empty');
    } else if (name.trim().length > 100) {
      errors.add('Family name cannot exceed 100 characters');
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FamilyCreateRequest && other.name == name && other.settings == settings;
  }

  @override
  int get hashCode {
    return Object.hash(name, settings);
  }

  @override
  String toString() {
    return 'FamilyCreateRequest('
        'name: $name, '
        'settings: $settings'
        ')';
  }
}
