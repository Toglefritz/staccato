part of 'firebase_auth_service.dart';

/// Represents a verified Firebase user with authentication information.
///
/// This class contains the essential user information extracted from a verified Firebase ID token, including the user
/// ID and provider information.
@immutable
class FirebaseUser {
  /// Creates a new Firebase user with the specified information.
  ///
  /// Parameters:
  /// * [uid] - The unique user identifier from Firebase
  /// * [email] - The user's email address (nullable for anonymous users)
  /// * [isAnonymous] - Whether this is an anonymous user account
  /// * [providers] - List of authentication providers used by this user
  const FirebaseUser({
    required this.uid,
    required this.isAnonymous,
    required this.providers,
    this.email,
  });

  /// The unique user identifier assigned by Firebase.
  ///
  /// This ID is consistent across all Firebase services and should be used as the primary identifier for the user in
  /// your application.
  final String uid;

  /// The user's email address.
  ///
  /// This will be null for anonymous users or users who haven't provided an email address during authentication.
  final String? email;

  /// Whether this user is authenticated anonymously.
  ///
  /// Anonymous users have limited privileges and may not have access to all application features.
  final bool isAnonymous;

  /// List of authentication providers used by this user.
  ///
  /// Common providers include 'password', 'google.com', 'facebook.com', and 'anonymous' for anonymous authentication.
  final List<String> providers;

  /// Creates a FirebaseUser from Firebase API response data.
  ///
  /// This factory constructor parses the JSON response from Firebase's user lookup API and extracts the relevant user
  /// information.
  ///
  /// Parameters:
  /// * [json] - The user data from Firebase API response
  ///
  /// Returns a new [FirebaseUser] instance with the parsed information.
  ///
  /// Throws [FormatException] if required fields are missing from the response.
  factory FirebaseUser.fromJson(Map<String, dynamic> json) {
    try {
      final String uid = json['localId'] as String? ?? (throw FormatException('Missing required field: localId'));

      final String? email = json['email'] as String?;

      final List<dynamic> providerUserInfo = json['providerUserInfo'] as List<dynamic>? ?? [];
      final List<String> providers = providerUserInfo
          .map((dynamic provider) => (provider as Map<String, dynamic>)['providerId'] as String)
          .toList();

      final bool isAnonymous = providers.contains('anonymous') || providers.isEmpty;

      return FirebaseUser(
        uid: uid,
        email: email,
        isAnonymous: isAnonymous,
        providers: providers,
      );
    } catch (e) {
      throw FormatException('Failed to parse FirebaseUser from JSON: $e');
    }
  }

  /// Converts this [FirebaseUser] to a JSON representation.
  ///
  /// This method is useful for serializing user information for logging, caching, or passing between services.
  ///
  /// Returns a `Map` containing the user's information in JSON format.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'isAnonymous': isAnonymous,
      'providers': providers,
    };
  }

  @override
  String toString() => 'FirebaseUser(uid: $uid, email: $email, isAnonymous: $isAnonymous)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FirebaseUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
