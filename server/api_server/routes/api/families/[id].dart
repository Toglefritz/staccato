// ignore_for_file: file_names
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import 'package:staccato_api_server/exceptions/service_exception.dart';
import 'package:staccato_api_server/exceptions/validation_exception.dart';
import 'package:staccato_api_server/models/family.dart';
import 'package:staccato_api_server/models/family_update_request.dart';
import 'package:staccato_api_server/models/family_with_members_response.dart';
import 'package:staccato_api_server/services/family_service.dart';

/// Route handler for individual family operations.
///
/// This handler manages HTTP requests for specific family operations including:
/// - GET /api/families/{id} - Retrieve a family by ID
/// - PUT /api/families/{id} - Update a family
/// - DELETE /api/families/{id} - Delete a family
///
/// All operations require authentication and proper authorization.
Future<Response> onRequest(RequestContext context, String id) async {
  switch (context.request.method) {
    case HttpMethod.get:
      return _getFamily(context, id);
    case HttpMethod.put:
      return _updateFamily(context, id);
    case HttpMethod.delete:
      return _deleteFamily(context, id);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/// Retrieves a family by its unique identifier.
///
/// This endpoint returns complete family information including member details. The response includes both family
/// metadata and a list of all family members with their summary information.
///
/// Path Parameters:
/// - id: The unique family identifier
///
/// Query Parameters:
/// - includeMembers: Whether to include member details (default: true)
///
/// Response (200 OK) with members:
/// ```json
/// {
/// "family": {
/// "id": "family_123",
/// "name": "The Smith Family",
/// "primaryUserId": "user_456",
/// "settings": { ... },
/// "createdAt": "2025-01-10T14:30:00Z",
/// "updatedAt": "2025-01-10T14:30:00Z"
/// },
/// "members": [
/// {
/// "id": "user_456",
/// "displayName": "John Smith",
/// "permissionLevel": "primary",
/// "profileImageUrl": "https://..."
/// }
/// ],
/// "memberCount": 1,
/// "isAtMemberLimit": false
/// }
/// ```
///
/// Response (200 OK) without members:
/// ```json
/// {
/// "id": "family_123",
/// "name": "The Smith Family",
/// "primaryUserId": "user_456",
/// "settings": { ... },
/// "createdAt": "2025-01-10T14:30:00Z",
/// "updatedAt": "2025-01-10T14:30:00Z"
/// }
/// ```
Future<Response> _getFamily(RequestContext context, String id) async {
  try {
    // Validate family ID
    if (id.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: <String, dynamic>{
          'error': 'Family ID is required',
        },
      );
    }

    // Get required services
    final FamilyService familyService = context.read<FamilyService>();

    // Check if members should be included
    final Uri uri = context.request.uri;
    final String? includeMembersParam = uri.queryParameters['includeMembers'];
    final bool includeMembers = includeMembersParam != 'false'; // Default to true

    if (includeMembers) {
      // Get family with members
      final FamilyWithMembersResponse? response = await familyService.getFamilyWithMembers(id);

      if (response == null) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: <String, dynamic>{
            'error': 'Family not found',
          },
        );
      }

      return Response.json(
        body: response.toJson(),
      );
    } else {
      // Get family only
      final Family? family = await familyService.getFamilyById(id);

      if (family == null) {
        return Response.json(
          statusCode: HttpStatus.notFound,
          body: <String, dynamic>{
            'error': 'Family not found',
          },
        );
      }

      return Response.json(
        body: family.toJson(),
      );
    }
  } on ValidationException catch (e) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{
        'error': e.message,
        'code': e.code,
        'field': e.field,
      },
    );
  } on ServiceException catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': 'Failed to retrieve family',
        'message': e.message,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': 'Internal server error',
      },
    );
  }
}

/// Updates an existing family with the provided data.
///
/// This endpoint allows partial updates where only specified fields are changed. The requesting user must have
/// appropriate permissions to modify the family.
///
/// Path Parameters:
/// - id: The unique family identifier
///
/// Request Body:
/// ```json
/// {
/// "name": "Updated Family Name",
/// "settings": {
/// "timezone": "America/Los_Angeles",
/// "maxFamilyMembers": 15
/// }
/// }
/// ```
///
/// Response (200 OK):
/// ```json
/// {
/// "id": "family_123",
/// "name": "Updated Family Name",
/// "primaryUserId": "user_456",
/// "settings": { ... },
/// "createdAt": "2025-01-10T14:30:00Z",
/// "updatedAt": "2025-01-10T15:45:00Z"
/// }
/// ```
Future<Response> _updateFamily(RequestContext context, String id) async {
  try {
    // Validate family ID
    if (id.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: <String, dynamic>{
          'error': 'Family ID is required',
        },
      );
    }

    // Get required services
    final FamilyService familyService = context.read<FamilyService>();

    // Parse and validate request body
    final Map<String, dynamic> body = await context.request.json() as Map<String, dynamic>;
    final FamilyUpdateRequest request = FamilyUpdateRequest.fromJson(body);

    // Update the family
    final Family updatedFamily = await familyService.updateFamily(id, request);

    return Response.json(
      body: updatedFamily.toJson(),
    );
  } on ValidationException catch (e) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{
        'error': e.message,
        'code': e.code,
        'field': e.field,
      },
    );
  } on ServiceException catch (e) {
    // Check if it's a not found error
    if (e.message.contains('does not exist')) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: <String, dynamic>{
          'error': 'Family not found',
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': 'Failed to update family',
        'message': e.message,
      },
    );
  } on FormatException catch (e) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{
        'error': 'Invalid JSON format',
        'message': e.message,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': 'Internal server error',
      },
    );
  }
}

/// Deletes a family and all associated data.
///
/// This endpoint permanently removes a family group and all its associated data. Only the primary administrator can
/// delete a family. This operation cannot be undone.
///
/// Path Parameters:
/// - id: The unique family identifier
///
/// Response (204 No Content): Empty response body on successful deletion.
///
/// Response (403 Forbidden): When the requesting user is not the primary administrator.
/// ```json
/// {
/// "error": "Only the primary administrator can delete the family"
/// }
/// ```
Future<Response> _deleteFamily(RequestContext context, String id) async {
  try {
    // Validate family ID
    if (id.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: <String, dynamic>{
          'error': 'Family ID is required',
        },
      );
    }

    // Get required services
    final FamilyService familyService = context.read<FamilyService>();

    // TODO(Toglefritz): Extract user ID from authentication context
    // For now, using a placeholder - this should be replaced with actual auth
    const String requestingUserId = 'user_placeholder';

    // Delete the family
    await familyService.deleteFamily(id, requestingUserId);

    return Response(statusCode: HttpStatus.noContent);
  } on ValidationException catch (e) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{
        'error': e.message,
        'code': e.code,
        'field': e.field,
      },
    );
  } on ServiceException catch (e) {
    // Check for specific error types
    if (e.message.contains('does not exist')) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: <String, dynamic>{
          'error': 'Family not found',
        },
      );
    }

    if (e.message.contains('Only the primary administrator')) {
      return Response.json(
        statusCode: HttpStatus.forbidden,
        body: <String, dynamic>{
          'error': e.message,
        },
      );
    }

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': 'Failed to delete family',
        'message': e.message,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': 'Internal server error',
      },
    );
  }
}
