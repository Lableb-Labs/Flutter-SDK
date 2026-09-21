# Lableb Flutter SDK

A production-ready Flutter SDK for integrating with the Lableb platform. This SDK provides a clean, type-safe interface to all Lableb API endpoints including search, autocomplete, recommendations, and feedback.

## Features

✅ **Complete API Coverage**
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
  apiKey: 'your-api-key',
  platformName: 'your-platform-name',
  indexName: 'your-index-name',
  enableLogging: true, // Optional: for debugging
);
```

### 2. Perform Search

```dart
final result = await sdk
    .searchRequest()
    .forQuery('product')
    .withHandler('suggest')
    .withFilters({'category': 'electronics'})
    .sortBy('price', direction: 'asc')
    .paginate(page: 1, pageSize: 10)
    .send();

print('Found ${result.results.length} results');
for (final item in result.results) {
  print('${item.id}: ${item.data['name']}'); // keys come from your index schema
}
```

> **Search handlers.** Every search and autocomplete request runs against a
> *handler* configured on your project's Lableb dashboard. The SDK defaults to
> `'default'`, and a project that is not provisioned with that handler returns
> HTTP 404. Pass the handler your project actually has — `.withHandler(...)` on
> the search builder, `handler:` on `getSuggestions`.

### 3. Get Autocomplete Suggestions

```dart
final suggestions = await sdk.autocomplete.getSuggestions(
  query: 'prod',
  limit: 5,
  handler: 'suggest',
);
```

### 4. Get Recommendations

```dart
final recommendations = await sdk
    .recommendations()
    .forItem('item-1')
    .limit(10)
    .send();
```

### 5. Submit Feedback

Report what a user did with a search result, so the platform can learn from it.
The project and index are taken from the `platformName` and `indexName` you
constructed the SDK with, so there is nothing extra to supply.

```dart
await sdk
    .searchFeedbackEvent()
    .forQuery('product')
    .event(SearchFeedbackEventType.click)
    .forItem(id: 'item-1', order: 1)
    .withHandler('suggest')
    .fromUser(id: 'user-123', sessionId: 'session-123')
    .send();
```

`event(...)` accepts `click`, `addToCart` and `purchase`.

Autocomplete feedback reports which suggestion the user took for the prefix
they typed. The suggestion is identified by `forItem`, exactly as a search
result is:

```dart
await sdk
    .autocompleteFeedback()
    .forQuery('samsu')
    .event(SearchFeedbackEventType.click)
    .forItem(id: '153-ar', order: 4)
    .withHandler('suggest')
    .fromUser(id: '2313', sessionId: '1c4CqE')
    .send();
```

Recommendation feedback reports that a user moved from one document to another
recommended alongside it. It is the one feedback endpoint that takes a
source/target pair instead of a query:

```dart
await sdk
    .recommenderFeedback()
    .forRecommendation(sourceId: '153-en', targetId: '154-ar')
    .event(SearchFeedbackEventType.click)
    .atOrder(2)
    .withHandler('suggest')
    .send();
```

All three accept the same optional commerce and attribution fields —
`withCart(...)`, `withRequestSource(...)`, `fromUser(...)`, and a `quantity` on
the item — and all three default to the `default` handler. Set
`withHandler(...)` to whatever your project is provisioned with: a project that
only has a `suggest` handler returns 404 on `default`, exactly as it does for
search.

## Error Handling

The SDK provides comprehensive error handling with custom exception types:

```dart
try {
  await sdk.searchRequest().forQuery('example').withHandler('suggest').send();
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on UnauthorizedException catch (e) {
  print('Unauthorized: ${e.message}');
} on ForbiddenException catch (e) {
  print('Forbidden: ${e.message}');
} on NotFoundException catch (e) {
  print('Not found: ${e.message}');
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
  apiKey: 'your-api-key',
  platformName: 'your-platform-name',
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
  apiKey: 'your-api-key',
  platformName: 'your-platform-name',
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

### SearchRepository

- `search({required String query, ...})` - Perform a search with optional
  filters, sorting, and pagination. **Deprecated** - use `sdk.searchRequest()`.

### AutocompleteRepository

- `getSuggestions({required String query, ...})` - Get autocomplete suggestions

### RecommenderRepository

- `getRecommendations({String? userId, String? itemId, ...})` - Get
  recommendations. **Deprecated** - use `sdk.recommendations()`.

### FeedbackRepository

- `submitSearchFeedbackEvent(...)` - Submit search feedback events
  (click/add_to_cart/purchase). **Deprecated** - use `sdk.searchFeedbackEvent()`.
- `submitAutocompleteFeedbackEvent(...)` - Submit autocomplete feedback events.
  **Deprecated** - use `sdk.autocompleteFeedback()`.
- `submitRecommendFeedbackEvent(...)` - Submit recommendation feedback events
  (source item -> target item). **Deprecated** - use
  `sdk.recommenderFeedback()`.
- `submitSearchFeedback(...)` - Legacy search feedback. **Deprecated** - use
  `sdk.searchFeedbackEvent()`.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

For issues, questions, or feature requests, please open an issue on GitHub.
