/// Authentication Middleware for Dart Frog
///
/// This module provides authentication middleware functions for validating Firebase ID tokens in Dart Frog
/// applications. It includes support for both regular authenticated users and anonymous users, with special handling
/// for emulator environments during development.
///
/// The middleware integrates with the FirebaseAuthService to verify tokens and attach user information to request
/// contexts for use by route handlers.
library auth_middleware;

import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:staccato_api_server/services/firebase_auth.dart';

/// Middleware function to authenticate Firebase ID tokens for regular users.
///
/// This middleware extracts the ID token from the Authorization header, verifies it using the Firebase Auth service,
/// and attaches the decoded user information to the request context. If the token is missing or invalid, an
/// unauthorized response is returned.
///
/// The middleware also supports emulator mode for development, where authentication can be bypassed by providing a user
/// ID in the 'x-user-id' header when the Authorization header is missing.
///
/// Usage:
/// ```dart
/// Handler middleware(Handler handler) {
/// return handler.use(authenticate());
/// }
/// ```
///
/// Parameters:
/// * [firebaseAuthService] - Optional service instance for token verification.
/// If not provided, the service will be read from the request context.
///
/// Returns a middleware function that can be used with Dart Frog handlers.
Middleware authenticate({FirebaseAuthService? firebaseAuthService}) {
  return (Handler handler) {
    return (RequestContext context) async {
      final FirebaseAuthService authService = firebaseAuthService ?? context.read<FirebaseAuthService>();

      // Handle emulator environment for development and testing
      if (authService.isEmulatorEnvironment && context.request.headers['authorization'] == null) {
        final String? testUserId = context.request.headers['x-user-id'];
        if (testUserId != null && testUserId.isNotEmpty) {
          // Create a test user for emulator environment
          final FirebaseUser testUser = FirebaseUser(
            uid: testUserId,
            isAnonymous: false,
            providers: const ['test'],
          );

          // Attach the test user to the request context
          final RequestContext authenticatedContext = context.provide<FirebaseUser>(
            () => testUser,
          );

          return handler(authenticatedContext);
        }

        // In emulator mode without user ID, continue without authentication
        return handler(context);
      }

      // Extract the ID token from the Authorization header
      final String? authHeader = context.request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'error': {
              'message': 'Unauthorized (no ID token)',
              'code': 'MISSING_AUTH_TOKEN',
            },
          },
        );
      }

      final String idToken = authHeader.substring('Bearer '.length);

      try {
        // Verify the ID token using the Firebase Auth service
        final FirebaseUser user = await authService.verifyIdToken(idToken);

        // Check for user ID mismatch if provided in request
        final String? requestUserId = _extractUserIdFromRequest(context);
        if (requestUserId != null && requestUserId != user.uid) {
          return Response.json(
            statusCode: HttpStatus.forbidden,
            body: {
              'error': {
                'message': 'Forbidden (userId mismatch)',
                'code': 'USER_ID_MISMATCH',
              },
            },
          );
        }

        // Attach the authenticated user to the request context
        final RequestContext authenticatedContext = context.provide<FirebaseUser>(
          () => user,
        );

        return handler(authenticatedContext);
      } on AuthenticationException catch (e) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'error': {
              'message': 'Unauthorized (token verification failed)',
              'code': 'INVALID_AUTH_TOKEN',
              'details': e.message,
            },
          },
        );
      } on NetworkException catch (e) {
        return Response.json(
          statusCode: HttpStatus.serviceUnavailable,
          body: {
            'error': {
              'message': 'Authentication service unavailable',
              'code': 'AUTH_SERVICE_UNAVAILABLE',
              'details': e.message,
            },
          },
        );
      } on Exception {
        return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {
            'error': {
              'message': 'Internal server error during authentication',
              'code': 'AUTH_INTERNAL_ERROR',
            },
          },
        );
      }
    };
  };
}

