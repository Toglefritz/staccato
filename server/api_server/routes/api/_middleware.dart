import 'package:dart_frog/dart_frog.dart';
import 'package:staccato_api_server/middleware/providers.dart';

/// Middleware for the /api routes.
///
/// This middleware applies dependency injection providers to make services and repositories available to API route
/// handlers.
Handler middleware(Handler handler) {
  return handler.use(providers());
}
