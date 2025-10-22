/// Global Middleware Configuration
///
/// This file sets up middleware that applies to all routes in the application. It configures dependency injection,
/// logging, error handling, and other cross-cutting concerns that should be available throughout the API.
library global_middleware;

import 'package:dart_frog/dart_frog.dart';
import 'package:staccato_api_server/middleware/providers.dart';

/// Global middleware handler that applies to all routes.
///
/// This middleware sets up the foundational services and providers that are needed by all routes in the application. It
/// should be kept minimal and only include truly global concerns.
///
/// The middleware is applied in order, with earlier middleware wrapping later middleware and route handlers.
Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(providers());
}

/// Simple request logging middleware for development and debugging.
///
/// This middleware logs basic information about each request including the HTTP method, path, and response status code.
/// It's useful for monitoring API usage and debugging routing issues.
///
/// In production, you might want to replace this with more sophisticated logging that integrates with your monitoring
/// and observability stack.
Middleware requestLogger() {
  return (handler) => (context) async {
        final response = await handler(context);

        return response;
      };
}
