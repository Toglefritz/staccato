import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:logging/logging.dart';

import 'package:staccato_api_server/exceptions/conflict_exception.dart';
import 'package:staccato_api_server/exceptions/service_exception.dart';
import 'package:staccato_api_server/exceptions/validation_exception.dart';
import 'package:staccato_api_server/models/user.dart';
import 'package:staccato_api_server/services/user_service.dart';

/// Logger instance for user routes.
final Logger _logger = Logger('UserRoutes');

/// Handles HTTP requests for the /api/users endpoint.
///
/// This route handler processes user-related operations including:
/// - POST: Create a new user
/// - GET: Retrieve users (with optional family filtering)
///
/// All responses follow a consistent JSON format with appropriate HTTP status codes and error handling.
Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.post:
      return _createUser(context);
    case HttpMethod.get:
      return _getUsers(context);
    default:
      return Response.json(
        statusCode: HttpStatus.methodNotAllowed,
        body: <String, dynamic>{
          'error': <String, dynamic>{
            'message': 'Method ${context.request.method.value} not allowed',
            'code': 'METHOD_NOT_ALLOWED',
          },
          'meta': <String, dynamic>{
            'timestamp': DateTime.now().toIso8601String(),
          },
        },
      );
  }
}

/// Creates a new user from the request data.
///
/// This handler processes POST requests to create new users in the system. It validates the request data, delegates
/// business logic to the UserService, and returns appropriate responses.
///
/// Request body should contain:
/// - displayName: User's display name (required)
/// - familyId: ID of the family this user belongs to (required)
/// - permissionLevel: User's permission level (required)
/// - profileImageUrl: URL to profile image (optional)
///
/// Returns:
/// - 201 Created: User created successfully with user data
/// - 400 Bad Request: Invalid request data or validation errors
/// - 409 Conflict: User with same ID already exists
/// - 500 Internal Server Error: Unexpected server error
Future<Response> _createUser(RequestContext context) async {
  final String requestId = _generateRequestId();

  try {
    _logger.info('Processing user creation request', {
      'requestId': requestId,
      'method': 'POST',
      'path': '/api/users',
    });

    // Get user service from context
    final UserService userService = context.read<UserService>();

    // Parse request body
    final Map<String, dynamic> body =
        await context.request.json() as Map<String, dynamic>;
    final UserCreateRequest request = UserCreateRequest.fromJson(body);

    _logger.fine('User creation request parsed', {
      'requestId': requestId,
      'displayName': request.displayName,
      'familyId': request.familyId,
      'permissionLevel': request.permissionLevel.value,
    });

    // Create user
    final User user = await userService.createUser(request);

    _logger.info('User created successfully', {
      'requestId': requestId,
      'userId': user.id,
      'displayName': user.displayName,
      'familyId': user.familyId,
    });

    return Response.json(
      statusCode: HttpStatus.created,
      body: <String, dynamic>{
        'data': user.toJson(),
        'meta': <String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'requestId': requestId,
        },
      },
    );
  } on FormatException catch (e) {
    _logger.warning('Invalid JSON in user creation request', {
      'requestId': requestId,
      'error': e.message,
    });

    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{
        'error': <String, dynamic>{
          'message': 'Invalid JSON format',
          'code': 'INVALID_JSON',
          'details': e.message,
        },
        'meta': <String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'requestId': requestId,
        },
      },
    );
  } on ValidationException catch (e) {
    _logger.warning('Validation error in user creation request', {
      'requestId': requestId,
      'error': e.message,
      'field': e.field,
      'code': e.code,
    });

    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{
        'error': <String, dynamic>{
          'message': e.message,
          'code': e.code,
          'field': e.field,
        },
        'meta': <String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'requestId': requestId,
        },
      },
    );
  } on ConflictException catch (e) {
    _logger.warning('Conflict error in user creation request', {
      'requestId': requestId,
      'error': e.message,
      'code': e.code,
    });

    return Response.json(
      statusCode: HttpStatus.conflict,
      body: <String, dynamic>{
        'error': <String, dynamic>{
          'message': e.message,
          'code': e.code,
        },
        'meta': <String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'requestId': requestId,
        },
      },
    );
  } on ServiceException catch (e) {
    _logger.severe('Service error in user creation request', {
      'requestId': requestId,
      'error': e.message,
      'code': e.code,
      'cause': e.cause?.toString(),
    });

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': <String, dynamic>{
          'message': 'Internal server error',
          'code': 'INTERNAL_ERROR',
        },
        'meta': <String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'requestId': requestId,
        },
      },
    );
  } catch (e) {
    _logger.severe('Unexpected error in user creation request', {
      'requestId': requestId,
      'error': e.toString(),
    });

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': <String, dynamic>{
          'message': 'Internal server error',
          'code': 'INTERNAL_ERROR',
        },
        'meta': <String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'requestId': requestId,
        },
      },
    );
  }
}

