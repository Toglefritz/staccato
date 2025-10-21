import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:staccato_api_server/exceptions/service_exception.dart';
import 'package:staccato_api_server/exceptions/validation_exception.dart';
import 'package:staccato_api_server/models/family.dart';
import 'package:staccato_api_server/models/family_create_request.dart';
import 'package:staccato_api_server/models/family_update_request.dart';
import 'package:staccato_api_server/models/user.dart';
import 'package:staccato_api_server/repositories/family_repository.dart';
import 'package:staccato_api_server/repositories/user_repository.dart';
import 'package:staccato_api_server/services/family_service.dart';

/// Mock implementations for testing.
class MockFamilyRepository extends Mock implements FamilyRepository {}

class MockUserRepository extends Mock implements UserRepository {}

/// Fake implementations for fallback values.
class FakeFamily extends Fake implements Family {}

class FakeUser extends Fake implements User {}

/// Test suite for FamilyService functionality.
void main() {
  /// Register fallback values for mocktail.
  setUpAll(() {
    registerFallbackValue(FakeFamily());
    registerFallbackValue(FakeUser());
  });

  group('FamilyService', () {
    late FamilyService service;
    late MockFamilyRepository mockFamilyRepository;
    late MockUserRepository mockUserRepository;

    setUp(() {
      mockFamilyRepository = MockFamilyRepository();
      mockUserRepository = MockUserRepository();

      service = FamilyService(
        familyRepository: mockFamilyRepository,
        userRepository: mockUserRepository,
      );
    });

    group('createFamily', () {
      test('should create family successfully with valid request', () async {
        // Arrange
        const FamilyCreateRequest request = FamilyCreateRequest(
          name: 'Test Family',
        );
        const String primaryUserId = 'user_123';

        final Family expectedFamily = Family(
          id: 'family_456',
          name: 'Test Family',
          primaryUserId: primaryUserId,
          settings: const FamilySettings(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(() => mockFamilyRepository.create(any())).thenAnswer((_) async => expectedFamily);

        // Act
        final Family result = await service.createFamily(request, primaryUserId);

        // Assert
        expect(result.name, equals('Test Family'));
        expect(result.primaryUserId, equals(primaryUserId));
        expect(result.id, isNotEmpty);

        verify(() => mockFamilyRepository.create(any())).called(1);
      });

      test('should throw ValidationException for empty family name', () async {
        // Arrange
        const FamilyCreateRequest request = FamilyCreateRequest(
          name: '',
        );
        const String primaryUserId = 'user_123';

        // Act & Assert
        expect(
          () => service.createFamily(request, primaryUserId),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException for empty primary user ID', () async {
        // Arrange
        const FamilyCreateRequest request = FamilyCreateRequest(
          name: 'Test Family',
        );
        const String primaryUserId = '';

        // Act & Assert
        expect(
          () => service.createFamily(request, primaryUserId),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('getFamilyById', () {
      test('should return family when found', () async {
        // Arrange
        const String familyId = 'family_123';
        final Family expectedFamily = Family(
          id: familyId,
          name: 'Test Family',
          primaryUserId: 'user_456',
          settings: const FamilySettings(),
          createdAt: DateTime.now(),
        );

        when(() => mockFamilyRepository.findById(any())).thenAnswer((_) async => expectedFamily);

        // Act
        final Family? result = await service.getFamilyById(familyId);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(familyId));
        expect(result.name, equals('Test Family'));
      });

      test('should return null when family not found', () async {
        // Arrange
        const String familyId = 'nonexistent_family';

        when(() => mockFamilyRepository.findById(any())).thenAnswer((_) async => null);

        // Act
        final Family? result = await service.getFamilyById(familyId);

        // Assert
        expect(result, isNull);
      });

      test('should throw ValidationException for empty family ID', () async {
        // Act & Assert
        expect(
          () => service.getFamilyById(''),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('updateFamily', () {
      test('should update family successfully with valid request', () async {
        // Arrange
        const String familyId = 'family_123';
        final Family existingFamily = Family(
          id: familyId,
          name: 'Old Name',
          primaryUserId: 'user_456',
          settings: const FamilySettings(),
          createdAt: DateTime.now(),
        );

        const FamilyUpdateRequest request = FamilyUpdateRequest(
          name: 'New Name',
        );

        final Family updatedFamily = existingFamily.copyWith(
          name: 'New Name',
          updatedAt: DateTime.now(),
        );

        when(() => mockFamilyRepository.findById(any())).thenAnswer((_) async => existingFamily);
        when(() => mockFamilyRepository.update(any())).thenAnswer((_) async => updatedFamily);

        // Act
        final Family result = await service.updateFamily(familyId, request);

        // Assert
        expect(result.name, equals('New Name'));
        expect(result.id, equals(familyId));
      });

      test('should throw ServiceException when family not found', () async {
        // Arrange
        const String familyId = 'nonexistent_family';
        const FamilyUpdateRequest request = FamilyUpdateRequest(
          name: 'New Name',
        );

        when(() => mockFamilyRepository.findById(any())).thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => service.updateFamily(familyId, request),
          throwsA(isA<ServiceException>()),
        );
      });
    });

    group('deleteFamily', () {
      test('should delete family successfully when user is primary administrator', () async {
        // Arrange
        const String familyId = 'family_123';
        const String primaryUserId = 'user_456';
        final Family family = Family(
          id: familyId,
          name: 'Test Family',
          primaryUserId: primaryUserId,
          settings: const FamilySettings(),
          createdAt: DateTime.now(),
        );

        when(() => mockFamilyRepository.findById(any())).thenAnswer((_) async => family);
        when(() => mockFamilyRepository.delete(any())).thenAnswer((_) async {});

        // Act
        await service.deleteFamily(familyId, primaryUserId);

        // Assert - no exception thrown
        verify(() => mockFamilyRepository.delete(familyId)).called(1);
      });

      test('should throw ServiceException when user is not primary administrator', () async {
        // Arrange
        const String familyId = 'family_123';
        const String primaryUserId = 'user_456';
        const String requestingUserId = 'user_789';
        final Family family = Family(
          id: familyId,
          name: 'Test Family',
          primaryUserId: primaryUserId,
          settings: const FamilySettings(),
          createdAt: DateTime.now(),
        );

        when(() => mockFamilyRepository.findById(any())).thenAnswer((_) async => family);

        // Act & Assert
        expect(
          () => service.deleteFamily(familyId, requestingUserId),
          throwsA(isA<ServiceException>()),
        );
      });
    });
  });
}
