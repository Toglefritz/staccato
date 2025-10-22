import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

import 'package:staccato_api_server/exceptions/service_exception.dart';
import 'package:staccato_api_server/exceptions/validation_exception.dart';
import 'package:staccato_api_server/models/family.dart';
import 'package:staccato_api_server/models/family_create_request.dart';
import 'package:staccato_api_server/services/family_service.dart';

/// Route handler for family collection operations.
///
/// This handler manages HTTP requests for family-related operations including:
/// - POST /api/families - Create a new family
/// - GET /api/families - List families for the authenticated user
///
/// All operations require authentication and proper request validation.
Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return _createFamily(context);
    case HttpMethod.get:
      return _getFamilies(context);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

/// Creates a new family group.
///
/// This endpoint processes family creation requests and establishes the requesting user as the primary administrator.
/// The family is created with default settings unless custom settings are provided in the request.
///
/// Request Body:
/// ```json
/// {
/// "name": "The Smith Family",
/// "settings": {
/// "timezone": "America/New_York",
/// "maxFamilyMembers": 10
/// }
/// }
/// ```
///
/// Response (201 Created):
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
Future<Response> _createFamily(RequestContext context) async {
  try {
    // Get required services
    final FamilyService familyService = context.read<FamilyService>();

    // TODO(Toglefritz): Extract user ID from authentication context
    // For now, using a placeholder - this should be replaced with actual auth
    const String primaryUserId = 'user_placeholder';

    // Parse and validate request body
    final Map<String, dynamic> body = await context.request.json() as Map<String, dynamic>;
    final FamilyCreateRequest request = FamilyCreateRequest.fromJson(body);

    // Create the family
    final Family family = await familyService.createFamily(request, primaryUserId);

    return Response.json(
      statusCode: HttpStatus.created,
      body: family.toJson(),
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
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': 'Failed to create family',
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

/// Retrieves families for the authenticated user.
///
/// This endpoint returns all families where the authenticated user is the primary administrator. It supports optional
/// pagination parameters for large result sets.
///
/// Query Parameters:
/// - limit: Maximum number of families to return (optional)
/// - offset: Number of families to skip for pagination (optional)
///
/// Response (200 OK):
/// ```json
/// [
/// {
/// "id": "family_123",
/// "name": "The Smith Family",
/// "primaryUserId": "user_456",
/// "settings": { ... },
/// "createdAt": "2025-01-10T14:30:00Z",
/// "updatedAt": "2025-01-10T14:30:00Z"
/// }
/// ]
/// ```
Future<Response> _getFamilies(RequestContext context) async {
  try {
    // Get required services
    final FamilyService familyService = context.read<FamilyService>();

    // TODO(Toglefritz): Extract user ID from authentication context
    // For now, using a placeholder - this should be replaced with actual auth
    const String primaryUserId = 'user_placeholder';

    // Parse optional query parameters
    final Uri uri = context.request.uri;
    final String? limitString = uri.queryParameters['limit'];
    final String? offsetString = uri.queryParameters['offset'];

    final int? limit = limitString != null ? int.tryParse(limitString) : null;
    final int? offset = offsetString != null ? int.tryParse(offsetString) : null;

    // Validate pagination parameters
    if (limit != null && limit <= 0) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: <String, dynamic>{
          'error': 'Limit must be a positive integer',
        },
      );
    }

    if (offset != null && offset < 0) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: <String, dynamic>{
          'error': 'Offset must be a non-negative integer',
        },
      );
    }

    // Get families for the user
    final List<Family> families = await familyService.getFamiliesByPrimaryUserId(
      primaryUserId,
      limit: limit,
      offset: offset,
    );

    // Convert to JSON response
    final List<Map<String, dynamic>> familiesJson = families.map((Family family) => family.toJson()).toList();

    return Response.json(
      body: familiesJson,
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
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': 'Failed to retrieve families',
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
