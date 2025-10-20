import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';

import 'package:staccato_api_server/repositories/firestore_user_repository.dart';
import 'package:staccato_api_server/repositories/user_repository.dart';
import 'package:staccato_api_server/services/firestore_client.dart';
import 'package:staccato_api_server/services/user_service.dart';

/// Middleware that provides dependency injection for the application.
///
/// This middleware sets up the dependency injection container with all required services and repositories. It uses
/// Dart Frog's provider system to make dependencies available throughout the request handling pipeline.
///
/// Dependencies are registered in order of their dependencies (dependencies first) to ensure proper initialization.
Handler middleware(Handler handler) {
  // Create all dependencies upfront to avoid context.read issues
  final FirestoreClient firestoreClient = _createFirestoreClient();
  final UserRepository userRepository = FirestoreUserRepository(firestoreClient);
  final UserService userService = UserService(userRepository: userRepository);

  return handler
      .use(provider<FirestoreClient>((RequestContext context) => firestoreClient))
      .use(provider<UserRepository>((RequestContext context) => userRepository))
      .use(provider<UserService>((RequestContext context) => userService));
}

/// Creates a FirestoreClient instance from environment configuration.
FirestoreClient _createFirestoreClient() {
  // Load environment variables from .env file
  final DotEnv env = DotEnv();
  try {
    env.load(['.env']);
  } catch (e) {
    // .env file might not exist, continue with system environment variables
  }

  // Get configuration from environment variables (loaded from .env or system)
  String? projectId = env['GOOGLE_CLOUD_PROJECT_ID'] ?? Platform.environment['GOOGLE_CLOUD_PROJECT_ID'];
  String? serviceAccountEmail =
      env['GOOGLE_SERVICE_ACCOUNT_EMAIL'] ?? Platform.environment['GOOGLE_SERVICE_ACCOUNT_EMAIL'];
  String? privateKey =
      env['GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY'] ?? Platform.environment['GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY'];
  final String? keyFilePath =
      env['GOOGLE_SERVICE_ACCOUNT_KEY_FILE'] ?? Platform.environment['GOOGLE_SERVICE_ACCOUNT_KEY_FILE'];

  // Option 1: Use individual environment variables
  if (projectId != null && serviceAccountEmail != null && privateKey != null) {
    return FirestoreClient(
      projectId: projectId,
      serviceAccountEmail: serviceAccountEmail,
      privateKey: privateKey,
    );
  }

  // Option 2: Use service account JSON file
  if (keyFilePath != null && keyFilePath.isNotEmpty) {
    final File keyFile = File(keyFilePath);
    if (!keyFile.existsSync()) {
      throw StateError('Service account key file not found: $keyFilePath');
    }

    final String keyFileContent = keyFile.readAsStringSync();
    final Map<String, dynamic> keyData = jsonDecode(keyFileContent) as Map<String, dynamic>;

    projectId = keyData['project_id'] as String?;
    serviceAccountEmail = keyData['client_email'] as String?;
    privateKey = keyData['private_key'] as String?;

    if (projectId == null || serviceAccountEmail == null || privateKey == null) {
      throw StateError(
        'Invalid service account key file: missing required fields',
      );
    }

    return FirestoreClient(
      projectId: projectId,
      serviceAccountEmail: serviceAccountEmail,
      privateKey: privateKey,
    );
  }

  // Fallback error
  throw StateError(
    'Either provide individual environment variables (GOOGLE_CLOUD_PROJECT_ID, GOOGLE_SERVICE_ACCOUNT_EMAIL, GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY) '
    'or GOOGLE_SERVICE_ACCOUNT_KEY_FILE pointing to your service account JSON file',
  );
}