/// Retrieves users with optional filtering.
///
/// This handler processes GET requests to retrieve users from the system. It supports filtering by family ID and
/// pagination parameters.
///
/// Query parameters:
/// - familyId: Filter users by family ID (optional)
/// - limit: Maximum number of users to return (optional)
/// - offset: Number of users to skip for pagination (optional)
///
/// Returns:
/// - 200 OK: Users retrieved successfully with user data array
/// - 400 Bad Request: Invalid query parameters
/// - 500 Internal Server Error: Unexpected server error
Future<Response> _getUsers(RequestContext context) async {
  final String requestId = _generateRequestId();

  try {
    _logger.info('Processing user retrieval request', {
      'requestId': requestId,
      'method': 'GET',
      'path': '/api/users',
    });

    // Get user service from context
    final UserService userService = context.read<UserService>();

    // Parse query parameters
    final Uri uri = context.request.uri;
    final String? familyId = uri.queryParameters['familyId'];
    final String? limitString = uri.queryParameters['limit'];
    final String? offsetString = uri.queryParameters['offset'];

    // Parse pagination parameters
    int? limit;
    int? offset;

    if (limitString != null) {
      limit = int.tryParse(limitString);
      if (limit == null || limit <= 0) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: <String, dynamic>{
            'error': <String, dynamic>{
              'message': 'Limit must be a positive integer',
              'code': 'INVALID_LIMIT',
              'field': 'limit',
            },
            'meta': <String, dynamic>{
              'timestamp': DateTime.now().toIso8601String(),
              'requestId': requestId,
            },
          },
        );
      }
    }

    if (offsetString != null) {
      offset = int.tryParse(offsetString);
      if (offset == null || offset < 0) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: <String, dynamic>{
            'error': <String, dynamic>{
              'message': 'Offset must be a non-negative integer',
              'code': 'INVALID_OFFSET',
              'field': 'offset',
            },
            'meta': <String, dynamic>{
              'timestamp': DateTime.now().toIso8601String(),
              'requestId': requestId,
            },
          },
        );
      }
    }

    // Retrieve users
    final List<User> users;
    if (familyId != null && familyId.isNotEmpty) {
      _logger.fine('Retrieving users by family ID', {
        'requestId': requestId,
        'familyId': familyId,
        'limit': limit,
        'offset': offset,
      });
      users = await userService.getUsersByFamilyId(
        familyId,
        limit: limit,
        offset: offset,
      );
    } else {
      // For now, we don't support retrieving all users without family filtering
      // This could be added later if needed
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: <String, dynamic>{
          'error': <String, dynamic>{
            'message': 'familyId query parameter is required',
            'code': 'MISSING_FAMILY_ID',
            'field': 'familyId',
          },
          'meta': <String, dynamic>{
            'timestamp': DateTime.now().toIso8601String(),
            'requestId': requestId,
          },
        },
      );
    }

    _logger.info('Users retrieved successfully', {
      'requestId': requestId,
      'userCount': users.length,
      'familyId': familyId,
    });

    return Response.json(
      body: <String, dynamic>{
        'data': users.map((User user) => user.toJson()).toList(),
        'meta': <String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'requestId': requestId,
          'count': users.length,
        },
      },
    );
  } on ValidationException catch (e) {
    _logger.warning('Validation error in user retrieval request', {
      'requestId': requestId,
      'error': e.message,
      'field': e.field,
      'code': e.code,
    });

    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{
        'error': <String, dynamic>{
          'message': e.message,
          'code': e.code,
          'field': e.field,
        },
        'meta': <String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'requestId': requestId,
        },
      },
    );
  } on ServiceException catch (e) {
    _logger.severe('Service error in user retrieval request', {
      'requestId': requestId,
      'error': e.message,
      'code': e.code,
      'cause': e.cause?.toString(),
    });

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': <String, dynamic>{
          'message': 'Internal server error',
          'code': 'INTERNAL_ERROR',
        },
        'meta': <String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'requestId': requestId,
        },
      },
    );
  } catch (e) {
    _logger.severe('Unexpected error in user retrieval request', {
      'requestId': requestId,
      'error': e.toString(),
    });

    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{
        'error': <String, dynamic>{
          'message': 'Internal server error',
          'code': 'INTERNAL_ERROR',
        },
        'meta': <String, dynamic>{
          'timestamp': DateTime.now().toIso8601String(),
          'requestId': requestId,
        },
      },
    );
  }
}

/// Generates a unique request ID for tracking and logging purposes.
///
/// Returns a simple timestamp-based ID for request correlation.
String _generateRequestId() {
  return 'req_${DateTime.now().millisecondsSinceEpoch}';
}
