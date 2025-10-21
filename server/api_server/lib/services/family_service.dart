import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import 'package:staccato_api_server/exceptions/service_exception.dart';
import 'package:staccato_api_server/exceptions/validation_exception.dart';
import 'package:staccato_api_server/models/family.dart';
import 'package:staccato_api_server/models/family_create_request.dart';
import 'package:staccato_api_server/models/family_member_summary.dart';
import 'package:staccato_api_server/models/family_update_request.dart';
import 'package:staccato_api_server/models/family_with_members_response.dart';
import 'package:staccato_api_server/models/user.dart';
import 'package:staccato_api_server/repositories/family_repository.dart';
import 'package:staccato_api_server/repositories/user_repository.dart';

/// Service for managing family operations and business logic.
///
/// This service handles all family-related business logic including validation, family creation, member management,
/// and coordination between different system components. It serves as the primary interface between the presentation
/// layer and data persistence.
///
/// The service is stateless and uses dependency injection for repositories and external services.
class FamilyService {
  /// Creates a new family service with the specified dependencies.
  ///
  /// Parameters:
  /// * [familyRepository] - Repository for family data operations
  /// * [userRepository] - Repository for user data operations
  const FamilyService({
    required FamilyRepository familyRepository,
    required UserRepository userRepository,
  })  : _familyRepository = familyRepository,
        _userRepository = userRepository;

  /// Repository for family data persistence operations.
  final FamilyRepository _familyRepository;

  /// Repository for user data persistence operations.
  final UserRepository _userRepository;

  /// Logger instance for this service.
  static final Logger _logger = Logger('FamilyService');

  /// UUID generator for creating unique family identifiers.
  static const Uuid _uuid = Uuid();

