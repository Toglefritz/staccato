# Staccato API Server

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Dart Frog](https://img.shields.io/endpoint?url=https://tinyurl.com/dartfrog-badge)](https://dart-frog.dev)

The REST API server for the Staccato family management system, built with Dart Frog and deployed on Google Cloud Run.

## Quick Start

1. **Install dependencies**
   ```bash
   dart pub get
   ```

2. **Set up environment**
   ```bash
   cp .env.example .env
   # Edit .env with your Firebase configuration
   ```

3. **Start Firebase emulator** (in a separate terminal)
   ```bash
   cd ../shared
   firebase emulators:start --only firestore,auth
   ```

4. **Run the development server**
   ```bash
   dart_frog dev
   ```

The server will be available at `http://localhost:8080`.

## Project Structure

- `lib/models/` - Data models and DTOs
- `lib/services/` - Business logic layer
- `lib/repositories/` - Data access layer
- `lib/exceptions/` - Custom exception types
- `lib/middleware/` - Cross-cutting concerns
- `lib/config/` - Configuration management
- `routes/` - HTTP route handlers
- `test/` - Test files

## API Endpoints

- `GET /health` - Health check
- `POST /api/users` - Create user
- `GET /api/users/me` - Get current user
- `GET /api/families/me` - Get family group
- `POST /api/families/{id}/members` - Add family member

See the main server README for complete API documentation.

[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis