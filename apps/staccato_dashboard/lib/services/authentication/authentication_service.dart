import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

import '../firebase/dev_machine_ip.dart';
import 'exceptions/firebase_auth_creation_exception.dart';
import 'exceptions/user_document_creation_exception.dart';
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

  /// The host for the Firebase Functions base URL.
  static final String _cloudFunctionsHost = kDebugMode
      ? devMachineIP
      : ''; // TODO(Toglefritz): update prod host

  /// The base URL for all endpoints used by this service.
  static String baseUrl = kDebugMode
      ? 'http://$_cloudFunctionsHost:5001/brine-3b212/us-central1'
      : ''; // TODO(Toglefritz): update prod endpoint

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
  /// Throws a distinct exception if Firebase Auth user creation or user document creation fails.
  static Future<void> createUser({
    required AuthMethod method,
    String? emailAddress,
    String? password,
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
        await _createUserDocument(user);
      } catch (e) {
        debugPrint('Failed to create Firestore user document: $e');
        throw UserDocumentCreationException();
      }

      debugPrint('Authenticated with UID, ${user.uid}');
    }
  }

  /// Creates a Firestore user document for the authenticated user via backend endpoint.
  static Future<void> _createUserDocument(User user) async {
    final String? idToken = await user.getIdToken();

    // Ensure the user is authenticated and has an ID token
    if (idToken == null) {
      throw Exception('Missing ID token for authenticated user.');
    }

    // Define the backend endpoint URL for creating a user document
    const String endpoint = '/createUserDocument';
    final Uri url = Uri.parse(baseUrl + endpoint);

    // Make an authenticated HTTP POST request to create the user document
    final Response response = await post(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    // Check the response status code
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to create user document: ${response.reasonPhrase}',
      );
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
  Future<void> deleteUserDocument() async {
    try {
      // Get the authenticated user's Firebase ID token
      final String? idToken = await FirebaseAuth.instance.currentUser
          ?.getIdToken();

      if (idToken == null) {
        throw Exception(
          'User is not authenticated. Cannot delete user document.',
        );
      }

      // Define the backend endpoint URL
      const String endpoint = '/deleteUser';

      // Make an authenticated HTTP DELETE request
      final Response response = await delete(
        Uri.parse(baseUrl + endpoint),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      // Check the response status code
      if (response.statusCode == 200) {
        debugPrint('Successfully deleted user document for UID: ${user.uid}');
      } else {
        throw Exception(
          'Failed to delete user document: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      debugPrint('Error deleting user document: $e');
      throw Exception('Error deleting user document: $e');
    }
  }
}
