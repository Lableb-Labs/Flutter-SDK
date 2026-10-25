/// Merchant-level Lableb dashboard settings that affect SDK behavior.
///
/// Fetched once at SDK initialization from Lableb's settings endpoint.
class GlobalSettings {
  /// When false/unset, search and autocomplete results are restricted to
  /// in-stock products (`is_available=true&quantity_from=1`).
  final bool showOutofStackProducts;

  /// When false/unset, the recommender feature is disabled.
  final bool hasRecommendation;

  /// When true, search and autocomplete requests omit the `quantity_from`
  /// filter (independent of [showOutofStackProducts]'s `is_available` filter).
  final bool disableQuantityFilter;

  /// The project's search API key (`searchAPIKey`), used by the SDK when the
  /// app does not pass its own `apiKey`. Null when the endpoint omits it.
  final String? searchApiKey;

  const GlobalSettings({
    this.showOutofStackProducts = false,
    this.hasRecommendation = false,
    this.disableQuantityFilter = false,
    this.searchApiKey,
  });

  /// Represents the "not fetched yet" / "fetch failed" state, matching
  /// Lableb's own documented false/unset semantics for both fields.
  const GlobalSettings.unset() : this();
}
