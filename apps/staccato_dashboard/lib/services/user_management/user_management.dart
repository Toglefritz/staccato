/// User Management Service Library
///
/// This library provides a comprehensive user management system for the Staccato dashboard application. It includes
/// models, services, and exceptions for handling user accounts, documents, and related operations.
///
/// The library is designed to work with the Staccato API server and provides a clean, type-safe interface for all
/// user management operations.
library;

// ignore_for_file: directives_ordering

// Export models
export 'models/user.dart';
export 'models/user_create_request.dart';
export 'models/user_permission_level.dart';

// Export exceptions
export 'exceptions/user_document_creation_exception.dart';
export 'exceptions/user_document_deletion_exception.dart';
export 'exceptions/user_not_authenticated_exception.dart';
export 'exceptions/user_retrieval_exception.dart';
export 'exceptions/user_service_exception.dart';
export 'exceptions/user_service_network_exception.dart';

// Export main service
export 'user_management_service.dart';
