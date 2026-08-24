import 'preorder_campaign_entity.dart';

/// Domain entity representing a search result.
///
/// This entity represents a single result returned from a search query.
class SearchEntity {
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
  final PreorderCampaign? preorderCampaign;

  /// Pre-order campaign inherited from this product or its parent, if any.
  final PreorderCampaign? effectivePreorderCampaign;

  /// Campaign stock rule, e.g. `IN_STOCK_ONLY` or `OUT_OF_STOCK_ONLY`.
  final String? preorderStockBehavior;

  /// True when a pre-order campaign slot exists and is not exhausted.
  final bool preorderSlotsAvailable;

  SearchEntity({
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
}
