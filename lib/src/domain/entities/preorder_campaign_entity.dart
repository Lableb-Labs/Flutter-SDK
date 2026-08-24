/// A Zid pre-order campaign attached to a product.
///
/// See https://docs.zid.sa/add-preorder-support-to-your-theme-2132176m0
class PreorderCampaign {
  /// Text displayed on the storefront pre-order badge.
  final String? badgeText;

  /// Whether the countdown timer should be shown for this campaign.
  final bool showCountdown;

  /// Optional messaging text displayed alongside the countdown.
  final String? releaseNote;

  /// Campaign expiration timestamp.
  final DateTime? endDate;

  const PreorderCampaign({
    this.badgeText,
    this.showCountdown = false,
    this.releaseNote,
    this.endDate,
  });
}
