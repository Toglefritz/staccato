import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:staccato_api_server/exceptions/service_exception.dart'
    show ServiceException;
import 'package:uuid/uuid.dart';

import '../exceptions/validation_exception.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

/// Service for managing user operations and business logic.
///
/// This service handles all user-related business logic including validation, user creation, and coordination between
/// different system components. It serves as the primary interface between the presentation layer and data persistence.
///
/// The service is stateless and uses dependency injection for repositories and external services.
class UserService {
  /// Creates a new user service with the specified dependencies.
  ///
  /// Parameters:
  /// * [userRepository] - Repository for user data operations
  const UserService({
    required UserRepository userRepository,
  }) : _userRepository = userRepository;

  /// Repository for user data persistence operations.
  final UserRepository _userRepository;

  /// Logger instance for this service.
  static final Logger _logger = Logger('UserService');

  /// UUID generator for creating unique user identifiers.
  static const Uuid _uuid = Uuid();

  /// Creates a new user from the provided request data.
  ///
  /// This method handles the complete user creation workflow:
  /// 1. Validates the user request data
  /// 2. Generates a unique user ID
  /// 3. Creates the user record in the repository
  /// 4. Returns the created user
  ///
  /// Parameters:
  /// * [request] - User creation request containing user data
  ///
  /// Returns the created [User] instance.
  ///
  /// Throws [ValidationException] when the request data is invalid or incomplete. Throws [ServiceException] when the
  /// creation operation fails.
  Future<User> createUser(UserCreateRequest request) async {
    _logger.info('Creating new user', {
      'displayName': request.displayName,
      'familyId': request.familyId,
      'permissionLevel': request.permissionLevel.value,
    });

    // Validate the request
    _validateUserCreateRequest(request);

    // Generate unique user ID
    final String userId = _uuid.v4();
    final DateTime now = DateTime.now();

    // Create user instance
    final User user = User(
      id: userId,
      displayName: request.displayName,
      familyId: request.familyId,
      permissionLevel: request.permissionLevel,
      createdAt: now,
      updatedAt: now,
      profileImageUrl: request.profileImageUrl,
    );

    try {
      // Create user in repository
      final User createdUser = await _userRepository.create(user);

      _logger.info('User created successfully', {
        'userId': createdUser.id,
        'displayName': createdUser.displayName,
        'familyId': createdUser.familyId,
      });

      return createdUser;
    } catch (e) {
      _logger.severe('Failed to create user', {
        'displayName': request.displayName,
        'familyId': request.familyId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Retrieves a user by their unique identifier.
  ///
  /// Parameters:
  /// * [id] - The unique user identifier
  ///
  /// Returns the user if found, null otherwise.
  ///
  /// Throws [ServiceException] if the retrieval operation fails.
  Future<User?> getUserById(String id) async {
    _logger.fine('Retrieving user by ID', {'userId': id});

    if (id.isEmpty) {
      throw ValidationException.missingField('id');
    }

    return _userRepository.findById(id);
  }

  /// Retrieves all users belonging to a specific family.
  ///
  /// Parameters:
  /// * [familyId] - The family identifier
  /// * [limit] - Maximum number of users to return (optional)
  /// * [offset] - Number of users to skip for pagination (optional)
  ///
  /// Returns a list of users in the specified family.
  ///
  /// Throws [ValidationException] if the family ID is invalid. Throws [ServiceException] if the retrieval operation
  /// fails.
  Future<List<User>> getUsersByFamilyId(
    String familyId, {
    int? limit,
    int? offset,
  }) async {
    _logger.fine('Retrieving users by family ID', {
      'familyId': familyId,
      'limit': limit,
      'offset': offset,
    });

    if (familyId.isEmpty) {
      throw ValidationException.missingField('familyId');
    }

    return _userRepository.findByFamilyId(
      familyId,
      limit: limit,
      offset: offset,
    );
  }

  /// Validates a user creation request.
  ///
  /// This method performs comprehensive validation of user creation data including:
  /// - Required field presence
  /// - Field format validation
  /// - Business rule validation
  ///
  /// Parameters:
  /// * [request] - The user creation request to validate
  ///
  /// Throws [ValidationException] if any validation rules are violated.
  void _validateUserCreateRequest(UserCreateRequest request) {
    // Validate display name
    if (request.displayName.isEmpty) {
      throw ValidationException.missingField('displayName');
    }

    if (request.displayName.length > 100) {
      throw ValidationException(
        'Display name must be 100 characters or less.',
        field: 'displayName',
        code: 'VALIDATION_FIELD_TOO_LONG',
      );
    }

    // Validate family ID
    if (request.familyId.isEmpty) {
      throw ValidationException.missingField('familyId');
    }

    // Validate profile image URL format if provided
    if (request.profileImageUrl != null &&
        request.profileImageUrl!.isNotEmpty) {
      final Uri? uri = Uri.tryParse(request.profileImageUrl!);
      if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        throw ValidationException.invalidFormat(
          'profileImageUrl',
          'valid HTTP or HTTPS URL',
        );
      }
    }
  }
}

/// Request model for creating a new user.
///
/// This class represents the data required to create a new user in the system. It contains all necessary information
/// for user creation while excluding system-generated fields like ID and timestamps.
@immutable
class UserCreateRequest {
  /// Creates a new user creation request with the specified data.
  ///
  /// Parameters:
  /// * [displayName] - User's display name
  /// * [familyId] - ID of the family this user belongs to
  /// * [permissionLevel] - Permission level for the user
  /// * [profileImageUrl] - Optional URL to the user's profile image
  const UserCreateRequest({
    required this.displayName,
    required this.familyId,
    required this.permissionLevel,
    this.profileImageUrl,
  });

  /// User's display name shown throughout the application.
  final String displayName;

  /// ID of the family group this user belongs to.
  final String familyId;

  /// Permission level determining the user's access rights.
  final UserPermissionLevel permissionLevel;

  /// Optional URL to the user's profile image.
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
  /// Throws [FormatException] if the JSON is malformed or missing required fields. Throws [ArgumentError] if field
  /// values are invalid.
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

  /// Converts this request to a JSON map.
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserCreateRequest &&
        other.displayName == displayName &&
        other.familyId == familyId &&
        other.permissionLevel == permissionLevel &&
        other.profileImageUrl == profileImageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      displayName,
      familyId,
      permissionLevel,
      profileImageUrl,
    );
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
