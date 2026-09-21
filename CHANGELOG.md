# Changelog

All notable changes to this package are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

