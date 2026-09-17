import '../../domain/repositories/feedback_repository.dart';

/// Request model for the **Search Feedback Event** API.
///
/// Per Lableb's REST API docs (docs.lableb.com/docs/cse/rest/feedback/
/// search-feedback), the endpoint is
/// `POST /v2/projects/{platformName}/indices/{indexName}/search/{handler}/feedback/events`,
/// it authenticates with an `apikey` query parameter that must carry `Search`
/// permission, and the events themselves travel as a **JSON array body** — not
/// as query string parameters.
class SearchFeedbackEventRequest {
  /// Project name on the Lableb dashboard (the SDK's `platformName`).
  final String platformName;

  /// Index name (the SDK's `indexName`, `index` by default).
  final String indexName;

  /// Search handler name (defaults to `default`).
  final String handler;

  /// The search query.
  final String query;

  /// Event type (purchase/add_to_cart/click).
  final SearchFeedbackEventType eventType;

  /// The id of the clicked result.
  final String itemId;

  /// The index of the clicked result starting from 1.
  final int itemOrder;

  /// The price of the item.
  final double? itemPrice;

  /// The url of the clicked result.
  final String? url;

  /// A unique identifier for a user session.
  final String? sessionId;

  /// A unique identifier for a user.
  final String? userId;

  /// User IP address.
  final String? userIp;

  /// User country code.
  final String? userCountry;

  SearchFeedbackEventRequest({
    required this.platformName,
    required this.indexName,
    this.handler = 'default',
    required this.query,
    required this.eventType,
    required this.itemId,
    required this.itemOrder,
    this.itemPrice,
    this.url,
    this.sessionId,
    this.userId,
    this.userIp,
    this.userCountry,
  }) : assert(itemOrder >= 1, 'itemOrder must be >= 1');

  /// Builds the request path.
  String buildPath() {
    return '/v2/projects/$platformName/indices/$indexName/search/$handler'
        '/feedback/events';
  }

  /// Builds the single event object sent inside the JSON array body.
  Map<String, dynamic> toEventJson() {
    return {
      'event_type': eventType.toApiValue(),
      'query': query,
      'item_id': itemId,
      'item_order': itemOrder,
      if (itemPrice != null) 'item_price': itemPrice,
      if (url != null && url!.isNotEmpty) 'url': url,
      if (sessionId != null && sessionId!.isNotEmpty) 'session_id': sessionId,
      if (userId != null && userId!.isNotEmpty) 'user_id': userId,
      if (userIp != null && userIp!.isNotEmpty) 'user_ip': userIp,
      if (userCountry != null && userCountry!.isNotEmpty)
        'country': userCountry,
    };
  }

  /// The request body: the docs specify an array of event objects.
  List<Map<String, dynamic>> toBody() => [toEventJson()];
}
