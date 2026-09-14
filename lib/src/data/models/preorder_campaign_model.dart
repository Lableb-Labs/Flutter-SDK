import '../../domain/entities/preorder_campaign_entity.dart';

/// Data model for a Zid pre-order campaign attached to a product.
///
/// See https://docs.zid.sa/add-preorder-support-to-your-theme-2132176m0
class PreorderCampaignModel {
  final String? id;
  final String? name;
  final String? badgeText;
  final bool showCountdown;
  final String? releaseNote;
  final String? stockBehavior;
  final DateTime? startDate;
  final DateTime? endDate;

  const PreorderCampaignModel({
    this.id,
    this.name,
    this.badgeText,
    this.showCountdown = false,
    this.releaseNote,
    this.stockBehavior,
    this.startDate,
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

  /// Parses a campaign directly attached to a product from the flat,
  /// `preorder_campaign_`-prefixed fields the search/autocomplete API
  /// returns on the product document itself (no nested campaign object).
  ///
  /// Returns null when none of those fields are present.
  static PreorderCampaignModel? fromFlatJson(Map<String, dynamic> data) {
    const prefixedKeys = [
      'preorder_campaign_id',
      'preorder_campaign_name',
      'preorder_campaign_badge_text',
      'preorder_campaign_release_note',
      'preorder_campaign_stock_behavior',
      'preorder_campaign_start_date',
      'preorder_campaign_end_date',
      'preorder_campaign_show_countdown',
    ];
    if (!prefixedKeys.any(data.containsKey)) return null;

    return PreorderCampaignModel(
      id: data['preorder_campaign_id']?.toString(),
      name: data['preorder_campaign_name'] as String?,
      badgeText: data['preorder_campaign_badge_text'] as String?,
      showCountdown: data['preorder_campaign_show_countdown'] as bool? ?? false,
      releaseNote: data['preorder_campaign_release_note'] as String?,
      stockBehavior: data['preorder_campaign_stock_behavior'] as String?,
      startDate: data['preorder_campaign_start_date'] != null
          ? DateTime.tryParse(data['preorder_campaign_start_date'].toString())
          : null,
      endDate: data['preorder_campaign_end_date'] != null
          ? DateTime.tryParse(data['preorder_campaign_end_date'].toString())
          : null,
    );
  }

  PreorderCampaign toEntity() => PreorderCampaign(
        id: id,
        name: name,
        badgeText: badgeText,
        showCountdown: showCountdown,
        releaseNote: releaseNote,
        stockBehavior: stockBehavior,
        startDate: startDate,
        endDate: endDate,
      );

  factory PreorderCampaignModel.fromEntity(PreorderCampaign entity) {
    return PreorderCampaignModel(
      id: entity.id,
      name: entity.name,
      badgeText: entity.badgeText,
      showCountdown: entity.showCountdown,
      releaseNote: entity.releaseNote,
      stockBehavior: entity.stockBehavior,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }
}
