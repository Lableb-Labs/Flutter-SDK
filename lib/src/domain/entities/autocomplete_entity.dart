import 'preorder_campaign_entity.dart';

/// Domain entity representing an autocomplete suggestion.
///
/// This entity represents a single autocomplete suggestion returned
/// by the autocomplete API.
class AutocompleteEntity {
  /// The suggested text.
  final String text;

  /// Optional metadata associated with the suggestion.
  final Map<String, dynamic>? metadata;

  /// Relevance score for this suggestion.
  final double? score;

  /// Final theme-safe flag for whether this product can be preordered.
  final bool canBePreordered;

  /// Pre-order campaign directly attached to this product, if any.
  final PreorderCampaign? preorderCampaign;

  /// Pre-order campaign inherited from this product or its parent, if any.
  final PreorderCampaign? effectivePreorderCampaign;

  /// Campaign stock rule, e.g. `IN_STOCK_ONLY` or `OUT_OF_STOCK_ONLY`.
  final String? preorderStockBehavior;

  /// True when a pre-order campaign slot exists and is not exhausted.
  final bool preorderSlotsAvailable;

  AutocompleteEntity({
    required this.text,
    this.metadata,
    this.score,
    this.canBePreordered = false,
    this.preorderCampaign,
    this.effectivePreorderCampaign,
    this.preorderStockBehavior,
    this.preorderSlotsAvailable = false,
  });
}
