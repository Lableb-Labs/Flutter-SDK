import '../../domain/repositories/feedback_repository.dart';

/// Request model for the **Recommendation Feedback Event** API.
///
/// Per Lableb's REST API docs (docs.lableb.com/docs/cse/rest/feedback/
/// recommendation-feedback), the endpoint is
/// `POST /v2/projects/{platformName}/indices/{indexName}/recommend/{handler}/feedback/events`,
/// it authenticates with an `apikey` query parameter that must carry `Search`
/// permission, and the events themselves travel as a **JSON array body** — not
/// as query string parameters.
///
/// This event reports that a user moved from one document to another that was
/// recommended alongside it, so it is shaped differently from the search and
/// autocomplete events: [sourceId] and [targetId] replace `item_id`, there is
/// no `query`, and [eventType] is optional.
class RecommendFeedbackEventRequest {
  /// Project name on the Lableb dashboard (the SDK's `platformName`).
  final String platformName;

  /// Index name (the SDK's `indexName`, `index` by default).
  final String indexName;

  /// Recommendation handler name (defaults to `default`).
  final String handler;

  /// The id of the document the recommendation was shown on.
  final String sourceId;

  /// The id of the recommended document the user moved to.
  final String targetId;

  /// Event type (purchase/add_to_cart/click). Optional per the docs.
  final SearchFeedbackEventType? eventType;

  /// The title of the source document.
  final String? sourceTitle;

  /// The url of the source document.
  final String? sourceUrl;

  /// The title of the target document.
  final String? targetTitle;

  /// The url of the target document.
  final String? targetUrl;

  /// The index of the clicked recommendation starting from 1.
  final int? itemOrder;

  /// The individual unit price of the target item.
  final double? itemPrice;

  /// The number of units selected for the target item.
  final int? itemQuantity;

  /// Unique identifier for the user's current shopping session.
  final String? cartId;

  /// A unique identifier for a user session.
  final String? sessionId;

  /// A unique identifier for a user.
  final String? userId;

  /// User IP address.
  final String? userIp;

  /// User country code.
  final String? userCountry;

  /// Originating platform (`web`, `mobile`, `ios`, ...).
  final String? requestSource;

  RecommendFeedbackEventRequest({
    required this.platformName,
    required this.indexName,
    this.handler = 'default',
    required this.sourceId,
    required this.targetId,
    this.eventType,
    this.sourceTitle,
    this.sourceUrl,
    this.targetTitle,
    this.targetUrl,
    this.itemOrder,
    this.itemPrice,
    this.itemQuantity,
    this.cartId,
    this.sessionId,
    this.userId,
    this.userIp,
    this.userCountry,
    this.requestSource,
  }) : assert(itemOrder == null || itemOrder >= 1, 'itemOrder must be >= 1');

  /// Builds the request path.
  ///
  /// The path segment is `recommend`, even though the SDK's builder and
  /// repository accessor are named *recommender*. This is not a typo and must
  /// not be "corrected": `recommendation`, `recommendations` and `recommender`
  /// all return 404.
  String buildPath() {
    return '/v2/projects/$platformName/indices/$indexName/recommend/$handler'
        '/feedback/events';
  }

  /// Builds the single event object sent inside the JSON array body.
  ///
  /// Note the absence of `query`, `item_id` and `url`: none of the three are
  /// part of this endpoint's documented payload.
  Map<String, dynamic> toEventJson() {
    return {
      if (eventType != null) 'event_type': eventType!.toApiValue(),
      'source_id': sourceId,
      'target_id': targetId,
      if (sourceTitle != null && sourceTitle!.isNotEmpty)
        'source_title': sourceTitle,
      if (sourceUrl != null && sourceUrl!.isNotEmpty) 'source_url': sourceUrl,
      if (targetTitle != null && targetTitle!.isNotEmpty)
        'target_title': targetTitle,
      if (targetUrl != null && targetUrl!.isNotEmpty) 'target_url': targetUrl,
      if (itemOrder != null) 'item_order': itemOrder,
      if (itemPrice != null) 'item_price': itemPrice,
      if (itemQuantity != null) 'item_quantity': itemQuantity,
      if (cartId != null && cartId!.isNotEmpty) 'cart_id': cartId,
      if (sessionId != null && sessionId!.isNotEmpty) 'session_id': sessionId,
      if (userId != null && userId!.isNotEmpty) 'user_id': userId,
      if (userIp != null && userIp!.isNotEmpty) 'user_ip': userIp,
      if (userCountry != null && userCountry!.isNotEmpty)
        'country': userCountry,
      if (requestSource != null && requestSource!.isNotEmpty)
        'request_source': requestSource,
    };
  }

  /// The request body: the docs specify an array of event objects.
  List<Map<String, dynamic>> toBody() => [toEventJson()];
}
