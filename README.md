# Lableb Flutter SDK

A Flutter SDK for the [Lableb](https://lableb.com) search platform. It provides
typed access to search, autocomplete, recommendations, indexing, and feedback,
plus a turnkey integration path for Zid merchant apps.

## Features

- **Fluent, step-validated builders** for search, recommendations, and all
  feedback endpoints — required fields are enforced by the type system.
- **Zid / AppsBunches integration** via a single `LablebSDK.init()` call, including
  sandbox routing, encrypted token storage, and merchant global settings.
- **Pre-order support** — campaign, options, fields, and formatted sale price
  attributes on search and autocomplete results.
- **Drop-in recommendations widget**, page-route analytics, and cart event hooks.
- **Typed error handling** with a single `LablebException` base class.
- **Clean-architecture layering** — domain entities and abstract repositories over
  a data layer of models, requests, and responses, wired through `get_it`.
- Full null safety, configurable timeouts, and request/response logging.

## Installation

```yaml
dependencies:
  lableb_flutter_sdk: ^1.0.0
```

```bash
flutter pub get
```

```dart
import 'package:lableb_flutter_sdk/lableb_flutter_sdk.dart';
```

## Getting started

The SDK has two entry points. Pick the one that matches your integration.

### Option A — `LablebSDK.init()` (preferred for merchant integrations)

Zid and AppsBunches hand your app a configuration payload. Pass it straight
through: the SDK derives the base URL, selects the sandbox when appropriate,
persists the token in encrypted storage, and fetches the merchant's global
settings.

```dart
await LablebSDK.init(
  initialJson: {
    'status': true,               // master switch; false disables the SDK
    'app_key': 'your-app-key',    // required
    'token': 'merchant-token',
    'primary_color': '#FF6600',
    'store_id': '56705',
    'sandbox': false,
  },
);

if (LablebSDK.isEnabled) {
  final sdk = LablebSDK.instance;
  // ...
}
```

If `status` is `false` or `app_key` is missing or empty, the SDK stays disabled
and `LablebSDK.isEnabled` reports `false` — no exception. Token-storage and
settings-fetch failures are swallowed too, so a device without secure storage or
without connectivity still initializes.

Field *types*, however, are not defensive: `status` and `sandbox` must be real
booleans and `app_key` a real string. A JSON payload that sends `"status":
"true"` or a numeric `app_key` throws a `TypeError`. If the payload comes from a
source you do not control, coerce it first or wrap the call:

```dart
try {
  await LablebSDK.init(initialJson: payload);
} catch (_) {
  // treat as disabled
}
```

Reading `LablebSDK.instance` before a successful `init` throws a `StateError`, so
gate on `isEnabled`.

### Option B — direct construction

```dart
final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKey: 'your-api-key',
  indexName: 'index',        // defaults to 'index'
  platformName: 'zid_56705', // optional; enables global settings fetch
  enableLogging: true,
);
```

Only `baseUrl` and `apiKey` are required.

Supplying `platformName` starts the merchant global-settings fetch, but the
constructor **does not wait for it** — it is fire-and-forget, because a Dart
constructor cannot be `async`. Until it resolves, every flag in
[Global settings](#global-settings) reads `false`. `LablebSDK.init()` awaits the
same fetch, which is why it is the better choice when those flags gate your UI.
If you need the flags right after direct construction, poll
`LablebSDK.hasRecommendation` or defer the dependent render by a frame.

## Search

```dart
final result = await sdk
    .searchRequest()
    .forQuery('laptop')
    .withFilters({'brand': 'Dell'})
    .sortBy('price', direction: 'asc')
    .paginate(page: 1, pageSize: 10)
    .send();

print('${result.totalResults} results in ${result.executionTime}ms');

for (final item in result.results) {
  print('${item.id}: ${item.data['title']} (score ${item.score})');
}

if (result.pagination.canGoNext) {
  // fetch page 2
}
```

`sortBy` is a convenience for a single field. For multi-field sorting use
`withSort({'price': 'asc', 'rating': 'desc'})`. To target a non-default search
handler configured on your Lableb dashboard, add `.withHandler('my-handler')`.

`send()` returns a `SearchResult` with `results` (`List<SearchEntity>`),
`pagination`, `totalResults`, and `executionTime`.

## Autocomplete

```dart
final suggestions = await sdk.autocomplete.getSuggestions(
  query: 'lap',
  limit: 5,
);

for (final suggestion in suggestions) {
  print('${suggestion.text} (${suggestion.score})');
}
```

## Recommendations

```dart
final recommendations = await sdk
    .recommendations()
    .forItem('item-1')
    .limit(10)
    .withContext({'page': 'product_detail'})
    .send();

for (final rec in recommendations) {
  print('${rec.id}: ${rec.reason}');
}
```

Start the builder with `forItem(id)`, `fromUser(id)`, or
`fromUserForItem(userId: ..., itemId: ...)` — at least one signal is required.

> **Recommendations are gated on `LablebSDK.hasRecommendation`.** When that flag
> is `false`, `send()` returns an empty list immediately and never calls the API.
> The flag is `false` not only when the merchant has the recommender disabled in
> the Lableb dashboard, but also whenever global settings have not been fetched —
> which is the case if you constructed the SDK directly without `platformName`,
> or if you call `send()` before the fetch resolves. Silently empty results here
> almost always mean the flag, not the query.

Check `LablebSDK.hasRecommendation` before rendering if you need to hide the UI
entirely. The same gate applies to `LablebSDK.recommendationsWidget()`, which
renders nothing rather than reporting an error.

## Feedback

Feedback is what trains ranking, so send it for every meaningful interaction.

### Search feedback events (click / add to cart / purchase)

```dart
await sdk
    .searchFeedbackEvent()
    .forCollection(project: 'wptest', collection: 'posts')
    .forQuery('laptop')
    .event(SearchFeedbackEventType.click)
    .forItem(id: 'item-1', order: 1, price: 95.5)
    .fromUser(id: 'user-123', sessionId: '1c4Hb23', country: 'DE')
    .send();
```

`order` is the item's 1-based position in the result list. The available event
types are `SearchFeedbackEventType.click`, `.addToCart`, and `.purchase`.
Optional steps: `.withUrl(...)`, `.withToken(...)`, and a `handler` argument on
`forCollection`.

To inspect the payload without hitting the network — useful in tests — call
`.build()` instead of `.send()`.

### Autocomplete feedback

```dart
await sdk
    .autocompleteFeedback()
    .forQuery('lap')
    .forSuggestion('laptop')
    .value('clicked')
    .fromUser(id: 'user-123')
    .send();
```

### Recommender feedback

```dart
await sdk
    .recommenderFeedback()
    .forRecommendation('item-2')
    .value('positive')
    .fromUser(id: 'user-123')
    .send();
```

### Legacy search feedback

Prefer `searchFeedbackEvent()`. This endpoint remains for existing integrations:

```dart
await sdk
    .legacySearchFeedback()
    .forQuery('laptop')
    .forResult('item-1')
    .value('positive')
    .send();
```

## Indexing

Indexing takes `IndexEntity` objects, not raw maps.

```dart
await sdk.index.indexItem(
  IndexEntity(
    id: 'item-1',
    data: {
      'title': 'Example Product',
      'description': 'Product description',
      'price': 99.99,
    },
  ),
);

await sdk.index.indexBatch([
  IndexEntity(id: 'item-2', data: {'title': 'Second Product'}),
  IndexEntity(id: 'item-3', data: {'title': 'Third Product'}),
]);

await sdk.index.updateItem(
  IndexEntity(id: 'item-1', data: {'price': 89.99}),
);

await sdk.index.deleteItem('item-1');
```

## Merchant features

### Global settings

Merchant-level toggles are fetched once at initialization and exposed as static
getters. They default to `false` when the fetch has not happened or failed.

```dart
LablebSDK.hasRecommendation;      // recommender feature enabled
LablebSDK.showOutOfStockProducts; // include out-of-stock products in results
LablebSDK.disableQuantityFilter;  // omit the quantity_from filter
```

### Recommendations widget

A horizontally scrolling product strip that resolves its own data and renders
nothing when recommendations are unavailable:

```dart
LablebSDK.recommendationsWidget(productId: 'item-1')
```

### Page route tracking

```dart
await LablebSDK.trackPageRoute(pageName: 'product_detail');
```

### Cart event handlers

Let Lableb-rendered widgets drive your app's cart:

```dart
await LablebSDK.registerCartEventHandlers(
  onAddToCart: (productId, quantity) {
    // add to your cart
  },
  onRemoveFromCart: (productId) {
    // remove from your cart
  },
);
```

## Pre-order fields

Search and autocomplete results carry Zid pre-order attributes:

```dart
for (final item in result.results) {
  if (item.canBePreordered && item.preorderSlotsAvailable) {
    final campaign = item.effectivePreorderCampaign ?? item.preorderCampaign;
    print('${campaign?.badgeText} — ends ${campaign?.endDate}');
  }

  if (item.hasOptions) { /* show the variant picker */ }
  if (item.formattedSalePrice != null) { /* show the sale price */ }
}
```

`PreorderCampaign` exposes `id`, `name`, `badgeText`, `showCountdown`,
`releaseNote`, `stockBehavior`, `startDate`, and `endDate`.

## Error handling

Every SDK error extends `LablebException`, which carries `message`,
`statusCode`, and `details`. Catch the specific types first:

```dart
try {
  await sdk.searchRequest().forQuery('laptop').send();
} on UnauthorizedException catch (e) {
  print('Check your API key: ${e.message}');
} on ForbiddenException catch (e) {
  print('Forbidden: ${e.message}');
} on NotFoundException catch (e) {
  print('Not found: ${e.message}');
} on ValidationException catch (e) {
  print('Bad request: ${e.message} ${e.details}');
} on TimeoutException catch (e) {
  print('Timed out: ${e.message}');
} on NetworkException catch (e) {
  print('Network error: ${e.message}');
} on ServerException catch (e) {
  print('Server error ${e.statusCode}: ${e.message}');
} on LablebException catch (e) {
  print('Lableb error: ${e.message}');
}
```

The final `on LablebException` clause is not decorative: HTTP status codes
outside 400/401/403/404/5xx, and cancelled requests, surface as
`GeneralException`, which only that clause catches.

> `TimeoutException` shadows the `dart:async` class of the same name. If you
> import both libraries, alias one of them.

## Advanced configuration

### Timeouts

```dart
final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKey: 'your-api-key',
  connectTimeout: const Duration(seconds: 60),
  receiveTimeout: const Duration(seconds: 60),
  sendTimeout: const Duration(seconds: 60),
);
```

### Authentication style and custom headers

```dart
final sdk = LablebSDK(
  baseUrl: 'https://api.lableb.com',
  apiKey: 'your-api-key',
  authType: AuthType.custom,        // bearer (default), apiKey, or custom
  customHeaderName: 'X-Lableb-Key',
  defaultHeaders: {'X-Tenant': 'acme'},
);
```

### Service locator

All services are registered in a `get_it` container exported as `locator`.
Resolve a repository or builder directly when you need to bypass the `LablebSDK`
facade — useful for injecting fakes in tests:

```dart
final repository = locator<SearchRepository>();
```

## Architecture

```
lib/
├── lableb_flutter_sdk.dart
└── src/
    ├── analytics/        # Page-route tracking builder and service
    ├── api/              # Dio client, interceptors, settings client
    ├── cart/             # Cart event bus and handler builder
    ├── core/             # Shared models (pagination)
    ├── data/             # Models, repository impls, requests, responses
    ├── di/               # get_it locator and SDK options
    ├── domain/           # Entities and abstract repositories
    ├── exceptions/       # LablebException hierarchy
    ├── feedback/         # Feedback builders and extensions
    ├── recommender/      # Recommendations builder and extension
    ├── search/           # Search request builder and extension
    ├── ui/               # LablebRecommendationWidget
    ├── zid/              # Zid config and encrypted token storage
    └── sdk_initializer.dart
```

## API reference

### Builder entry points (extensions on `LablebSDK`)

Each entry point returns a builder; the type below is what its terminal
`.send()` resolves to.

| Entry point | `.send()` resolves to |
| --- | --- |
| `searchRequest()` | `Future<SearchResult>` |
| `recommendations()` | `Future<List<RecommenderEntity>>` |
| `searchFeedbackEvent()` | `Future<void>` (or `SearchFeedbackEventPayload` via `.build()`) |
| `autocompleteFeedback()` | `Future<void>` |
| `recommenderFeedback()` | `Future<void>` |
| `legacySearchFeedback()` | `Future<void>` |

### Static members on `LablebSDK`

`init()`, `instance`, `isEnabled`, `hasRecommendation`, `showOutOfStockProducts`,
`disableQuantityFilter`, `trackPageRoute()`, `registerCartEventHandlers()`,
`recommendationsWidget()`.

### Repositories

- `IndexRepository` — `indexItem`, `indexBatch`, `updateItem`, `deleteItem`
- `AutocompleteRepository` — `getSuggestions`
- `SearchRepository` — `search` *(deprecated: use `searchRequest()`)*
- `RecommenderRepository` — `getRecommendations` *(deprecated: use `recommendations()`)*
- `FeedbackRepository` — `submitSearchFeedbackEvent`, `submitSearchFeedback`,
  `submitAutocompleteFeedback`, `submitRecommenderFeedback`
  *(all deprecated: use the feedback builders)*
- `SettingsRepository` — `getSettings`

The deprecated repository methods still work and are what the builders call
internally. They are marked deprecated because the builders validate required
fields at compile time; expect them to be removed in a future major version.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request at
[Lableb-Labs/Flutter-SDK](https://github.com/Lableb-Labs/Flutter-SDK).

## License

MIT. See [LICENSE](LICENSE).

## Support

For issues, questions, or feature requests, open an issue on
[GitHub](https://github.com/Lableb-Labs/Flutter-SDK/issues).
