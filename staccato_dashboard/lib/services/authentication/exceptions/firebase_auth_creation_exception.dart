/// Exception thrown when Firebase Auth user creation fails.
class FirebaseAuthCreationException implements Exception {
  /// Optional message to provide more context about the exception.
  final String message;

  /// Creates a [FirebaseAuthCreationException] with an optional message.
  FirebaseAuthCreationException([
    this.message = 'Failed to create Firebase Auth user',
  ]);

  @override
  String toString() => 'FirebaseAuthCreationException: $message';
}