  /// Creates a new family from the provided request data.
  ///
  /// This method handles the complete family creation workflow:
  /// 1. Validates the family request data
  /// 2. Generates a unique family ID
  /// 3. Creates the family record in the repository
  /// 4. Returns the created family
  ///
  /// Parameters:
  /// * [request] - Family creation request containing family data
  /// * [primaryUserId] - ID of the user who will be the primary administrator
  ///
  /// Returns the created [Family] instance.
  ///
  /// Throws [ValidationException] when the request data is invalid or incomplete.
  /// Throws [ServiceException] when the creation operation fails.
  Future<Family> createFamily(FamilyCreateRequest request, String primaryUserId) async {
    _logger.info('Creating new family', {
      'name': request.name,
      'primaryUserId': primaryUserId,
    });

    // Validate the request
    _validateFamilyCreateRequest(request, primaryUserId);

    // Generate unique family ID
    final String familyId = _uuid.v4();
    final DateTime now = DateTime.now();

    // Create default settings if not provided
    final FamilySettings settings = request.settings ?? const FamilySettings();

    // Create family instance
    final Family family = Family(
      id: familyId,
      name: request.name,
      primaryUserId: primaryUserId,
      settings: settings,
      createdAt: now,
      updatedAt: now,
    );

    try {
      // Create family in repository
      final Family createdFamily = await _familyRepository.create(family);

      _logger.info('Family created successfully', {
        'familyId': createdFamily.id,
        'name': createdFamily.name,
        'primaryUserId': createdFamily.primaryUserId,
      });

      return createdFamily;
    } catch (e) {
      _logger.severe('Failed to create family', {
        'name': request.name,
        'primaryUserId': primaryUserId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Retrieves a family by its unique identifier.
  ///
  /// Parameters:
  /// * [id] - The unique family identifier
  ///
  /// Returns the family if found, null otherwise.
  ///
  /// Throws [ServiceException] if the retrieval operation fails.
  Future<Family?> getFamilyById(String id) async {
    _logger.fine('Retrieving family by ID', {'familyId': id});

    if (id.isEmpty) {
      throw ValidationException.missingField('id');
    }

    return _familyRepository.findById(id);
  }

  /// Retrieves a family with its members by family ID.
  ///
  /// This method combines family data with member information to provide a complete view of the family group.
  ///
  /// Parameters:
  /// * [familyId] - The unique family identifier
  ///
  /// Returns a [FamilyWithMembersResponse] containing family and member data, or null if family not found.
  ///
  /// Throws [ValidationException] if the family ID is invalid.
  /// Throws [ServiceException] if the retrieval operation fails.
  Future<FamilyWithMembersResponse?> getFamilyWithMembers(String familyId) async {
    _logger.fine('Retrieving family with members', {'familyId': familyId});

    if (familyId.isEmpty) {
      throw ValidationException.missingField('familyId');
    }

    try {
      // Get family data
      final Family? family = await _familyRepository.findById(familyId);
      if (family == null) {
        return null;
      }

      // Get family members
      final List<User> users = await _userRepository.findByFamilyId(familyId);

      // Convert users to member summaries
      final List<FamilyMemberSummary> members = users.map((User user) => FamilyMemberSummary.fromUser(user)).toList();

      final FamilyWithMembersResponse response = FamilyWithMembersResponse(
        family: family,
        members: members,
      );

      // Return sorted response for consistent ordering
      return response.withSortedMembers();
    } catch (e) {
      _logger.severe('Failed to retrieve family with members', {
        'familyId': familyId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Retrieves all families where the specified user is the primary administrator.
  ///
  /// Parameters:
  /// * [primaryUserId] - The primary user identifier
  /// * [limit] - Maximum number of families to return (optional)
  /// * [offset] - Number of families to skip for pagination (optional)
  ///
  /// Returns a list of families administered by the specified user.
  ///
  /// Throws [ValidationException] if the user ID is invalid.
  /// Throws [ServiceException] if the retrieval operation fails.
  Future<List<Family>> getFamiliesByPrimaryUserId(
    String primaryUserId, {
    int? limit,
    int? offset,
  }) async {
    _logger.fine('Retrieving families by primary user ID', {
      'primaryUserId': primaryUserId,
      'limit': limit,
      'offset': offset,
    });

    if (primaryUserId.isEmpty) {
      throw ValidationException.missingField('primaryUserId');
    }

    return _familyRepository.findByPrimaryUserId(
      primaryUserId,
      limit: limit,
      offset: offset,
    );
  }

  /// Updates an existing family with the provided data.
  ///
  /// This method handles partial updates where only specified fields are changed.
  ///
  /// Parameters:
  /// * [familyId] - The unique family identifier
  /// * [request] - Family update request containing the fields to update
  ///
  /// Returns the updated [Family] instance.
  ///
  /// Throws [ValidationException] when the request data is invalid.
  /// Throws [ServiceException] when the family doesn't exist or the update fails.
  Future<Family> updateFamily(String familyId, FamilyUpdateRequest request) async {
    _logger.info('Updating family', {
      'familyId': familyId,
      'hasNameUpdate': request.name != null,
      'hasSettingsUpdate': request.settings != null,
    });

    // Validate inputs
    if (familyId.isEmpty) {
      throw ValidationException.missingField('familyId');
    }

    _validateFamilyUpdateRequest(request);

    try {
      // Get current family
      final Family? currentFamily = await _familyRepository.findById(familyId);
      if (currentFamily == null) {
        throw ServiceException('Family with ID $familyId does not exist');
      }

      // Apply updates
      final Family updatedFamily = request.applyTo(currentFamily);

      // Save updated family
      final Family savedFamily = await _familyRepository.update(updatedFamily);

      _logger.info('Family updated successfully', {
        'familyId': savedFamily.id,
        'name': savedFamily.name,
      });

      return savedFamily;
    } catch (e) {
      _logger.severe('Failed to update family', {
        'familyId': familyId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Deletes a family and all associated data.
  ///
  /// This method handles the complete family deletion workflow including validation of permissions and cleanup of
  /// related data.
  ///
  /// Parameters:
  /// * [familyId] - The unique family identifier
  /// * [requestingUserId] - ID of the user requesting the deletion (must be primary administrator)
  ///
  /// Throws [ValidationException] when the inputs are invalid.
  /// Throws [ServiceException] when the family doesn't exist, user lacks permissions, or deletion fails.
  Future<void> deleteFamily(String familyId, String requestingUserId) async {
    _logger.info('Deleting family', {
      'familyId': familyId,
      'requestingUserId': requestingUserId,
    });

    // Validate inputs
    if (familyId.isEmpty) {
      throw ValidationException.missingField('familyId');
    }

    if (requestingUserId.isEmpty) {
      throw ValidationException.missingField('requestingUserId');
    }

    try {
      // Get current family
      final Family? family = await _familyRepository.findById(familyId);
      if (family == null) {
        throw ServiceException('Family with ID $familyId does not exist');
      }

      // Verify requesting user is the primary administrator
      if (family.primaryUserId != requestingUserId) {
        throw ServiceException('Only the primary administrator can delete the family');
      }

      // Delete the family
      await _familyRepository.delete(familyId);

      _logger.info('Family deleted successfully', {
        'familyId': familyId,
        'requestingUserId': requestingUserId,
      });
    } catch (e) {
      _logger.severe('Failed to delete family', {
        'familyId': familyId,
        'requestingUserId': requestingUserId,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Validates a family creation request.
  ///
  /// This method performs comprehensive validation of family creation data including:
  /// - Required field presence
  /// - Field format validation
  /// - Business rule validation
  ///
  /// Parameters:
  /// * [request] - The family creation request to validate
  /// * [primaryUserId] - The primary user ID to validate
  ///
  /// Throws [ValidationException] if any validation rules are violated.
  void _validateFamilyCreateRequest(FamilyCreateRequest request, String primaryUserId) {
    // Validate request using built-in validation
    final List<String> requestErrors = request.validate();
    if (requestErrors.isNotEmpty) {
      throw ValidationException(
        'Family creation request validation failed: ${requestErrors.join(', ')}',
        code: 'VALIDATION_FAILED',
      );
    }

    // Validate primary user ID
    if (primaryUserId.isEmpty) {
      throw ValidationException.missingField('primaryUserId');
    }
  }

  /// Validates a family update request.
  ///
  /// This method performs comprehensive validation of family update data including:
  /// - Required field presence for updates
  /// - Field format validation
  /// - Business rule validation
  ///
  /// Parameters:
  /// * [request] - The family update request to validate
  ///
  /// Throws [ValidationException] if any validation rules are violated.
  void _validateFamilyUpdateRequest(FamilyUpdateRequest request) {
    // Validate request using built-in validation
    final List<String> requestErrors = request.validate();
    if (requestErrors.isNotEmpty) {
      throw ValidationException(
        'Family update request validation failed: ${requestErrors.join(', ')}',
        code: 'VALIDATION_FAILED',
      );
    }
  }
}
