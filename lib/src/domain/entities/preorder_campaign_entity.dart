/// A Zid pre-order campaign attached to a product.
///
/// See https://docs.zid.sa/add-preorder-support-to-your-theme-2132176m0
class PreorderCampaign {
  /// Unique identifier of the campaign.
  final String? id;

  /// Display name of the campaign.
  final String? name;

  /// Text displayed on the storefront pre-order badge.
  final String? badgeText;

  /// Whether the countdown timer should be shown for this campaign.
  final bool showCountdown;

  /// Optional messaging text displayed alongside the countdown.
  final String? releaseNote;

  /// Campaign stock rule, e.g. `IN_STOCK_ONLY` or `OUT_OF_STOCK_ONLY`.
  final String? stockBehavior;

  /// Campaign start timestamp.
  final DateTime? startDate;

  /// Campaign expiration timestamp.
  final DateTime? endDate;

  const PreorderCampaign({
    this.id,
    this.name,
    this.badgeText,
    this.showCountdown = false,
    this.releaseNote,
    this.stockBehavior,
    this.startDate,
    this.endDate,
  });
}
