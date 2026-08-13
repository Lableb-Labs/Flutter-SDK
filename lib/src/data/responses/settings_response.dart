import '../../domain/entities/global_settings_entity.dart';

/// Response model for the Lableb global settings endpoint.
///
/// Wraps the `{"response": {...}}` envelope returned by
/// `GET /v2/projects/{platformName}/settings`.
class SettingsResponse {
  final bool showOutofStackProducts;
  final bool hasRecommendation;

  const SettingsResponse({
    required this.showOutofStackProducts,
    required this.hasRecommendation,
  });

  factory SettingsResponse.fromJson(Map<String, dynamic> json) {
    final response = json['response'] as Map<String, dynamic>? ?? const {};
    return SettingsResponse(
      showOutofStackProducts:
          response['showOutofStackProducts'] as bool? ?? false,
      hasRecommendation: response['hasRecommendation'] as bool? ?? false,
    );
  }

  GlobalSettings toEntity() => GlobalSettings(
        showOutofStackProducts: showOutofStackProducts,
        hasRecommendation: hasRecommendation,
      );
}
