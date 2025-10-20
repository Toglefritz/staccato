/// Exception thrown when user document creation in Firestore fails.
class UserDocumentCreationException implements Exception {
  /// Optional message to provide more context about the exception.
  final String message;

  /// Creates a [UserDocumentCreationException] with an optional message.
  UserDocumentCreationException([
    this.message = 'Failed to create user document',
  ]);

  @override
  String toString() => 'UserDocumentCreationException: $message';
}
