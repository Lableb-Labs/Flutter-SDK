# Lableb Flutter SDK

A production-ready Flutter SDK for integrating with the Lableb platform. This SDK provides a clean, type-safe interface to all Lableb API endpoints including search, autocomplete, recommendations, indexing, and feedback.

## Features

✅ **Complete API Coverage**
- Index/Data ingestion
- Search with filtering, sorting, and pagination
- Autocomplete suggestions
- Personalized recommendations
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

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  lableb_flutter_sdk: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Initialize the SDK

```dart
import 'package:lableb_flutter_sdk/lableb_flutter_sdk.dart';

final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKey: 'your-api-key-here',
  enableLogging: true, // Optional: for debugging
);
```

### 2. Index Data

```dart
final item = IndexEntity(
  id: 'item-1',
  data: {
    'title': 'Example Product',
    'description': 'Product description',
    'price': 99.99,
  },
);

await sdk.index.indexItem(item);
```

### 3. Perform Search

```dart
final result = await sdk
    .searchRequest()
    .forQuery('product')
    .withFilters({'category': 'electronics'})
    .paginate(page: 1, pageSize: 10)
    .send();

print('Found ${result.totalResults} results');
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

for (final suggestion in suggestions) {
  print(suggestion.text);
}
```

### 5. Get Recommendations

```dart
final recommendations = await sdk
    .recommendations()
    .fromUser('user-123')
    .limit(10)
    .send();

for (final rec in recommendations) {
  print('${rec.id}: ${rec.data['title']}');
}
```

### 6. Submit Feedback

```dart
// Search feedback events (click/add_to_cart/purchase) using the fluent builder
await sdk
    .searchFeedbackEvent()
    .forCollection(project: 'wptest', collection: 'posts', handler: 'default')
    .forQuery('product')
    .event(SearchFeedbackEventType.click)
    .forItem(id: 'item-1', order: 1, price: 95.5)
    .withUrl('http://mysite.com/posts/clicked-document')
    .fromUser(
      id: '1',
      sessionId: '1c4Hb23',
      ip: '192.111.24.21',
      country: 'DE',
    )
    .send();

// Autocomplete feedback
await sdk
    .autocompleteFeedback()
    .forQuery('prod')
    .forSuggestion('product')
    .value('clicked')
    .send();

// Recommender feedback
await sdk
    .recommenderFeedback()
    .forRecommendation('item-2')
    .value('positive')
    .fromUser(id: 'user-123')
    .send();
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

### Custom Authentication

```dart
final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKey: 'your-api-key',
  authType: AuthType.apiKey, // or AuthType.bearer (default)
  customHeaderName: 'X-API-Key', // for custom headers
);
```

### Custom Timeouts

```dart
final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKey: 'your-api-key',
  connectTimeout: const Duration(seconds: 60),
  receiveTimeout: const Duration(seconds: 60),
  sendTimeout: const Duration(seconds: 60),
);
```

### Default Headers

```dart
final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKey: 'your-api-key',
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

