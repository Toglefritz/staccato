# Staccato Server Infrastructure

The complete backend infrastructure for the Staccato family management system, consisting of two main subsystems:

1. **API Server** (`api-server/`) - Core REST API built with Dart Frog for user management, family coordination, and data persistence
2. **Agent System** (`agent-system/`) - AI agent orchestration using Google's Agent Development Kit (ADK) for personalized family experiences

Both subsystems are designed for deployment on Google Cloud Run with Firebase integration.

## System Architecture

The Staccato server infrastructure is organized into two complementary subsystems:

```
┌─────────────────────────────────────────────────────────────┐
│                    Frontend Applications                     │
│              (Flutter Dashboard, Mobile Apps)               │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────┴───────────────────────────────────────┐
│                  API Gateway / Load Balancer                │
└─────────────────┬───────────────────┬───────────────────────┘
                  │                   │
┌─────────────────┴─────────────────┐ │ ┌─────────────────────┴─────────────────┐
│           API Server              │ │ │          Agent System                 │
│        (Dart Frog)                │ │ │    (Google ADK + Python)             │
├───────────────────────────────────┤ │ ├───────────────────────────────────────┤
│  • User Management                │ │ │  • Per-User Agents                    │
│  • Family Coordination            │ │ │  • Coordinator Agent                  │
│  • Authentication                 │ │ │  • Policy Agent                       │
│  • Data Persistence               │ │ │  • AI Model Integration               │
│  • RESTful API Endpoints          │ │ │  • Personalization Engine            │
└─────────────────┬─────────────────┘ │ └─────────────────┬─────────────────────┘
                  │                   │                   │
                  └─────────────────┬─┴───────────────────┘
                                    │
┌─────────────────────────────────┬─┴─────────────────────────────────┐
│            Firebase             │           Google Cloud            │
│  • Firestore Database          │  • AI Studio / Vertex AI         │
│  • Authentication              │  • Cloud Run Deployment          │
│  • Storage                      │  • Cloud Logging                 │
│  • Real-time Sync              │  • Cloud Monitoring              │
└─────────────────────────────────┴───────────────────────────────────┘
```

## Subsystem Overview

### API Server (`api-server/`)
The core REST API service built with Dart Frog, following a strict layered architecture:

- **Route Handlers**: HTTP request/response processing with validation and error handling
- **Services**: Business logic, orchestration, and coordination between components
- **Repositories**: Data persistence abstraction layer for Firebase Firestore
- **Models**: Immutable data structures with JSON serialization
- **Middleware**: Cross-cutting concerns (authentication, logging, CORS)
- **Exceptions**: Structured error handling with proper HTTP status codes

### Agent System (`agent-system/`)
AI-powered personalization and coordination using Google's Agent Development Kit:

- **Per-User Agents**: Individual AI agents managing user-specific preferences and interactions
- **Coordinator Agent**: Orchestrates family-wide scheduling, task assignment, and conflict resolution
- **Policy Agent**: Enforces family rules, parental controls, and privacy settings
- **Integration Layer**: Connects agents with Firebase data and external AI services
- **Event Processing**: Handles real-time events and triggers from the API server

## Technology Stack

