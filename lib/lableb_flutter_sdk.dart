/// Lableb Flutter SDK
///
/// A production-ready Flutter SDK for integrating with the Lableb platform.
///
/// This SDK provides a clean, type-safe interface to all Lableb API endpoints
/// including search, autocomplete, recommendations, indexing, and feedback.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:lableb_flutter_sdk/lableb_flutter_sdk.dart';
///
/// // Initialize the SDK
/// final sdk = LablebSDK(
///   baseUrl: 'https://api.lableb.com',
///   apiKeySearch: 'your-search-api-key',
///   apiKeyIndex: 'your-index-api-key',
///   projectId: 'your_project_name',
///   indexName: 'your_index_name',
/// );
///
/// // Perform a search
/// final results = await sdk.search.search(query: 'example');
/// ```
library lableb_flutter_sdk;

// SDK Core
export 'src/sdk_initializer.dart';
export 'src/di/locator.dart';

// Exceptions
export 'src/exceptions/exceptions.dart';

// Domain Entities
export 'src/domain/entities/document_entity.dart';

// Domain Repositories (Abstract Interfaces)
export 'src/domain/repositories/index_repository.dart';
export 'src/domain/repositories/search_repository.dart';
export 'src/domain/repositories/autocomplete_repository.dart';
export 'src/domain/repositories/recommender_repository.dart';
export 'src/domain/repositories/feedback_repository.dart';

// Data Models
export 'src/data/models/document_model.dart';
export 'src/data/models/facet_model.dart';
export 'src/data/models/suggested_filters_model.dart';
export 'src/data/models/feedback_event_model.dart';

// Data Requests
export 'src/data/requests/search_request.dart';
export 'src/data/requests/autocomplete_request.dart';
export 'src/data/requests/recommender_request.dart';

// Data Responses
export 'src/data/responses/matching_response.dart';

// API Client (for advanced usage)
export 'src/api/api_client.dart';
