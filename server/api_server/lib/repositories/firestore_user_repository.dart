import 'package:logging/logging.dart';

import '../exceptions/conflict_exception.dart';
import '../exceptions/service_exception.dart';
import '../models/user.dart';
import '../services/firestore_client.dart';
import 'user_repository.dart';

/// Firestore implementation of the user repository.
///
/// This repository handles all user data operations using Google Cloud Firestore as the backend storage. It provides
/// CRUD operations while handling Firestore-specific concerns like document references, transactions, and error
/// handling.
///
/// The repository uses the 'users' collection in Firestore, with each user document identified by the user's ID.
class FirestoreUserRepository implements UserRepository {
  /// Creates a new Firestore user repository with the specified Firestore client.
  ///
  /// Parameters:
  /// * [_firestoreClient] - The Firestore client instance to use for database operations
  const FirestoreUserRepository(this._firestoreClient);

  /// Firestore client instance used for database operations.
  final FirestoreClient _firestoreClient;

  /// Logger instance for this repository.
  static final Logger _logger = Logger('FirestoreUserRepository');

  /// Name of the Firestore collection containing user documents.
  static const String _collectionName = 'users';

  @override
  Future<User> create(User user) async {
    try {
      _logger.info('Creating user', {
        'userId': user.id,
        'familyId': user.familyId,
        'permissionLevel': user.permissionLevel.value,
      });

      // Check if user already exists
      final bool exists =
          await _firestoreClient.documentExists(_collectionName, user.id);
      if (exists) {
        throw ConflictException('User with ID ${user.id} already exists');
      }

      // Create the user document
      final Map<String, dynamic> userData = user.toJson();
      await _firestoreClient.createDocument(
        _collectionName,
        userData,
        documentId: user.id,
      );

      _logger.info('User created successfully', {
        'userId': user.id,
        'familyId': user.familyId,
      });

      return user;
    } on ConflictException {
      rethrow;
    } catch (e) {
      _logger.severe('Failed to create user', {
        'userId': user.id,
        'error': e.toString(),
      });
      throw ServiceException('Failed to create user: $e', cause: e);
    }
  }

  @override
  Future<User?> findById(String id) async {
    try {
      _logger.fine('Finding user by ID', {'userId': id});

      final Map<String, dynamic>? data =
          await _firestoreClient.getDocument(_collectionName, id);

      if (data == null) {
        _logger.fine('User not found', {'userId': id});
        return null;
      }

      final User user = User.fromJson(data);
      _logger.fine('User found successfully', {'userId': id});
      return user;
    } catch (e) {
      _logger.severe('Failed to find user by ID', {
        'userId': id,
        'error': e.toString(),
      });
      throw ServiceException('Failed to find user: $e', cause: e);
    }
  }

  @override
  Future<List<User>> findByFamilyId(
    String familyId, {
    int? limit,
    int? offset,
  }) async {
    try {
      _logger.fine('Finding users by family ID', {
        'familyId': familyId,
        'limit': limit,
        'offset': offset,
      });

      final List<Map<String, dynamic>> documents =
          await _firestoreClient.queryDocuments(
        _collectionName,
        where: <String, dynamic>{'familyId': familyId},
        limit: limit,
        offset: offset,
      );

      final List<User> users = documents.map(User.fromJson).toList();

      _logger.fine('Found users by family ID', {
        'familyId': familyId,
        'userCount': users.length,
      });

      return users;
    } catch (e) {
      _logger.severe('Failed to find users by family ID', {
        'familyId': familyId,
        'error': e.toString(),
      });
      throw ServiceException('Failed to find users by family ID: $e', cause: e);
    }
  }

  @override
  Future<User> update(User user) async {
    try {
      _logger.info('Updating user', {
        'userId': user.id,
        'familyId': user.familyId,
      });

      // Check if user exists
      final bool exists =
          await _firestoreClient.documentExists(_collectionName, user.id);
      if (!exists) {
        throw ServiceException('User with ID ${user.id} does not exist');
      }

      // Update the user document
      final Map<String, dynamic> userData = user.toJson();
      await _firestoreClient.updateDocument(_collectionName, user.id, userData);

      _logger.info('User updated successfully', {
        'userId': user.id,
        'familyId': user.familyId,
      });

      return user;
    } catch (e) {
      _logger.severe('Failed to update user', {
        'userId': user.id,
        'error': e.toString(),
      });
      throw ServiceException('Failed to update user: $e', cause: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      _logger.info('Deleting user', {'userId': id});

      // Check if user exists
      final bool exists =
          await _firestoreClient.documentExists(_collectionName, id);
      if (!exists) {
        throw ServiceException('User with ID $id does not exist');
      }

      // Delete the user document
      await _firestoreClient.deleteDocument(_collectionName, id);

      _logger.info('User deleted successfully', {'userId': id});
    } catch (e) {
      _logger.severe('Failed to delete user', {
        'userId': id,
        'error': e.toString(),
      });
      throw ServiceException('Failed to delete user: $e', cause: e);
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      _logger.fine('Checking if user exists', {'userId': id});

      final bool userExists =
          await _firestoreClient.documentExists(_collectionName, id);

      _logger.fine('User existence check completed', {
        'userId': id,
        'exists': userExists,
      });

      return userExists;
    } catch (e) {
      _logger.severe('Failed to check user existence', {
        'userId': id,
        'error': e.toString(),
      });
      throw ServiceException('Failed to check user existence: $e', cause: e);
    }
  }
}
