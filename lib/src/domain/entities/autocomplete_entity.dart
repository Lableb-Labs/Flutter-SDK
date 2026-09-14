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

  /// True when this product is part of an active pre-order campaign.
  final bool isPreorderCampaign;

  /// True when the product has selectable options (e.g. size, color).
  final bool hasOptions;

  /// True when the product has custom fields.
  final bool hasFields;

  /// Display-ready sale price, pre-formatted by the backend.
  final String? formattedSalePrice;

  AutocompleteEntity({
    required this.text,
    this.metadata,
    this.score,
    this.canBePreordered = false,
    this.preorderCampaign,
    this.effectivePreorderCampaign,
    this.preorderStockBehavior,
    this.preorderSlotsAvailable = false,
    this.isPreorderCampaign = false,
    this.hasOptions = false,
    this.hasFields = false,
    this.formattedSalePrice,
  });
}
