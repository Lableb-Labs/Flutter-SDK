# Lableb Flutter SDK

A production-ready Flutter SDK for integrating with the Lableb platform. This SDK provides a clean, type-safe interface to all Lableb API endpoints including search, autocomplete, recommendations, indexing, and feedback.

## Features

✅ **Complete API Coverage**
- Index/Data ingestion
- Search with filtering, sorting, and pagination
- Autocomplete suggestions
- Recommendations
- Feedback submission (search, autocomplete, recommender)

✅ **Clean Architecture**
- Domain layer with entities and abstract repositories
- Data layer with models, requests, and responses
- Proper separation of concerns
- SOLID principles

✅ **Production Ready**
- Full null safety
- Comprehensive error handling
- Request/response logging (debug mode)
- Timeout handling
- Retry strategies
- Type-safe models with JSON serialization

✅ **Developer Experience**
- Full documentation comments
- Easy-to-use API
- Comprehensive examples
- Strong typing throughout

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  lableb_flutter_sdk:
    path: ../
```

Then run:

```bash
flutter pub get
```

> Note: For publishable packages, replace the local `path` dependency with a hosted version once released.

## Quick Start

### 1. Initialize the SDK

```dart
import 'package:lableb_flutter_sdk/lableb_flutter_sdk.dart';

final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKeySearch: 'your-search-api-key',
  apiKeyIndex: 'your-index-api-key',
  projectId: 'your-project-id',
  indexName: 'your-index-name',
  enableLogging: true, // Optional: for debugging
);
```

### 2. Upload Documents

```dart
await sdk.index.uploadDocuments([
  {
    'id': 'item-1',
    'title': 'Example Product',
    'description': 'Product description',
    'price': 99.99,
  }
]);
```

### 3. Perform Search

```dart
final result = await sdk.search.search(
  query: 'product',
  filters: {'category': 'electronics'},
  sort: 'price asc',
  page: 1,
  pageSize: 10,
);

print('Found ${result.results.length} results');
for (final item in result.results) {
  print('${item.id}: ${item.data['title']}');
}
```

### 4. Get Autocomplete Suggestions

```dart
final suggestions = await sdk.autocomplete.getSuggestions(
  query: 'prod',
  limit: 5,
);
```

### 5. Get Recommendations

```dart
final recommendations = await sdk.recommender.getRecommendations(
  limit: 10,
  itemId: 'user-123',
);
```

### 6. Submit Feedback

```dart
await sdk.feedback.submitSearchFeedbackEvent(
  SearchFeedbackEvent(
    eventType: FeedbackEventType.click,
    query: 'product',
    itemId: 'item-1',
    sessionId: 'session-123',
  ),
);

await sdk.feedback.submitAutocompleteFeedbackEvent(
  AutocompleteFeedbackEvent(
    eventType: FeedbackEventType.click,
    query: 'prod',
    itemId: 'suggestion-1',
  ),
);

await sdk.feedback.submitRecommendFeedbackEvent(
  RecommendFeedbackEvent(
    eventType: FeedbackEventType.addToCart,
    sourceId: 'item-1',
    targetId: 'item-2',
  ),
);
```

## Error Handling

The SDK provides comprehensive error handling with custom exception types:

```dart
try {
  await sdk.search.search(query: 'example');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on UnauthorizedException catch (e) {
  print('Unauthorized: ${e.message}');
} on ValidationException catch (e) {
  print('Validation error: ${e.message}');
} on ServerException catch (e) {
  print('Server error: ${e.message}');
} on TimeoutException catch (e) {
  print('Request timed out: ${e.message}');
} on LablebException catch (e) {
  print('Lableb error: ${e.message}');
}
```

## Advanced Configuration

### Custom Timeouts

```dart
final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKeySearch: 'your-search-api-key',
  apiKeyIndex: 'your-index-api-key',
  projectId: 'your-project-id',
  indexName: 'your-index-name',
  connectTimeout: const Duration(seconds: 60),
  receiveTimeout: const Duration(seconds: 60),
  sendTimeout: const Duration(seconds: 60),
);
```

### Default Headers

```dart
final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKeySearch: 'your-search-api-key',
  apiKeyIndex: 'your-index-api-key',
  projectId: 'your-project-id',
  indexName: 'your-index-name',
  defaultHeaders: {
    'X-Custom-Header': 'value',
  },
);
```

## Architecture

The SDK follows Clean Architecture principles:

```
lib/
├── src/
│   ├── api/              # API client and interceptors
│   ├── core/             # Core utilities (pagination, etc.)
│   ├── data/             # Data layer (models, repositories, requests, responses)
│   ├── domain/           # Domain layer (entities, abstract repositories)
│   ├── exceptions/       # Custom exceptions
│   └── sdk_initializer.dart
└── lableb_flutter_sdk.dart
```

## API Reference

### IndexRepository

- `indexItem(IndexEntity item)` - Index a single item
- `indexBatch(List<IndexEntity> items)` - Index multiple items
- `updateItem(IndexEntity item)` - Update an existing item
- `deleteItem(String id)` - Delete an item

### SearchRepository

- `search({required String query, ...})` - Perform a search with optional filters, sorting, and pagination

### AutocompleteRepository

- `getSuggestions({required String query, ...})` - Get autocomplete suggestions

### RecommenderRepository

- `getRecommendations({String? userId, String? itemId, ...})` - Get recommendations

### FeedbackRepository

- `submitSearchFeedbackEvent(...)` - Submit search feedback events (click/add_to_cart/purchase)
- `submitSearchFeedback(...)` - Legacy search feedback (deprecated)
- `submitAutocompleteFeedback(...)` - Submit feedback for autocomplete
- `submitRecommenderFeedback(...)` - Submit feedback for recommendations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

For issues, questions, or feature requests, please open an issue on GitHub.

