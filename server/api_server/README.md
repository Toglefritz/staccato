# Staccato API Server

A REST API server for the Staccato family management system, built with Dart Frog and using a custom Firestore REST API client.

## Features

- **Custom Firestore Integration**: Direct REST API integration with Google Cloud Firestore (no third-party packages)
- **User Management**: Complete CRUD operations for user entities
- **Authentication**: Service Account-based authentication with Google Cloud
- **Comprehensive Testing**: Full test coverage for all endpoints and services
- **Type Safety**: Strongly typed throughout with comprehensive documentation

## Architecture

The server follows a layered architecture pattern:

- **Routes**: HTTP request/response handling
- **Services**: Business logic and validation
- **Repositories**: Data persistence abstraction
- **Models**: Data transfer objects with JSON serialization

### Custom Firestore Client

Instead of relying on third-party Firebase packages, this server implements a custom Firestore client using the official REST API. This provides:

- **Full Control**: Direct access to all Firestore features
- **No Dependencies**: No reliance on unofficial or incomplete packages
- **Better Performance**: Optimized for server-side usage
- **Security**: Service Account authentication with JWT tokens

## Setup

### Prerequisites

- Dart SDK 3.0.0 or higher
- Google Cloud Project with Firestore enabled
- Service Account with Firestore permissions

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
# Google Cloud Configuration
GOOGLE_CLOUD_PROJECT_ID=your-project-id
GOOGLE_SERVICE_ACCOUNT_EMAIL=your-service-account@your-project-id.iam.gserviceaccount.com
GOOGLE_SERVICE_ACCOUNT_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour private key content here\n-----END PRIVATE KEY-----"

# Server Configuration
PORT=8080
LOG_LEVEL=INFO
```

### Google Cloud Setup

1. **Create a Service Account**:
   ```bash
   gcloud iam service-accounts create staccato-api \
     --description="Service account for Staccato API server" \
     --display-name="Staccato API"
   ```

2. **Grant Firestore Permissions**:
   ```bash
   gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
     --member="serviceAccount:staccato-api@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
     --role="roles/datastore.user"
   ```

3. **Generate Private Key**:
   ```bash
   gcloud iam service-accounts keys create key.json \
     --iam-account=staccato-api@YOUR_PROJECT_ID.iam.gserviceaccount.com
   ```

4. **Extract Private Key**: Copy the `private_key` field from `key.json` to your `.env` file.

### Installation

1. **Install Dependencies**:
   ```bash
   dart pub get
   ```

2. **Run Tests**:
   ```bash
   dart test
   ```

3. **Start Development Server**:
   ```bash
   dart_frog dev
   ```

## API Endpoints

### Users

#### Create User
```http
POST /api/users
Content-Type: application/json

{
  "displayName": "John Doe",
  "familyId": "family_123",
  "permissionLevel": "adult",
  "profileImageUrl": "https://example.com/profile.jpg"
}
```

**Response (201 Created)**:
```json
{
  "data": {
    "id": "user_456",
    "displayName": "John Doe",
    "familyId": "family_123",
    "permissionLevel": "adult",
    "createdAt": "2025-01-10T14:30:00.000Z",
    "updatedAt": "2025-01-10T14:30:00.000Z",
    "profileImageUrl": "https://example.com/profile.jpg"
  },
  "meta": {
    "timestamp": "2025-01-10T14:30:00.000Z",
    "requestId": "req_123"
  }
}
```

#### Get Users by Family
```http
GET /api/users?familyId=family_123&limit=10&offset=0
```

**Response (200 OK)**:
```json
{
  "data": [
    {
      "id": "user_456",
      "displayName": "John Doe",
      "familyId": "family_123",
      "permissionLevel": "adult",
      "createdAt": "2025-01-10T14:30:00.000Z",
      "updatedAt": "2025-01-10T14:30:00.000Z",
      "profileImageUrl": "https://example.com/profile.jpg"
    }
  ],
  "meta": {
    "timestamp": "2025-01-10T14:30:00.000Z",
    "requestId": "req_124",
    "count": 1
  }
}
```

## Error Handling

The API returns structured error responses:

```json
{
  "error": {
    "message": "The displayName field is required but was not provided.",
    "code": "VALIDATION_MISSING_FIELD",
    "field": "displayName"
  },
  "meta": {
    "timestamp": "2025-01-10T14:30:00.000Z",
    "requestId": "req_125"
  }
}
```

### Error Codes

- `VALIDATION_FAILED`: General validation error
- `VALIDATION_MISSING_FIELD`: Required field is missing
- `VALIDATION_INVALID_FORMAT`: Field format is invalid
- `RESOURCE_CONFLICT`: Resource already exists
- `INTERNAL_ERROR`: Server error
- `METHOD_NOT_ALLOWED`: HTTP method not supported

## Firestore REST API Implementation

The custom Firestore client handles:

### Authentication
- JWT token generation using service account credentials
- Automatic token refresh with expiration handling
- OAuth 2.0 flow with Google's token endpoint

### Document Operations
- **Create**: `POST /v1/projects/{project}/databases/(default)/documents/{collection}`
- **Read**: `GET /v1/projects/{project}/databases/(default)/documents/{collection}/{document}`
- **Update**: `PATCH /v1/projects/{project}/databases/(default)/documents/{collection}/{document}`
- **Delete**: `DELETE /v1/projects/{project}/databases/(default)/documents/{collection}/{document}`

### Queries
- Structured queries with filtering and pagination
- Field equality filters
- Limit and offset support
- Automatic result conversion

### Data Conversion
- Automatic conversion between Dart types and Firestore value types
- Support for strings, numbers, booleans, timestamps, arrays, and maps
- Proper handling of null values and nested objects

## Development

### Running Tests
```bash
# Run all tests
dart test

# Run specific test file
dart test test/services/user_service_test.dart

# Run with coverage
dart test --coverage=coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

### Code Analysis
```bash
# Run static analysis
dart analyze

# Fix formatting
dart format .
```

### Adding New Endpoints

1. **Create Route Handler**: Add a new file in `routes/api/`
2. **Implement Service**: Add business logic in `lib/services/`
3. **Create Repository**: Add data access in `lib/repositories/`
4. **Add Tests**: Create comprehensive tests for all layers
5. **Update Documentation**: Document the new endpoints

## Deployment

The server is designed to run on Google Cloud Run or any container platform:

1. **Build Container**:
   ```bash
   docker build -t staccato-api .
   ```

2. **Deploy to Cloud Run**:
   ```bash
   gcloud run deploy staccato-api \
     --image gcr.io/YOUR_PROJECT_ID/staccato-api \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated
   ```

3. **Set Environment Variables** in the Cloud Run service configuration.

## Security Considerations

- Service account private keys should be stored securely
- Use environment variables for all sensitive configuration
- Implement proper input validation and sanitization
- Consider rate limiting for production deployments
- Use HTTPS in production environments

## Contributing

1. Follow the established architecture patterns
2. Maintain comprehensive test coverage
3. Document all public APIs
4. Use strong typing throughout
5. Follow Dart style guidelines