- **Framework**: [Dart Frog](https://pub.dev/packages/dart_frog) - Fast, minimalist web framework for Dart
- **Language**: Dart 3.0+ with null safety and strong typing
- **Database**: Firebase Firestore (NoSQL document database)
- **Authentication**: Firebase Authentication with custom token validation
- **Deployment**: Google Cloud Run (containerized serverless)
- **Testing**: Built-in Dart test framework with mocking
- **Linting**: `very_good_analysis` for consistent code quality

## Project Structure

```
server/
├── api-server/                # Core REST API service (Dart Frog)
│   ├── lib/
│   │   ├── models/            # Data models and DTOs
│   │   │   ├── user.dart
│   │   │   ├── family_group.dart
│   │   │   └── api_response.dart
│   │   ├── repositories/      # Data access layer
│   │   │   ├── user_repository.dart
│   │   │   └── family_repository.dart
│   │   ├── services/          # Business logic layer
│   │   │   ├── user_service.dart
│   │   │   ├── family_service.dart
│   │   │   └── firebase_service.dart
│   │   ├── exceptions/        # Custom exception types
│   │   │   ├── api_exception.dart
│   │   │   ├── validation_exception.dart
│   │   │   └── unauthorized_exception.dart
│   │   └── middleware/        # Cross-cutting concerns
│   │       ├── authentication.dart
│   │       ├── logging.dart
│   │       └── providers.dart
│   ├── routes/                # HTTP route handlers
│   │   ├── api/
│   │   │   ├── users/
│   │   │   │   ├── index.dart # GET/POST /api/users
│   │   │   │   └── [id].dart  # GET/PUT/DELETE /api/users/:id
│   │   │   └── families/
│   │   │       ├── index.dart # GET/POST /api/families
│   │   │       └── [id]/
│   │   │           ├── index.dart # GET/PUT/DELETE /api/families/:id
│   │   │           └── members/
│   │   │               └── index.dart # POST/DELETE /api/families/:id/members
│   │   └── health/
│   │       └── index.dart     # GET /health
│   ├── test/                  # Test files mirroring lib/ structure
│   ├── pubspec.yaml          # API server dependencies
│   ├── analysis_options.yaml # Linting rules
│   └── README.md             # API server documentation
├── agent-system/             # AI agent orchestration (Google ADK)
│   ├── src/
│   │   ├── agents/           # Individual agent implementations
│   │   │   ├── user_agent.py
│   │   │   ├── coordinator_agent.py
│   │   │   └── policy_agent.py
│   │   ├── services/         # Agent support services
│   │   │   ├── firebase_client.py
│   │   │   ├── ai_studio_client.py
│   │   │   └── event_processor.py
│   │   ├── models/           # Data models for agent system
│   │   │   ├── agent_state.py
│   │   │   ├── family_context.py
│   │   │   └── personalization.py
│   │   └── utils/            # Shared utilities
│   │       ├── logging.py
│   │       └── config.py
│   ├── tests/                # Agent system tests
│   ├── requirements.txt      # Python dependencies
│   ├── pyproject.toml        # Python project configuration
│   └── README.md             # Agent system documentation
├── shared/                   # Shared configurations and utilities
│   ├── firebase.json         # Firebase configuration
│   ├── firestore.rules       # Firestore security rules
│   └── deployment/           # Deployment configurations
│       ├── api-server.yaml   # Cloud Run config for API server
│       └── agent-system.yaml # Cloud Run config for agent system
└── README.md                 # This file (overall infrastructure)
```

## Core Features

### User Management
- **User Registration**: Create new users with automatic family group assignment
- **Profile Management**: Update user profiles with permission-based access control
- **Permission System**: Hierarchical permissions (Primary, Adult, Child) with role-based access
- **Authentication**: Firebase ID token validation with request context injection

### Family Group Management
- **Family Creation**: Automatic family group creation for primary users
- **Member Management**: Add/remove family members with proper authorization
- **Permission Control**: Family-level permission management and inheritance
- **Data Isolation**: Strict family-level data separation and access control

### API Design
- **RESTful Endpoints**: Standard HTTP methods with consistent URL patterns
- **JSON API**: Structured request/response format with proper error handling
- **Validation**: Comprehensive input validation with detailed error messages
- **Documentation**: OpenAPI/Swagger compatible endpoint documentation

## Development Setup

### Prerequisites
- Dart SDK 3.0 or higher
- Python 3.11+ (for agent system)
- Firebase CLI (for local emulator)
- Google Cloud SDK (for deployment)
- Google ADK CLI (for agent development)

### Local Development

1. **Setup API Server**
   ```bash
   cd server/api-server
   dart pub get
   ```

2. **Setup Agent System**
   ```bash
   cd server/agent-system
   pip install -r requirements.txt
   ```

3. **Start Firebase Emulator**
   ```bash
   cd server/shared
   firebase emulators:start --only firestore,auth
   ```

4. **Run API Server**
   ```bash
   cd server/api-server
   dart_frog dev
   ```

5. **Run Agent System**
   ```bash
   cd server/agent-system
   python -m src.main
   ```

The API server will be available at `http://localhost:8080` and the agent system will run as background services.

### Environment Configuration

Create a `.env` file in the server directory:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY_ID=your-private-key-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=your-service-account@your-project.iam.gserviceaccount.com
FIREBASE_CLIENT_ID=your-client-id
FIREBASE_AUTH_URI=https://accounts.google.com/o/oauth2/auth
FIREBASE_TOKEN_URI=https://oauth2.googleapis.com/token

# Server Configuration
PORT=8080
LOG_LEVEL=INFO
ENVIRONMENT=development

# Development Only
USE_FIREBASE_EMULATOR=true
FIRESTORE_EMULATOR_HOST=localhost:8080
AUTH_EMULATOR_HOST=localhost:9099
```

## API Documentation

### Authentication
All API endpoints (except `/health`) require Firebase ID token authentication:

```http
Authorization: Bearer <firebase-id-token>
```

### User Endpoints

#### Create User
```http
POST /api/users
Content-Type: application/json

{
  "displayName": "John Doe",
  "email": "john@example.com",
  "permissionLevel": "primary"
}
```

#### Get Current User Profile
```http
GET /api/users/me
Authorization: Bearer <token>
```

#### Update User Permissions
```http
PUT /api/users/{userId}/permissions
Content-Type: application/json
Authorization: Bearer <token>

{
  "permissionLevel": "adult"
}
```

### Family Endpoints

#### Get Family Group
```http
GET /api/families/me
Authorization: Bearer <token>
```

#### Add Family Member
```http
POST /api/families/{familyId}/members
Content-Type: application/json
Authorization: Bearer <token>

{
  "displayName": "Jane Doe",
  "email": "jane@example.com",
  "permissionLevel": "child"
}
```

#### Remove Family Member
```http
DELETE /api/families/{familyId}/members/{userId}
Authorization: Bearer <token>
```

### Error Responses

All errors follow a consistent format:

```json
{
  "error": {
    "message": "Validation failed",
    "code": "VALIDATION_ERROR",
    "field": "email",
    "details": "Email address is required"
  },
  "meta": {
    "timestamp": "2025-01-10T14:30:00Z",
    "requestId": "req_123456"
  }
}
```

## Testing

### Running Tests
```bash
# Run all tests
dart test

# Run tests with coverage
dart test --coverage=coverage
dart pub global activate coverage
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
```

### Test Structure
- **Unit Tests**: Service and repository logic testing with mocked dependencies
- **Integration Tests**: HTTP endpoint testing with test Firebase emulator
- **Widget Tests**: Not applicable for server-side code

### Test Categories
- `test/models/` - Model serialization and validation tests
- `test/services/` - Business logic and service integration tests
- `test/repositories/` - Data access layer tests with mocked Firestore
- `test/routes/` - HTTP endpoint integration tests
- `test/middleware/` - Authentication and middleware tests

## Deployment

### Google Cloud Run Deployment

Both subsystems deploy independently to Cloud Run:

1. **Deploy API Server**
   ```bash
   cd server/api-server
   gcloud run deploy staccato-api-server \
     --source . \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated \
     --set-env-vars ENVIRONMENT=production
   ```

2. **Deploy Agent System**
   ```bash
   cd server/agent-system
   gcloud run deploy staccato-agent-system \
     --source . \
     --platform managed \
     --region us-central1 \
     --no-allow-unauthenticated \
     --set-env-vars ENVIRONMENT=production
   ```

### Production Configuration
- **Scaling**: Automatic scaling from 0 to 100 instances
- **Memory**: 512Mi per instance (configurable)
- **CPU**: 1 vCPU per instance
- **Timeout**: 300 seconds for long-running operations
- **Concurrency**: 80 requests per instance

## Monitoring and Observability

### Logging
- **Structured Logging**: JSON format with request correlation IDs
- **Log Levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL
- **Google Cloud Logging**: Automatic integration with Cloud Run
- **Request Tracing**: Full request lifecycle tracking

### Metrics
- **Response Times**: P50, P95, P99 latency tracking
- **Error Rates**: HTTP status code distribution
- **Throughput**: Requests per second monitoring
- **Resource Usage**: CPU, memory, and connection pool metrics

### Health Checks
- **Basic Health**: `GET /health` - Simple alive check
- **Detailed Health**: `GET /api/health` - Database connectivity and service status
- **Readiness**: Container readiness for traffic routing
- **Liveness**: Container health for restart decisions

## Security

### Authentication & Authorization
- **Firebase ID Tokens**: Stateless JWT-based authentication
- **Permission Levels**: Hierarchical role-based access control
- **Family Isolation**: Strict data separation between family groups
- **Request Validation**: Comprehensive input sanitization and validation

### Security Headers
- **CORS**: Configurable cross-origin resource sharing
- **Rate Limiting**: Per-user and per-IP request throttling
- **Input Sanitization**: XSS and injection attack prevention
- **HTTPS Only**: TLS encryption for all communications

## License

This project is part of the Staccato family management system. See the main project README for license information.