/// Middleware function to authenticate Firebase ID tokens for anonymous users.
///
/// This middleware is similar to the regular authenticate middleware but is specifically designed for endpoints that
/// should only be accessible by anonymous users. It verifies that the request is coming from an anonymous Firebase user
/// and rejects requests from regular authenticated users.
///
/// Usage:
/// ```dart
/// Handler middleware(Handler handler) {
/// return handler.use(authenticateAnonymous());
/// }
/// ```
///
/// Parameters:
/// * [firebaseAuthService] - Optional service instance for token verification.
/// If not provided, the service will be read from the request context.
///
/// Returns a middleware function that can be used with Dart Frog handlers.
Middleware authenticateAnonymous({FirebaseAuthService? firebaseAuthService}) {
  return (Handler handler) {
    return (RequestContext context) async {
      final FirebaseAuthService authService = firebaseAuthService ?? context.read<FirebaseAuthService>();

      // Handle emulator environment for development and testing
      if (authService.isEmulatorEnvironment && context.request.headers['authorization'] == null) {
        final String? testUserId = context.request.headers['x-user-id'];
        if (testUserId != null && testUserId.isNotEmpty) {
          // Create a test anonymous user for emulator environment
          final FirebaseUser testUser = FirebaseUser(
            uid: testUserId,
            isAnonymous: true,
            providers: const ['anonymous'],
          );

          // Attach the test user to the request context
          final RequestContext authenticatedContext = context.provide<FirebaseUser>(
            () => testUser,
          );

          return handler(authenticatedContext);
        }

        // In emulator mode without user ID, continue without authentication
        return handler(context);
      }

      // Extract the ID token from the Authorization header
      final String? authHeader = context.request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'error': {
              'message': 'Unauthorized (no ID token)',
              'code': 'MISSING_AUTH_TOKEN',
            },
          },
        );
      }

      final String idToken = authHeader.substring('Bearer '.length);

      try {
        // Verify the ID token using the Firebase Auth service
        final FirebaseUser user = await authService.verifyIdToken(idToken);

        // Verify that this is an anonymous user
        if (!user.isAnonymous) {
          return Response.json(
            statusCode: HttpStatus.forbidden,
            body: {
              'error': {
                'message': 'Forbidden (anonymous access only)',
                'code': 'NON_ANONYMOUS_USER',
              },
            },
          );
        }

        // Attach the authenticated anonymous user to the request context
        final RequestContext authenticatedContext = context.provide<FirebaseUser>(
          () => user,
        );

        return handler(authenticatedContext);
      } on AuthenticationException catch (e) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {
            'error': {
              'message': 'Unauthorized (token verification failed)',
              'code': 'INVALID_AUTH_TOKEN',
              'details': e.message,
            },
          },
        );
      } on NetworkException catch (e) {
        return Response.json(
          statusCode: HttpStatus.serviceUnavailable,
          body: {
            'error': {
              'message': 'Authentication service unavailable',
              'code': 'AUTH_SERVICE_UNAVAILABLE',
              'details': e.message,
            },
          },
        );
      } on Exception {
        return Response.json(
          statusCode: HttpStatus.internalServerError,
          body: {
            'error': {
              'message': 'Internal server error during authentication',
              'code': 'AUTH_INTERNAL_ERROR',
            },
          },
        );
      }
    };
  };
}

/// Extracts the user ID from the request body or query parameters.
///
/// This helper function checks both the request body (for POST/PUT requests) and query parameters (for GET requests) to
/// find a userId field that can be validated against the authenticated user's ID.
///
/// Parameters:
/// * [context] - The request context containing the HTTP request
///
/// Returns the user ID if found, or null if not present in the request.
String? _extractUserIdFromRequest(RequestContext context) {
  try {
    // Check query parameters first
    final String? queryUserId = context.request.uri.queryParameters['userId'];
    if (queryUserId != null && queryUserId.isNotEmpty) {
      return queryUserId;
    }

    // For requests with body content, we would need to parse the body
    // However, this is complex in Dart Frog middleware since the body
    // can only be read once. For now, we'll rely on route handlers
    // to perform this validation after parsing the request body.

    return null;
  } catch (e) {
    // If there's any error extracting the user ID, return null
    // The route handler can perform more specific validation
    return null;
  }
}

/// Helper function to get the authenticated user from the request context.
///
/// This function should be used by route handlers to access the authenticated user information that was attached by the
/// authentication middleware.
///
/// Parameters:
/// * [context] - The request context from a route handler
///
/// Returns the authenticated [FirebaseUser] if present.
///
/// Throws [StateError] if no authenticated user is found in the context, which indicates that the authentication
/// middleware was not applied or authentication failed.
///
/// Usage:
/// ```dart
/// Future<Response> onRequest(RequestContext context) async {
/// final FirebaseUser user = getAuthenticatedUser(context);
/// // Use user.uid for database queries, etc.
/// }
/// ```
FirebaseUser getAuthenticatedUser(RequestContext context) {
  try {
    return context.read<FirebaseUser>();
  } catch (e) {
    throw StateError(
      'No authenticated user found in request context. '
      'Ensure that authentication middleware is applied to this route.',
    );
  }
}

/// Helper function to safely get the authenticated user from the request context.
///
/// This function is similar to [getAuthenticatedUser] but returns null instead of throwing an exception when no
/// authenticated user is found. This is useful for optional authentication scenarios.
///
/// Parameters:
/// * [context] - The request context from a route handler
///
/// Returns the authenticated [FirebaseUser] if present, or null if not found.
///
/// Usage:
/// ```dart
/// Future<Response> onRequest(RequestContext context) async {
/// final FirebaseUser? user = tryGetAuthenticatedUser(context);
/// if (user != null) {
/// // Handle authenticated request
/// } else {
/// // Handle unauthenticated request
/// }
/// }
/// ```
FirebaseUser? tryGetAuthenticatedUser(RequestContext context) {
  try {
    return context.read<FirebaseUser>();
  } catch (e) {
    return null;
  }
}
