# Firebase Authentication Middleware for Dart Frog

This document explains how to use the Firebase authentication middleware in your Dart Frog API server.

## Overview

The authentication system provides Firebase ID token verification for your API endpoints. It includes:

- **FirebaseAuthService**: Verifies Firebase ID tokens using Firebase REST API
- **Authentication Middleware**: Dart Frog middleware for protecting routes
- **User Context**: Access to authenticated user information in route handlers

## Setup

### 1. Environment Variables

Set the following environment variables:

```bash
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_PROJECT_ID=your-project-id  # Optional, not currently used
PORT=8080
LOG_LEVEL=INFO
FUNCTIONS_EMULATOR=false  # Set to 'true' for development
```

### 2. Global Middleware

The global middleware in `routes/_middleware.dart` sets up dependency injection:

```dart
Handler middleware(Handler handler) {
  return handler
      .use(requestLogger())
      .use(providers());
}
```

### 3. Route-Specific Authentication

Apply authentication to specific routes by creating a `_middleware.dart` file:

```dart
// routes/protected/_middleware.dart
import 'package:dart_frog/dart_frog.dart';
import 'package:staccato_api_server/middleware/auth_middleware.dart';

Handler middleware(Handler handler) {
  return handler.use(authenticate());
}
```

## Usage in Route Handlers

### Accessing Authenticated User

```dart
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:staccato_api_server/middleware/auth_middleware.dart';
import 'package:staccato_api_server/services/firebase_auth.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    // Get the authenticated user
    final FirebaseUser user = getAuthenticatedUser(context);
    
    // Use user information
    return Response.json(body: {
      'message': 'Hello ${user.email ?? user.uid}!',
      'userId': user.uid,
      'isAnonymous': user.isAnonymous,
    });
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to process request'},
    );
  }
}
```

### Optional Authentication

For routes that work with or without authentication:

```dart
Future<Response> onRequest(RequestContext context) async {
  final FirebaseUser? user = tryGetAuthenticatedUser(context);
  
  if (user != null) {
    // Handle authenticated request
    return Response.json(body: {
      'message': 'Welcome back, ${user.email}!',
      'userId': user.uid,
    });
  } else {
    // Handle unauthenticated request
    return Response.json(body: {
      'message': 'Welcome, guest!',
    });
  }
}
```

## Authentication Types

### Regular Authentication

Use `authenticate()` middleware for regular user authentication:

```dart
Handler middleware(Handler handler) {
  return handler.use(authenticate());
}
```

### Anonymous Authentication

Use `authenticateAnonymous()` for anonymous-only endpoints:

```dart
Handler middleware(Handler handler) {
  return handler.use(authenticateAnonymous());
}
```

## Client Integration

### Sending Authenticated Requests

From your Flutter app or other clients, include the Firebase ID token:

```dart
// Flutter example
final User? user = FirebaseAuth.instance.currentUser;
if (user != null) {
  final String idToken = await user.getIdToken();
  
  final response = await http.get(
    Uri.parse('https://your-api.com/protected-endpoint'),
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    },
  );
}
```

### JavaScript/Web Example

```javascript
// Get the current user's ID token
firebase.auth().currentUser.getIdToken(true)
  .then(idToken => {
    return fetch('/api/protected-endpoint', {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${idToken}`,
        'Content-Type': 'application/json'
      }
    });
  })
  .then(response => response.json())
  .then(data => console.log(data));
```

## Development and Testing

### Emulator Mode

When `FUNCTIONS_EMULATOR=true`, you can bypass authentication by providing a test user ID:

```bash
curl -H "x-user-id: test-user-123" http://localhost:8080/protected-endpoint
```

### Testing with Real Tokens

For integration testing, obtain a real Firebase ID token and use it:

```bash
curl -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN" \
     http://localhost:8080/protected-endpoint
```

## Error Responses

The middleware returns structured error responses:

### Missing Token
```json
{
  "error": {
    "message": "Unauthorized (no ID token)",
    "code": "MISSING_AUTH_TOKEN"
  }
}
```

### Invalid Token
```json
{
  "error": {
    "message": "Unauthorized (token verification failed)",
    "code": "INVALID_AUTH_TOKEN",
    "details": "INVALID_ID_TOKEN"
  }
}
```

### Service Unavailable
```json
{
  "error": {
    "message": "Authentication service unavailable",
    "code": "AUTH_SERVICE_UNAVAILABLE",
    "details": "Connection timeout"
  }
}
```

## FirebaseUser Object

The authenticated user object contains:

```dart
class FirebaseUser {
  final String uid;           // Firebase user ID
  final String? email;        // User email (null for anonymous)
  final bool isAnonymous;     // Whether user is anonymous
  final List<String> providers; // Auth providers used
}
```

## Security Considerations

1. **Token Validation**: All tokens are verified against Firebase's servers
2. **HTTPS Only**: Always use HTTPS in production
3. **Token Expiry**: Firebase ID tokens expire after 1 hour
4. **Rate Limiting**: Consider implementing rate limiting for auth endpoints
5. **Logging**: Avoid logging sensitive user information

## Troubleshooting

### Common Issues

1. **Missing API Key**: Ensure `FIREBASE_API_KEY` is set
2. **Network Errors**: Check Firebase service availability
3. **Token Expired**: Client should refresh tokens automatically
4. **Wrong Project**: Verify the API key matches your Firebase project

### Debug Logging

Set `LOG_LEVEL=DEBUG` to see detailed authentication logs.