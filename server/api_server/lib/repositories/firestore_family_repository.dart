import 'package:logging/logging.dart';
import 'package:staccato_api_server/exceptions/conflict_exception.dart';
import 'package:staccato_api_server/exceptions/service_exception.dart';
import 'package:staccato_api_server/models/family.dart';
import 'package:staccato_api_server/repositories/family_repository.dart';
import 'package:staccato_api_server/services/firestore_client.dart';

/// Firestore implementation of the family repository.
///
/// This repository handles all family data operations using Google Cloud Firestore as the backend storage. It
/// implements the FamilyRepository interface and provides concrete methods for family CRUD operations.
///
/// The repository handles:
/// - Document creation and validation
/// - Data type conversion between Dart objects and Firestore documents
/// - Error handling and logging
/// - Query optimization and pagination
class FirestoreFamilyRepository implements FamilyRepository {
  /// Creates a new Firestore family repository with the specified client.
  ///
  /// Parameters:
  /// * [firestoreClient] - Configured Firestore client for database operations
  const FirestoreFamilyRepository(this._firestoreClient);

  /// Firestore client for database operations.
  final FirestoreClient _firestoreClient;

  /// Logger instance for this repository.
  static final Logger _logger = Logger('FirestoreFamilyRepository');

  /// Collection name for family documents in Firestore.
  static const String _collectionName = 'families';

  @override
  Future<Family> create(Family family) async {
    try {
      _logger.info('Creating family in Firestore', {
        'familyId': family.id,
        'name': family.name,
        'primaryUserId': family.primaryUserId,
      });

      // Check if family already exists
      final bool exists = await _firestoreClient.documentExists(_collectionName, family.id);
      if (exists) {
        throw ConflictException('Family with ID ${family.id} already exists');
      }

      // Create the document
      final Map<String, dynamic> createdDocument = await _firestoreClient.createDocument(
        _collectionName,
        family.toJson(),
        documentId: family.id,
      );

      final Family createdFamily = Family.fromJson(createdDocument);

      _logger.info('Family created successfully in Firestore', {
        'familyId': createdFamily.id,
        'name': createdFamily.name,
      });

      return createdFamily;
    } catch (e) {
      _logger.severe('Failed to create family in Firestore', {
        'familyId': family.id,
        'error': e.toString(),
      });

      if (e is ConflictException) {
        rethrow;
      }

      throw ServiceException('Failed to create family: $e', cause: e);
    }
  }

  @override
  Future<Family?> findById(String id) async {
    try {
      _logger.fine('Finding family by ID in Firestore', {'familyId': id});

      final Map<String, dynamic>? document = await _firestoreClient.getDocument(_collectionName, id);

      if (document == null) {
        _logger.fine('Family not found in Firestore', {'familyId': id});
        return null;
      }

      final Family family = Family.fromJson(document);

      _logger.fine('Family found in Firestore', {
        'familyId': family.id,
        'name': family.name,
      });

      return family;
    } catch (e) {
      _logger.severe('Failed to find family by ID in Firestore', {
        'familyId': id,
        'error': e.toString(),
      });
      throw ServiceException('Failed to find family: $e', cause: e);
    }
  }

  @override
  Future<List<Family>> findByPrimaryUserId(String primaryUserId, {int? limit, int? offset}) async {
    try {
      _logger.fine('Finding families by primary user ID in Firestore', {
        'primaryUserId': primaryUserId,
        'limit': limit,
        'offset': offset,
      });

      final List<Map<String, dynamic>> documents = await _firestoreClient.queryDocuments(
        _collectionName,
        where: <String, dynamic>{'primaryUserId': primaryUserId},
        limit: limit,
        offset: offset,
      );

      final List<Family> families = documents.map((Map<String, dynamic> doc) => Family.fromJson(doc)).toList();

      _logger.fine('Families found by primary user ID in Firestore', {
        'primaryUserId': primaryUserId,
        'count': families.length,
      });

      return families;
    } catch (e) {
      _logger.severe('Failed to find families by primary user ID in Firestore', {
        'primaryUserId': primaryUserId,
        'error': e.toString(),
      });
      throw ServiceException('Failed to find families: $e', cause: e);
    }
  }

  @override
  Future<Family> update(Family family) async {
    try {
      _logger.info('Updating family in Firestore', {
        'familyId': family.id,
        'name': family.name,
      });

      // Check if family exists
      final bool exists = await _firestoreClient.documentExists(_collectionName, family.id);
      if (!exists) {
        throw ServiceException('Family with ID ${family.id} does not exist');
      }

      // Update the document
      final Map<String, dynamic> updatedDocument = await _firestoreClient.updateDocument(
        _collectionName,
        family.id,
        family.toJson(),
      );

      final Family updatedFamily = Family.fromJson(updatedDocument);

      _logger.info('Family updated successfully in Firestore', {
        'familyId': updatedFamily.id,
        'name': updatedFamily.name,
      });

      return updatedFamily;
    } catch (e) {
      _logger.severe('Failed to update family in Firestore', {
        'familyId': family.id,
        'error': e.toString(),
      });
      throw ServiceException('Failed to update family: $e', cause: e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      _logger.info('Deleting family from Firestore', {'familyId': id});

      // Check if family exists
      final bool exists = await _firestoreClient.documentExists(_collectionName, id);
      if (!exists) {
        throw ServiceException('Family with ID $id does not exist');
      }

      // Delete the document
      await _firestoreClient.deleteDocument(_collectionName, id);

      _logger.info('Family deleted successfully from Firestore', {'familyId': id});
    } catch (e) {
      _logger.severe('Failed to delete family from Firestore', {
        'familyId': id,
        'error': e.toString(),
      });
      throw ServiceException('Failed to delete family: $e', cause: e);
    }
  }

  @override
  Future<bool> exists(String id) async {
    try {
      _logger.fine('Checking if family exists in Firestore', {'familyId': id});

      final bool exists = await _firestoreClient.documentExists(_collectionName, id);

      _logger.fine('Family existence check completed', {
        'familyId': id,
        'exists': exists,
      });

      return exists;
    } catch (e) {
      _logger.severe('Failed to check family existence in Firestore', {
        'familyId': id,
        'error': e.toString(),
      });
      throw ServiceException('Failed to check family existence: $e', cause: e);
    }
  }
}
