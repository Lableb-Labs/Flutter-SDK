import '../../domain/repositories/feedback_repository.dart';

/// Base class for feedback events with common functionality.
abstract class BaseFeedbackEvent {
  /// Type of interaction event (click, add_to_cart, purchase).
  final FeedbackEventType eventType;

  BaseFeedbackEvent({
    this.eventType = FeedbackEventType.click,
  });

  /// Converts the event to a JSON map for API submission.
  Map<String, dynamic> toJson();

  /// Builds the JSON with event_type and all optional fields.
  Map<String, dynamic> _buildJson(Map<String, dynamic> optionalFields) {
    final json = {
      'event_type': eventType.toApiValue(),
    };
    // Add all optional fields that are not null
    optionalFields.forEach((key, value) {
      if (value != null) {
        json[key] = value;
      }
    });
    return json;
  }
}

/// Feedback event for search operations.
///
/// Represents user interactions with search results.
class SearchFeedbackEvent extends BaseFeedbackEvent {
  /// The search query.
  final String? query;

  /// ID of the item that received the interaction.
  final String? itemId;

  /// Order position of the item in search results.
  final String? itemOrder;

  /// URL where the interaction occurred.
  final String? url;

  /// Session identifier for tracking user sessions.
  final String? sessionId;

  /// User ID (optional).
  final String? userId;

  /// User IP address.
  final String? userIp;

  /// Country code (e.g., "DE", "US").
  final String? country;

  /// Source of the request (e.g., "web", "mobile").
  final String? requestSource;

  /// Price of the item that received the interaction.
  final String? itemPrice;

  SearchFeedbackEvent({
    FeedbackEventType eventType = FeedbackEventType.click,
    this.query,
    this.itemId,
    this.itemOrder,
    this.url,
    this.sessionId,
    this.userId,
    this.userIp,
    this.country,
    this.requestSource,
    this.itemPrice,
  }) : super(eventType: eventType);

  @override
  Map<String, dynamic> toJson() {
    return _buildJson({
      'query': query,
      'item_id': itemId,
      'item_order': itemOrder,
      'url': url,
      'session_id': sessionId,
      'user_id': userId,
      'user_ip': userIp,
      'country': country,
      'request_source': requestSource,
      'item_price': itemPrice,
    });
  }
}

/// Feedback event for autocomplete operations.
///
/// Represents user interactions with autocomplete suggestions.
class AutocompleteFeedbackEvent extends BaseFeedbackEvent {
  /// The autocomplete query.
  final String? query;

  /// ID of the item that received the interaction.
  final String? itemId;

  /// Order position of the suggestion in results.
  final String? itemOrder;

  /// URL where the interaction occurred.
  final String? url;

  /// Session identifier for tracking user sessions.
  final String? sessionId;

  /// User ID (optional).
  final String? userId;

  /// User IP address.
  final String? userIp;

  /// Country code (e.g., "DE", "US").
  final String? country;

  /// Source of the request (e.g., "web", "mobile").
  final String? requestSource;

  /// Price of the item that received the interaction.
  final String? itemPrice;

  AutocompleteFeedbackEvent({
    FeedbackEventType eventType = FeedbackEventType.click,
    this.query,
    this.itemId,
    this.itemOrder,
    this.url,
    this.sessionId,
    this.userId,
    this.userIp,
    this.country,
    this.requestSource,
    this.itemPrice,
  }) : super(eventType: eventType);

  @override
  Map<String, dynamic> toJson() {
    return _buildJson({
      'query': query,
      'item_id': itemId,
      'item_order': itemOrder,
      'url': url,
      'session_id': sessionId,
      'user_id': userId,
      'user_ip': userIp,
      'country': country,
      'request_source': requestSource,
      'item_price': itemPrice,
    });
  }
}

/// Feedback event for recommendation operations.
///
/// Represents user interactions with recommendations, linking source and target items.
class RecommendFeedbackEvent extends BaseFeedbackEvent {
  /// ID of the source/recommended item.
  final String? sourceId;

  /// Title of the source item.
  final String? sourceTitle;

  /// URL of the source item.
  final String? sourceUrl;

  /// ID of the target item the user interacted with.
  final String? targetId;

  /// Title of the target item.
  final String? targetTitle;

  /// URL of the target item.
  final String? targetUrl;

  /// Order position in the recommendation list.
  final String? itemOrder;

  /// Session identifier for tracking user sessions.
  final String? sessionId;

  /// User ID (optional).
  final String? userId;

  /// User IP address.
  final String? userIp;

  /// Country code (e.g., "DE", "US").
  final String? country;

  /// Source of the request (e.g., "web", "mobile").
  final String? requestSource;

  /// Price of the item that received the interaction.
  final String? itemPrice;

  /// Quantity of the item that received the interaction.
  final String? itemQuantity;

  final String? cartId;

  RecommendFeedbackEvent({
    FeedbackEventType eventType = FeedbackEventType.click,
    this.sourceId,
    this.sourceTitle,
    this.sourceUrl,
    this.targetId,
    this.targetTitle,
    this.targetUrl,
    this.itemOrder,
    this.sessionId,
    this.userId,
    this.userIp,
    this.country,
    this.requestSource,
    this.itemPrice,
    this.itemQuantity,
    this.cartId,
  }) : super(eventType: eventType);

  @override
  Map<String, dynamic> toJson() {
    return _buildJson({
      'source_id': sourceId,
      'source_title': sourceTitle,
      'source_url': sourceUrl,
      'target_id': targetId,
      'target_title': targetTitle,
      'target_url': targetUrl,
      'item_order': itemOrder,
      'session_id': sessionId,
      'user_id': userId,
      'user_ip': userIp,
      'country': country,
      'request_source': requestSource,
      'item_price': itemPrice,
      'item_quantity': itemQuantity,
      'cart_id': cartId,
    });
  }
}
