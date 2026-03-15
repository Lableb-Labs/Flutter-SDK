# Lableb Flutter SDK - Project Structure

## Complete Folder Structure

```
lableb_flutter_sdk/
├── lib/
│   ├── lableb_flutter_sdk.dart          # Main export file
│   └── src/
│       ├── api/
│       │   ├── api_client.dart           # HTTP client wrapper with error handling
│       │   └── interceptors/
│       │       ├── auth_interceptor.dart # Authentication interceptor
│       │       └── logging_interceptor.dart # Request/response logging
│       ├── core/
│       │   └── pagination_model.dart      # Pagination data model
│       ├── data/
│       │   ├── models/                   # Data models (DTOs)
│       │   │   ├── index_model.dart
│       │   │   ├── search_model.dart
│       │   │   ├── autocomplete_model.dart
│       │   │   ├── recommender_model.dart
│       │   │   └── feedback_model.dart
│       │   ├── requests/                 # Request models
│       │   │   ├── index_request.dart
│       │   │   ├── search_request.dart
│       │   │   ├── autocomplete_request.dart
│       │   │   ├── recommender_request.dart
│       │   │   └── feedback_request.dart
│       │   ├── responses/                 # Response models
│       │   │   ├── index_response.dart
│       │   │   ├── search_response.dart
│       │   │   ├── autocomplete_response.dart
│       │   │   ├── recommender_response.dart
│       │   │   └── feedback_response.dart
│       │   └── repositories/             # Repository implementations
│       │       ├── index_repository_impl.dart
│       │       ├── search_repository_impl.dart
│       │       ├── autocomplete_repository_impl.dart
│       │       ├── recommender_repository_impl.dart
│       │       └── feedback_repository_impl.dart
│       ├── domain/
│       │   ├── entities/                 # Domain entities
│       │   │   ├── index_entity.dart
│       │   │   ├── search_entity.dart
│       │   │   ├── autocomplete_entity.dart
│       │   │   ├── recommender_entity.dart
│       │   │   └── feedback_entity.dart
│       │   └── repositories/              # Abstract repository interfaces
│       │       ├── index_repository.dart
│       │       ├── search_repository.dart
│       │       ├── autocomplete_repository.dart
│       │       ├── recommender_repository.dart
│       │       └── feedback_repository.dart
│       ├── exceptions/
│       │   └── exceptions.dart           # Custom exception classes
│       └── sdk_initializer.dart           # Main SDK initialization class
├── example/
│   └── main.dart                         # Complete usage examples
├── pubspec.yaml                          # Package dependencies
├── analysis_options.yaml                 # Linter configuration
├── .gitignore                            # Git ignore rules
├── README.md                              # Documentation
└── PROJECT_STRUCTURE.md                  # This file
```

## Architecture Layers

### 1. Domain Layer (`lib/src/domain/`)
- **Entities**: Pure business objects, no dependencies on data sources
- **Repositories**: Abstract interfaces defining contracts for data operations

### 2. Data Layer (`lib/src/data/`)
- **Models**: Data Transfer Objects (DTOs) for API communication
- **Requests**: Request payload models
- **Responses**: Response payload models
- **Repositories**: Concrete implementations of domain repository interfaces

### 3. API Layer (`lib/src/api/`)
- **ApiClient**: HTTP client wrapper using Dio
- **Interceptors**: Request/response interceptors for auth and logging

### 4. Core Layer (`lib/src/core/`)
- **Utilities**: Shared utilities like pagination models

### 5. Exceptions (`lib/src/exceptions/`)
- **Custom Exceptions**: Domain-specific exception classes

## API Endpoints Implemented

### ✅ Index/Data Ingestion
- `POST /index` - Index a single item
- `POST /index/batch` - Index multiple items
- `PUT /index/:id` - Update an indexed item
- `DELETE /index/:id` - Delete an indexed item

### ✅ Search
- `GET /search` - Perform search with query, filters, sorting, and pagination

### ✅ Autocomplete
- `GET /autocomplete` - Get autocomplete suggestions

### ✅ Recommender
- `POST /recommender` - Get personalized recommendations

### ✅ Feedback
- `POST /feedback/search` - Submit search feedback
- `POST /feedback/autocomplete` - Submit autocomplete feedback
- `POST /feedback/recommender` - Submit recommender feedback

## Key Features

### ✅ Error Handling
- `NetworkException` - Network connectivity issues
- `TimeoutException` - Request timeouts
- `UnauthorizedException` - 401 errors
- `ForbiddenException` - 403 errors
- `NotFoundException` - 404 errors
- `ValidationException` - 400 errors
- `ServerException` - 5xx errors
- `GeneralException` - Other errors

### ✅ Authentication
- Bearer token authentication (default)
- API key authentication
- Custom header authentication

### ✅ Features
- Full null safety
- Strong typing throughout
- Comprehensive documentation
- Request/response logging (debug mode)
- Configurable timeouts
- Pagination support
- Filtering and sorting
- Batch operations

## Usage Example

```dart
import 'package:lableb_flutter_sdk/lableb_flutter_sdk.dart';

// Initialize SDK
final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKey: 'your-api-key',
);

// Index data
await sdk.index.indexItem(item);

// Search
final results = await sdk.search.search(query: 'example');

// Autocomplete
final suggestions = await sdk.autocomplete.getSuggestions(query: 'ex');

// Recommendations
final recommendations = await sdk.recommender.getRecommendations(userId: 'user-1');

// Feedback
await sdk.feedback.submitSearchFeedback(
  query: 'example',
  resultId: 'item-1',
  feedbackValue: 'positive',
);
```

## Dependencies

- `dio: ^5.4.0` - HTTP client
- `json_annotation: ^4.8.1` - JSON serialization annotations

## Development Dependencies

- `build_runner: ^2.4.7` - Code generation
- `json_serializable: ^6.7.1` - JSON serialization code generation
- `lints: ^3.0.0` - Linter rules

## File Count

- **Total Dart Files**: 35
- **Domain Layer**: 10 files
- **Data Layer**: 20 files
- **API Layer**: 3 files
- **Core Layer**: 1 file
- **Exceptions**: 1 file

## Code Quality

- ✅ Full null safety
- ✅ No linter errors
- ✅ Comprehensive documentation comments
- ✅ Type-safe throughout
- ✅ Clean Architecture principles
- ✅ SOLID principles
- ✅ Repository pattern
- ✅ Production-ready

