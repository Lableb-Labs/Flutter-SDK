# Changelog

All notable changes to this package are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- `request_source`, an SDK-wide value sent on search, autocomplete, and
  recommendation requests, and on feedback events that do not set their own
  with `withRequestSource(...)`. It **defaults to `'mobile'`**
  (`LablebSDK.defaultRequestSource`), and passing `null` also gets the
  default. Pass `requestSource: 'web'` for a web app, or `''` to stop sending
  it. Set it with
  `LablebSDK(requestSource: ...)` or `LablebSDK.init(..., requestSource: ...)`.
  `SearchRequest`, `AutocompleteRequest`, and `RecommenderRequest` gain a
  matching optional `requestSource` field. The repository and builder
  interfaces are unchanged.
- `lang`, sent as `lang` on search, autocomplete, and recommendation requests
  and omitted when null or empty. Set it with `LablebSDK(lang: ...)` or
  `LablebSDK.init(..., lang: ...)`, and change it at runtime with
  `LablebSDK.setLang(...)` when the app language changes; the next request
  uses the new value. `LablebSDK.lang` reads the current value. The request
  models gain a matching optional `lang` field.
- `sessionId`, sent as `session_id` on search, autocomplete, and
  recommendation requests and omitted when null or empty. Set it with
  `LablebSDK(sessionId: ...)` or `LablebSDK.init(..., sessionId: ...)`, and
  change it at any time with `LablebSDK.setSessionId(...)`; the next request
  uses the new value. `LablebSDK.sessionId` reads the current value. The
  request models gain a matching optional `sessionId` field. Feedback events
  are unchanged and still take their session per event.
- The API key can come from the project's settings. `apiKey` on
  `LablebSDK(...)` is now optional when `platformName` is set: without it, the
  SDK uses `searchAPIKey` from the Lableb settings endpoint. In
  `LablebSDK.init(...)`, `app_key` is optional the same way, and the SDK stays
  disabled only if settings provide no key either. A key the app passes always
  wins. `GlobalSettings` and `SettingsResponse` gain an optional
  `searchApiKey`, `ApiClient` gains `updateApiKey(...)`, and `AuthInterceptor`
  gains an optional `apiKeyProvider`. With no key, no `Authorization` header is
  sent.

### Changed

- Requests now carry `request_source=mobile` by default, where before they
  carried no `request_source`. No code change is needed to keep working. To
  keep the old wire format, pass `requestSource: ''`.
- Search, autocomplete, recommendation and feedback requests now wait for the
  startup settings fetch started by `LablebSDK(platformName: ...)` before
  sending (`sdkSettingsReady()`). The first request can take one settings
  round-trip longer.

### Fixed

- Requests made right after `LablebSDK(...)` no longer race the settings
  fetch. Before this, they could be sent with the stock filters for unset
  settings (`is_available=true&quantity_from=1`) even when the merchant shows
  out-of-stock products, and recommendations could return an empty list
  before `hasRecommendation` loaded.
- Recommendations now call the documented endpoint,
  `GET /v2/projects/{platformName}/indices/{indexName}/recommend`, with
  `apikey` and the source item as `id` in the query string
  (docs.lableb.com/docs/cse/rest/recommendations). The docs label it `POST`,
  but the live API answers `POST` with `405 Method Not Allowed`. Before this
  they posted a JSON body to `/recommender`, which is not a Lableb route. Filters are
  flattened into query parameters the same way search flattens them. Scalar
  `context` entries such as `user_ip` and `user_country` are sent as-is. The
  merchant's out-of-stock setting applies the same way it does to search.
- The recommendation response is now parsed from Lableb's
  `{"time", "code", "response": {"results": [...]}}` envelope. Each flat
  document's fields land in `RecommenderEntity.data`, so `data['title']` works
  on live results, and numeric ids are read as strings. The old
  `{"recommendations": [...]}` shape still parses.
- Recommendations need an item. `fromUser(...)` without an item, or
  `getRecommendations` without `itemId`, now throws `ValidationException`.
  Before this it failed with an HTTP error. A missing `platformName` also
  throws `ValidationException`, as it does for search. The builder and
  repository interfaces are unchanged.

## 1.0.1

### Changed

- Rewrote `example/main.dart` to match the README. The published example could
  not run: it constructed `LablebSDK` without `platformName` or `indexName`, so
  every call threw `ValidationException`. It also demonstrated indexing (which
  the README withdraws), called `getSuggestions` and `searchFeedbackEvent`
  without an explicit handler, used the deprecated `sdk.search.search` and
  `sdk.recommender.getRecommendations`, and read `item.data['title']`, which is
  null on live documents.

### Fixed

- Enabled the `deprecated_member_use_from_same_package` lint, so the package's
  own deprecations are now visible in-package. Without it, `example/` could call
  deprecated methods with a clean `flutter analyze`.

No library code changed in this release; `lib/` is identical to 1.0.0.

## 1.0.0

Initial release.

### Added

- Search with filtering, sorting, and pagination.
- Autocomplete suggestions.
- Recommendations.
- Index / data ingestion.
- Feedback events for search, autocomplete and recommendations, posted to
  the documented v2 endpoints
  (`POST /v2/projects/{project}/indices/{index}/{search|autocomplete|recommend}/{handler}/feedback/events`)
  with `apikey` authentication and a JSON array body.
- Zid integration, including pre-order fields on search and autocomplete
  results and flat pre-order campaign, options, fields, and sale price
  attributes.
- Global settings, including `disableQuantityFilter`.
- Cart and quantity attributes.
- Clean-architecture layering: domain entities and abstract repositories over a
  data layer of models, requests, and responses.
- Typed error handling, request/response logging in debug mode, timeout
  handling, and retry strategies.

### Fixed

- Search, autocomplete and recommendation feedback each targeted a route that
  does not exist on the Lableb API — `/api/v1/{project}/collections/...` for
  search, `/feedback/autocomplete` and `/feedback/recommender` for the other
  two — and authenticated with a bearer token rather than the `apikey` query
  parameter. Every call was rejected before reaching the service. All three now
  post the documented event array to the v2 endpoints.

