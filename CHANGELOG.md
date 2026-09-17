# Changelog

All notable changes to this package are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0

Initial release.

### Added

- Search with filtering, sorting, and pagination.
- Autocomplete suggestions.
- Recommendations.
- Index / data ingestion.
- Feedback submission for search, autocomplete, and recommender.
- Zid integration, including pre-order fields on search and autocomplete
  results and flat pre-order campaign, options, fields, and sale price
  attributes.
- Global settings, including `disableQuantityFilter`.
- Cart and quantity attributes.
- Clean-architecture layering: domain entities and abstract repositories over a
  data layer of models, requests, and responses.
- Typed error handling, request/response logging in debug mode, timeout
  handling, and retry strategies.
