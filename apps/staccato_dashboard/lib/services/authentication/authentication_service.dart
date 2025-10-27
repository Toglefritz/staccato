import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../user_management/user_management.dart';
import 'exceptions/firebase_auth_creation_exception.dart';
import 'exceptions/user_document_creation_exception.dart' as auth_exceptions;
import 'models/auth_methods.dart';

/// A service class that handles authentication tasks with Firebase Auth.
///
/// This class provides static methods to perform various authentication actions, such as creating accounts with email
/// and password, signing in with Google, and signing out. It encapsulates the Firebase Auth operations for this app.
class AuthenticationService {
  /// The Firebase Auth [User] object representing the current user.
  final User user;

  /// Creates an instance of the [AuthenticationService] class with the specified [user].
  AuthenticationService({required this.user});

  /// User management service for handling user document operations.
  static final UserManagementService _userManagementService =
      UserManagementService();

  /// Creates a password-based account with Firebase Auth.
  ///
  /// As part of creating a password-based account with Firebase Auth, a [FirebaseAuthException] can be thrown if issues
  /// with the provided username or password are discovered.
  static Future<User?> _createBasicAuthAccount({
    required String emailAddress,
    required String password,
  }) async {
    try {
      final UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException thrown during account creation: $e');

      rethrow;
    } catch (e) {
      debugPrint('Creating password-based account failed with exception, $e');

      rethrow;
    }
  }

  /// Creates a new user via Firebase Authentication and creates a user document.
  ///
  /// This method handles the complete user creation workflow including Firebase Auth account creation and user
  /// document creation in the backend system.
  ///
  /// Parameters:
  /// * [method] - Authentication method to use (basic auth, Google, Apple)
  /// * [emailAddress] - Email address for basic auth (required for basic auth)
  /// * [password] - Password for basic auth (required for basic auth)
  /// * [displayName] - Display name for the user (required)
  /// * [familyId] - ID of the family this user will belong to (required)
  /// * [permissionLevel] - Permission level for the user (required)
  /// * [profileImageUrl] - Optional URL to the user's profile image
  ///
  /// Throws a distinct exception if Firebase Auth user creation or user document creation fails.
  static Future<void> createUser({
    required AuthMethod method,
    required String displayName,
    required String familyId,
    required UserPermissionLevel permissionLevel,
    String? emailAddress,
    String? password,
    String? profileImageUrl,
  }) async {
    User? user;

    try {
      switch (method) {
        case AuthMethod.basicAuth:
          assert(
            emailAddress != null && password != null,
            'For authenticating with basic auth, the email and password must be provided',
          );
          user = await _createBasicAuthAccount(
            emailAddress: emailAddress!,
            password: password!,
          );
        case AuthMethod.google:
          user = await signInWithGoogle();
        case AuthMethod.apple:
          // TODO(Toglefritz): Handle this case.
          break;
      }
    } catch (e) {
      debugPrint('Failed to create Firebase Auth user: $e');
      throw FirebaseAuthCreationException();
    }

    // If the user is successfully authenticated, create a Firestore user document.
    if (user != null) {
      try {
        final UserCreateRequest request = UserCreateRequest(
          displayName: displayName,
          familyId: familyId,
          permissionLevel: permissionLevel,
          profileImageUrl: profileImageUrl,
        );

        await _userManagementService.createUserDocument(request);
      } catch (e) {
        debugPrint('Failed to create Firestore user document: $e');
        throw auth_exceptions.UserDocumentCreationException();
      }

      debugPrint('Authenticated with UID, ${user.uid}');
    }
  }

  /// Asynchronously signs the user in using Google authentication.
  ///
  /// Uses the google_sign_in v7+ flow: first attempts a lightweight authentication via
  /// `attemptLightweightAuthentication()`, then falls back to an explicit `authenticate()` prompt (per the package
  /// example). On web, uses Firebase Auth's `signInWithPopup`.
  static Future<User?> signInWithGoogle() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    if (kIsWeb) {
      final GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final UserCredential userCredential = await auth.signInWithPopup(
          authProvider,
        );
        user = userCredential.user;
      } catch (e, s) {
        debugPrint(
          'Failed to sign in with Google (web) with exception: $e\n$s',
        );
        rethrow;
      }
    } else {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      GoogleSignInAccount? googleUser;

      try {
        // Try a lightweight auth first (may still show minimal UI on some platforms).
        googleUser = await signIn.attemptLightweightAuthentication();

        // If that didn't return a user, fall back to an explicit auth prompt if supported.
        if (googleUser == null) {
          if (signIn.supportsAuthenticate()) {
            googleUser = await signIn.authenticate();
          } else {
            // Fallback for older platforms; may be removed when no longer needed.
            googleUser = await GoogleSignIn.instance.authenticate();
          }
        }
      } on GoogleSignInException catch (e, s) {
        // Treat cancel as a non-error and return null; rethrow other issues.
        if (e.code == GoogleSignInExceptionCode.canceled) {
          debugPrint('Google sign-in canceled by user.');
          return null;
        }
        debugPrint(
          'GoogleSignInException during sign-in: ${e.code}: ${e.description}\n$s',
        );
        rethrow;
      } catch (e, s) {
        debugPrint('Unexpected error during Google sign-in: $e\n$s');
        rethrow;
      }

      // Exchange GoogleSignIn tokens for a Firebase credential.
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      try {
        final UserCredential userCredential = await auth.signInWithCredential(
          credential,
        );
        user = userCredential.user;
      } on FirebaseAuthException catch (e, s) {
        debugPrint(
          'FirebaseAuthException during Google sign-in: ${e.code}: ${e.message}\n$s',
        );
        rethrow;
      } catch (e, s) {
        debugPrint(
          'Unexpected error while exchanging Google credential with Firebase: $e\n$s',
        );
        rethrow;
      }
    }

    return user;
  }

  /// Logs the user out of the app via Firebase Auth.
  ///
  /// Uses the google_sign_in v7+ API. First calls `GoogleSignIn.instance.signOut()` to clear the current Google session
  /// for this app (non-destructive), then signs out of Firebase. If you need to fully revoke the app's authorization
  /// (to force account re-consent next time), call `disconnect()` instead of `signOut()`.
  static Future<void> signOut() async {
    final GoogleSignIn signIn = GoogleSignIn.instance;

    try {
      // Clear the Google session for this app.
      await signIn.signOut();

      // If you need to revoke prior authorization instead of just signing out,
      // use the following line *instead* of signOut():
      // await signIn.disconnect();
    } on GoogleSignInException catch (e, s) {
      // Swallow cancel/not-signed-in errors; rethrow unexpected ones.
      debugPrint(
        'Google sign-out encountered an error: ${e.code}: ${e.description}\n$s',
      );
    } catch (e, s) {
      debugPrint('Unexpected error during Google sign-out: $e\n$s');
    } finally {
      // Always sign out of Firebase as well.
      await FirebaseAuth.instance.signOut();
    }
  }

  /// Deletes the user's document in the "users" collection of the Firestore database.
  ///
  /// This method delegates to the UserManagementService to handle the deletion of the user document from the backend
  /// system.
  ///
  /// Throws [UserDocumentDeletionException] if the deletion fails.
  Future<void> deleteUserDocument() async {
    try {
      await _userManagementService.deleteCurrentUserDocument();
      debugPrint('Successfully deleted user document for UID: ${user.uid}');
    } on UserServiceException catch (e) {
      debugPrint('Error deleting user document: ${e.message}');
      throw Exception('Error deleting user document: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error deleting user document: $e');
      throw Exception('Error deleting user document: $e');
    }
  }
}
