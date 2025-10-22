import 'package:dart_frog/dart_frog.dart';
import 'package:staccato_api_server/middleware/auth_middleware.dart';
import 'package:staccato_api_server/middleware/providers.dart';

/// Middleware for the /api routes.
///
/// This middleware applies authentication and dependency injection to all API routes. All routes under /api/* will
/// require valid Firebase authentication.
Handler middleware(Handler handler) {
  return handler
      .use(authenticate()) // Require authentication for all /api routes
      .use(providers());
}
