import '../../domain/entities/search_entity.dart';
import 'preorder_campaign_model.dart';

/// Data model representing a search result.
///
/// This model is used for serialization/deserialization when
/// communicating with the API.
class SearchModel {
  /// Unique identifier of the result.
  final String id;

  /// The result content/data.
  final Map<String, dynamic> data;

  /// Relevance score for this result.
  final double? score;

  /// Highlighted snippets from the search query.
  final Map<String, List<String>>? highlights;

  /// Final theme-safe flag for whether this product can be preordered.
  final bool canBePreordered;

  /// Pre-order campaign directly attached to this product, if any.
  final PreorderCampaignModel? preorderCampaign;

  /// Pre-order campaign inherited from this product or its parent, if any.
  final PreorderCampaignModel? effectivePreorderCampaign;

  /// Campaign stock rule, e.g. `IN_STOCK_ONLY` or `OUT_OF_STOCK_ONLY`.
  final String? preorderStockBehavior;

  /// True when a pre-order campaign slot exists and is not exhausted.
  final bool preorderSlotsAvailable;

  SearchModel({
    required this.id,
    required this.data,
    this.score,
    this.highlights,
    this.canBePreordered = false,
    this.preorderCampaign,
    this.effectivePreorderCampaign,
    this.preorderStockBehavior,
    this.preorderSlotsAvailable = false,
  });

  /// Creates a [SearchModel] from a JSON map.
  ///
  /// Lableb's real search results are flat documents (id, name, price, ...)
  /// with no nested `data` wrapper, so when `data` is absent the whole item
  /// (minus id/score/highlights) is used as the result's data.
  ///
  /// Pre-order fields (see
  /// https://docs.zid.sa/add-preorder-support-to-your-theme-2132176m0) are
  /// read straight out of that same flat document.
  factory SearchModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (Map<String, dynamic>.from(json)
          ..remove('id')
          ..remove('score')
          ..remove('highlights'));

    return SearchModel(
      id: json['id']?.toString() ?? '',
      data: data,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      highlights: json['highlights'] != null
          ? Map<String, List<String>>.from(
              (json['highlights'] as Map).map(
                (key, value) => MapEntry(
                  key as String,
                  List<String>.from(value as List),
                ),
              ),
            )
          : null,
      canBePreordered: data['can_be_preordered'] as bool? ?? false,
      preorderCampaign:
          PreorderCampaignModel.fromJsonOrNull(data['preorder_campaign']),
      effectivePreorderCampaign: PreorderCampaignModel.fromJsonOrNull(
          data['effective_preorder_campaign']),
      preorderStockBehavior: data['preorder_stock_behavior'] as String?,
      preorderSlotsAvailable:
          data['preorder_slots_available'] as bool? ?? false,
    );
  }

  /// Converts the [SearchModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      if (score != null) 'score': score,
      if (highlights != null) 'highlights': highlights,
    };
  }

  /// Converts the model to a domain entity.
  SearchEntity toEntity() {
    return SearchEntity(
      id: id,
      data: data,
      score: score,
      highlights: highlights,
      canBePreordered: canBePreordered,
      preorderCampaign: preorderCampaign?.toEntity(),
      effectivePreorderCampaign: effectivePreorderCampaign?.toEntity(),
      preorderStockBehavior: preorderStockBehavior,
      preorderSlotsAvailable: preorderSlotsAvailable,
    );
  }

  /// Creates a model from a domain entity.
  factory SearchModel.fromEntity(SearchEntity entity) {
    return SearchModel(
      id: entity.id,
      data: entity.data,
      score: entity.score,
      highlights: entity.highlights,
      canBePreordered: entity.canBePreordered,
      preorderCampaign: entity.preorderCampaign != null
          ? PreorderCampaignModel.fromEntity(entity.preorderCampaign!)
          : null,
      effectivePreorderCampaign: entity.effectivePreorderCampaign != null
          ? PreorderCampaignModel.fromEntity(entity.effectivePreorderCampaign!)
          : null,
      preorderStockBehavior: entity.preorderStockBehavior,
      preorderSlotsAvailable: entity.preorderSlotsAvailable,
    );
  }
}
