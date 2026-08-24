import '../../domain/entities/autocomplete_entity.dart';
import 'preorder_campaign_model.dart';

/// Data model representing an autocomplete suggestion.
///
/// This model is used for serialization/deserialization when
/// communicating with the API.
class AutocompleteModel {
  /// The suggested text.
  final String text;

  /// Optional metadata associated with the suggestion.
  final Map<String, dynamic>? metadata;

  /// Relevance score for this suggestion.
  final double? score;

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

  AutocompleteModel({
    required this.text,
    this.metadata,
    this.score,
    this.canBePreordered = false,
    this.preorderCampaign,
    this.effectivePreorderCampaign,
    this.preorderStockBehavior,
    this.preorderSlotsAvailable = false,
  });

  /// Creates an [AutocompleteModel] from a JSON map.
  ///
  /// Lableb's real suggestion items are flat product documents with no
  /// `text` field — `name` is used as the suggestion text, and the whole
  /// item (minus text/score) becomes [metadata] when no explicit
  /// `metadata` key is present.
  ///
  /// Pre-order fields (see
  /// https://docs.zid.sa/add-preorder-support-to-your-theme-2132176m0) are
  /// read straight out of that same flat document.
  factory AutocompleteModel.fromJson(Map<String, dynamic> json) {
    final metadata = json['metadata'] is Map<String, dynamic>
        ? json['metadata'] as Map<String, dynamic>
        : (Map<String, dynamic>.from(json)
          ..remove('text')
          ..remove('name')
          ..remove('score'));

    return AutocompleteModel(
      text: json['text'] as String? ??
          json['name'] as String? ??
          json['title'] as String? ??
          '',
      metadata: metadata,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      canBePreordered: metadata['can_be_preordered'] as bool? ?? false,
      preorderCampaign: PreorderCampaignModel.fromJsonOrNull(
          metadata['preorder_campaign']),
      effectivePreorderCampaign: PreorderCampaignModel.fromJsonOrNull(
          metadata['effective_preorder_campaign']),
      preorderStockBehavior: metadata['preorder_stock_behavior'] as String?,
      preorderSlotsAvailable:
          metadata['preorder_slots_available'] as bool? ?? false,
    );
  }

  /// Converts the [AutocompleteModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      if (metadata != null) 'metadata': metadata,
      if (score != null) 'score': score,
    };
  }

  /// Converts the model to a domain entity.
  AutocompleteEntity toEntity() {
    return AutocompleteEntity(
      text: text,
      metadata: metadata,
      score: score,
      canBePreordered: canBePreordered,
      preorderCampaign: preorderCampaign?.toEntity(),
      effectivePreorderCampaign: effectivePreorderCampaign?.toEntity(),
      preorderStockBehavior: preorderStockBehavior,
      preorderSlotsAvailable: preorderSlotsAvailable,
    );
  }

  /// Creates a model from a domain entity.
  factory AutocompleteModel.fromEntity(AutocompleteEntity entity) {
    return AutocompleteModel(
      text: entity.text,
      metadata: entity.metadata,
      score: entity.score,
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
