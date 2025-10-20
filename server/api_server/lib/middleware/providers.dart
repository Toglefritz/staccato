import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dotenv/dotenv.dart';

import '../repositories/firestore_user_repository.dart';
import '../repositories/user_repository.dart';
import '../services/firestore_client.dart';
import '../services/user_service.dart';

/// Middleware that provides dependency injection for the application.
///
/// This middleware sets up the dependency injection container with all required services and repositories. It uses Dart
/// Frog's provider system to make dependencies available throughout the request handling pipeline.
///
/// Dependencies are registered in order of their dependencies (dependencies first) to ensure proper initialization.
Handler middleware(Handler handler) {
  return handler
      .use(
        provider<FirestoreClient>((RequestContext context) {
          // Load environment variables from .env file
          final DotEnv env = DotEnv();
          try {
            env.load(['.env']);
          } catch (e) {
            // .env file might not exist, continue with system environment variables
          }

          // Get configuration from environment variables (loaded from .env or system)
          final String? projectId = env['GOOGLE_CLOUD_PROJECT_ID'] ??
              Platform.environment['GOOGLE_CLOUD_PROJECT_ID'];
          final String? serviceAccountEmail =
              env['GOOGLE_SERVICE_ACCOUNT_EMAIL'] ??
                  Platform.environment['GOOGLE_SERVICE_ACCOUNT_EMAIL'];
          final String? privateKey =
              env['GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY'] ??
                  Platform.environment['GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY'];
          final String? keyFilePath = env['GOOGLE_SERVICE_ACCOUNT_KEY_FILE'] ??
              Platform.environment['GOOGLE_SERVICE_ACCOUNT_KEY_FILE'];

          // Option 1: Use individual environment variables
          if (projectId != null &&
              serviceAccountEmail != null &&
              privateKey != null) {
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
              throw StateError(
                'Service account key file not found: $keyFilePath',
              );
            }

            final String keyFileContent = keyFile.readAsStringSync();
            final Map<String, dynamic> keyData =
                jsonDecode(keyFileContent) as Map<String, dynamic>;

            final String? fileProjectId = keyData['project_id'] as String?;
            final String? fileServiceAccountEmail =
                keyData['client_email'] as String?;
            final String? filePrivateKey = keyData['private_key'] as String?;

            if (fileProjectId == null ||
                fileServiceAccountEmail == null ||
                filePrivateKey == null) {
              throw StateError(
                'Invalid service account key file: missing required fields',
              );
            }

            return FirestoreClient(
              projectId: fileProjectId,
              serviceAccountEmail: fileServiceAccountEmail,
              privateKey: filePrivateKey,
            );
          }

          // Fallback: Check for individual environment variables
          final String? envProjectId =
              Platform.environment['GOOGLE_CLOUD_PROJECT_ID'];
          final String? envServiceAccountEmail =
              Platform.environment['GOOGLE_SERVICE_ACCOUNT_EMAIL'];

          if (envProjectId == null || envProjectId.isEmpty) {
            throw StateError(
              'GOOGLE_CLOUD_PROJECT_ID environment variable or GOOGLE_SERVICE_ACCOUNT_KEY_FILE is required',
            );
          }
          if (envServiceAccountEmail == null ||
              envServiceAccountEmail.isEmpty) {
            throw StateError(
              'GOOGLE_SERVICE_ACCOUNT_EMAIL environment variable or GOOGLE_SERVICE_ACCOUNT_KEY_FILE is required',
            );
          }

          throw StateError(
            'Either GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY or GOOGLE_SERVICE_ACCOUNT_KEY_FILE environment variable is required',
          );
        }),
      )
      .use(
        provider<UserRepository>(
          (RequestContext context) =>
              FirestoreUserRepository(context.read<FirestoreClient>()),
        ),
      )
      .use(
        provider<UserService>(
          (RequestContext context) => UserService(
            userRepository: context.read<UserRepository>(),
          ),
        ),
      );
}
