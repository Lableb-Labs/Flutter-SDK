import '../../domain/entities/global_settings_entity.dart';

/// Response model for the Lableb global settings endpoint.
///
/// Wraps the `{"response": {...}}` envelope returned by
/// `GET /v2/projects/{platformName}/settings`.
class SettingsResponse {
  final bool showOutofStackProducts;
  final bool hasRecommendation;
  final bool disableQuantityFilter;

  /// `searchAPIKey`, or null when it is missing or empty.
  final String? searchApiKey;

  const SettingsResponse({
    required this.showOutofStackProducts,
    required this.hasRecommendation,
    required this.disableQuantityFilter,
    this.searchApiKey,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>? ?? const {};
    final searchApiKey = (response['searchAPIKey'] as String?)?.trim();
    return SettingsResponse(
      showOutofStackProducts:
          response['showOutofStackProducts'] as bool? ?? false,
      hasRecommendation: response['hasRecommendation'] as bool? ?? false,
      disableQuantityFilter:
          response['disableQuantityFilter'] as bool? ?? false,
      searchApiKey:
          searchApiKey == null || searchApiKey.isEmpty ? null : searchApiKey,
    );
  }

  GlobalSettings toEntity() => GlobalSettings(
        showOutofStackProducts: showOutofStackProducts,
        hasRecommendation: hasRecommendation,
        disableQuantityFilter: disableQuantityFilter,
        searchApiKey: searchApiKey,
      );
}
