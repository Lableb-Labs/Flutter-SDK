import '../../domain/entities/preorder_campaign_entity.dart';

/// Data model for a Zid pre-order campaign attached to a product.
///
/// See https://docs.zid.sa/add-preorder-support-to-your-theme-2132176m0
class PreorderCampaignModel {
  final String? badgeText;
  final bool showCountdown;
  final String? releaseNote;
  final DateTime? endDate;

  const PreorderCampaignModel({
    this.badgeText,
    this.showCountdown = false,
    this.releaseNote,
    this.endDate,
  });

  /// Parses a campaign object, or returns null when [json] isn't a map
  /// (e.g. the product has no attached campaign).
  static PreorderCampaignModel? fromJsonOrNull(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    return PreorderCampaignModel(
      badgeText: json['badge_text'] as String?,
      showCountdown: json['show_countdown'] as bool? ?? false,
      releaseNote: json['release_note'] as String?,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
    );
  }

  PreorderCampaign toEntity() => PreorderCampaign(
        badgeText: badgeText,
        showCountdown: showCountdown,
        releaseNote: releaseNote,
        endDate: endDate,
      );

  factory PreorderCampaignModel.fromEntity(PreorderCampaign entity) {
    return PreorderCampaignModel(
      badgeText: entity.badgeText,
      showCountdown: entity.showCountdown,
      releaseNote: entity.releaseNote,
      endDate: entity.endDate,
    );
  }
}
