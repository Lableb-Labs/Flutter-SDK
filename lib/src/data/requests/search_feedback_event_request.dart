import '../../domain/repositories/feedback_repository.dart';

/// Request model for **Search Feedback Event** API.
///
/// This request is sent as query string parameters (no JSON body).
class SearchFeedbackEventRequest {
  /// Project name.
  final String project;

  /// Collection name.
  final String collection;

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

  /// Optional API token passed as `token` query string parameter.
  final String? token;

  SearchFeedbackEventRequest({
    required this.project,
    required this.collection,
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
    this.token,
  }) : assert(itemOrder >= 1, 'itemOrder must be >= 1');

  /// Builds the request path.
  String buildPath() {
    return '/api/v1/$project/collections/$collection/search/$handler/feedback/events';
  }

  /// Converts the request to query parameters.
  Map<String, dynamic> toQueryParameters() {
    return {
      'query': query,
      'event_type': eventType.toApiValue(),
      'item_id': itemId,
      'item_order': itemOrder,
      if (itemPrice != null) 'item_price': itemPrice,
      if (url != null && url!.isNotEmpty) 'url': url,
      if (sessionId != null && sessionId!.isNotEmpty) 'session_id': sessionId,
      if (userId != null && userId!.isNotEmpty) 'user_id': userId,
      if (userIp != null && userIp!.isNotEmpty) 'user_ip': userIp,
      if (userCountry != null && userCountry!.isNotEmpty)
        'user_country': userCountry,
      if (token != null && token!.isNotEmpty) 'token': token,
    };
  }
}

