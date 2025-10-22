import 'package:dart_frog/dart_frog.dart';
import 'package:staccato_api_server/middleware/auth_middleware.dart';

/// Middleware for family-related API routes.
///
/// This middleware requires Firebase authentication for all family management endpoints. Users must provide a valid
/// Firebase ID token to access these routes.
Handler middleware(Handler handler) {
  return handler.use(authenticate());
}
