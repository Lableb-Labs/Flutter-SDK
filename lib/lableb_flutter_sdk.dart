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
///   apiKey: 'your-api-key',
/// );
/// 
/// // Perform a search
/// final results = await sdk.search.search(query: 'example');
/// ```
library lableb_flutter_sdk;

// SDK Core
export 'src/sdk_initializer.dart';
export 'src/di/locator.dart';
export 'src/feedback/search_feedback.dart';
export 'src/feedback/search_feedback_event_builder.dart';
export 'src/feedback/autocomplete_feedback_builder.dart';
export 'src/feedback/recommender_feedback_builder.dart';
export 'src/feedback/legacy_search_feedback_builder.dart';

export 'src/search/search.dart';
export 'src/search/search_request_builder.dart';

export 'src/recommender/recommender.dart';
export 'src/recommender/recommendations_builder.dart';

// Exceptions
export 'src/exceptions/exceptions.dart';

// Core Models
export 'src/core/pagination_model.dart';

// Domain Entities
export 'src/domain/entities/index_entity.dart';
export 'src/domain/entities/search_entity.dart';
export 'src/domain/entities/autocomplete_entity.dart';
export 'src/domain/entities/recommender_entity.dart';
export 'src/domain/entities/feedback_entity.dart';

// Domain Repositories (Abstract Interfaces)
export 'src/domain/repositories/index_repository.dart';
export 'src/domain/repositories/search_repository.dart';
export 'src/domain/repositories/autocomplete_repository.dart';
export 'src/domain/repositories/recommender_repository.dart';
export 'src/domain/repositories/feedback_repository.dart';

// Data Models
export 'src/data/models/index_model.dart';
export 'src/data/models/search_model.dart';
export 'src/data/models/autocomplete_model.dart';
export 'src/data/models/recommender_model.dart';
export 'src/data/models/feedback_model.dart';

// Data Requests
export 'src/data/requests/index_request.dart';
export 'src/data/requests/search_request.dart';
export 'src/data/requests/autocomplete_request.dart';
export 'src/data/requests/recommender_request.dart';
export 'src/data/requests/feedback_request.dart';

// Data Responses
export 'src/data/responses/index_response.dart';
export 'src/data/responses/search_response.dart';
export 'src/data/responses/autocomplete_response.dart';
export 'src/data/responses/recommender_response.dart';
export 'src/data/responses/feedback_response.dart';
export 'src/data/responses/feedback_event_response.dart';
export 'src/data/requests/search_feedback_event_request.dart';

// API Client (for advanced usage)
export 'src/api/api_client.dart';
export 'src/api/interceptors/auth_interceptor.dart';

