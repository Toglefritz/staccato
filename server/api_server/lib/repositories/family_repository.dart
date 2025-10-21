import 'package:staccato_api_server/exceptions/conflict_exception.dart';
import 'package:staccato_api_server/exceptions/service_exception.dart';
import 'package:staccato_api_server/models/family.dart';

/// Repository interface for family data operations.
///
/// This interface defines the contract for family data persistence operations. Implementations should handle all
/// database-specific logic while maintaining a clean, database-agnostic public interface.
///
/// The repository pattern provides abstraction over data storage, enabling easier testing and potential database
/// migrations in the future.
abstract interface class FamilyRepository {
  /// Creates a new family in the data store.
  ///
  /// Parameters:
  /// * [family] - The family instance to create
  ///
  /// Returns the created family with any generated fields populated.
  ///
  /// Throws [ConflictException] if a family with the same ID already exists.
  /// Throws [ServiceException] if the creation operation fails.
  Future<Family> create(Family family);

  /// Retrieves a family by its unique identifier.
  ///
  /// Parameters:
  /// * [id] - The unique family identifier
  ///
  /// Returns the family if found, null otherwise.
  ///
  /// Throws [ServiceException] if the retrieval operation fails.
  Future<Family?> findById(String id);

  /// Retrieves all families where the specified user is the primary administrator.
  ///
  /// Parameters:
  /// * [primaryUserId] - The primary user identifier
  /// * [limit] - Maximum number of families to return (optional)
  /// * [offset] - Number of families to skip for pagination (optional)
  ///
  /// Returns a list of families administered by the specified user.
  ///
  /// Throws [ServiceException] if the retrieval operation fails.
  Future<List<Family>> findByPrimaryUserId(String primaryUserId, {int? limit, int? offset});

  /// Updates an existing family in the data store.
  ///
  /// Parameters:
  /// * [family] - The family instance with updated values
  ///
  /// Returns the updated family.
  ///
  /// Throws [ServiceException] if the family doesn't exist or the update fails.
  Future<Family> update(Family family);

  /// Deletes a family from the data store.
  ///
  /// Parameters:
  /// * [id] - The unique family identifier
  ///
  /// Throws [ServiceException] if the family doesn't exist or the deletion fails.
  Future<void> delete(String id);

  /// Checks if a family exists with the specified ID.
  ///
  /// Parameters:
  /// * [id] - The unique family identifier
  ///
  /// Returns true if the family exists, false otherwise.
  ///
  /// Throws [ServiceException] if the check operation fails.
  Future<bool> exists(String id);
}
