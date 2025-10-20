import '../exceptions/conflict_exception.dart';
import '../exceptions/service_exception.dart';
import '../models/user.dart';

/// Repository interface for user data operations.
///
/// This interface defines the contract for user data persistence operations. Implementations should handle all
/// database-specific logic while maintaining a clean, database-agnostic public interface.
///
/// The repository pattern provides abstraction over data storage, enabling easier testing and potential database
/// migrations in the future.
abstract interface class UserRepository {
  /// Creates a new user in the data store.
  ///
  /// Parameters:
  /// * [user] - The user instance to create
  ///
  /// Returns the created user with any generated fields populated.
  ///
  /// Throws [ConflictException] if a user with the same ID already exists. Throws [ServiceException] if the creation
  /// operation fails.
  Future<User> create(User user);

  /// Retrieves a user by their unique identifier.
  ///
  /// Parameters:
  /// * [id] - The unique user identifier
  ///
  /// Returns the user if found, null otherwise.
  ///
  /// Throws [ServiceException] if the retrieval operation fails.
  Future<User?> findById(String id);

  /// Retrieves all users belonging to a specific family.
  ///
  /// Parameters:
  /// * [familyId] - The family identifier
  /// * [limit] - Maximum number of users to return (optional)
  /// * [offset] - Number of users to skip for pagination (optional)
  ///
  /// Returns a list of users in the specified family.
  ///
  /// Throws [ServiceException] if the retrieval operation fails.
  Future<List<User>> findByFamilyId(String familyId, {int? limit, int? offset});

  /// Updates an existing user in the data store.
  ///
  /// Parameters:
  /// * [user] - The user instance with updated values
  ///
  /// Returns the updated user.
  ///
  /// Throws [ServiceException] if the user doesn't exist or the update fails.
  Future<User> update(User user);

  /// Deletes a user from the data store.
  ///
  /// Parameters:
  /// * [id] - The unique user identifier
  ///
  /// Throws [ServiceException] if the user doesn't exist or the deletion fails.
  Future<void> delete(String id);

  /// Checks if a user exists with the specified ID.
  ///
  /// Parameters:
  /// * [id] - The unique user identifier
  ///
  /// Returns true if the user exists, false otherwise.
  ///
  /// Throws [ServiceException] if the check operation fails.
  Future<bool> exists(String id);
}
