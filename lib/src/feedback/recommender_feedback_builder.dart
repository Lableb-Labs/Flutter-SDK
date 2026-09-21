import 'package:get_it/get_it.dart';

import '../domain/repositories/feedback_repository.dart';

/// Entry point step for building and sending a Recommendation Feedback Event.
///
/// The project and index segments of the endpoint come from the `platformName`
/// and `indexName` given to `LablebSDK`, so there is nothing to supply here.
abstract interface class RecommenderFeedbackBuilderStart {
  /// Identifies the recommendation the user acted on.
  ///
  /// [sourceId] is the document the recommendation was shown on and
  /// [targetId] is the recommended document the user moved to. They are the
  /// only two fields this endpoint requires.
  RecommenderFeedbackBuilderEvent forRecommendation({
    required String sourceId,
    required String targetId,
  });
}

abstract interface class RecommenderFeedbackBuilderEvent {
  /// Records the kind of interaction.
  ///
  /// Optional: the API accepts a recommendation event without it.
  RecommenderFeedbackBuilderReady event(SearchFeedbackEventType type);

  /// Records the position of the clicked recommendation, counting from 1.
  RecommenderFeedbackBuilderReady atOrder(
    int order, {
    double? price,
    int? quantity,
  });

  /// Describes the document the recommendation was shown on.
  RecommenderFeedbackBuilderReady withSourceDetails({
    String? title,
    String? url,
  });

  /// Describes the recommended document the user moved to.
  RecommenderFeedbackBuilderReady withTargetDetails({
    String? title,
    String? url,
  });

  /// Overrides the recommendation handler (defaults to `default`).
  ///
  /// A project provisioned only with a named handler returns 404 on
  /// `default`, so set this to whatever the project uses.
  RecommenderFeedbackBuilderReady withHandler(String handler);

  /// Ties this event to the user's current shopping session.
  RecommenderFeedbackBuilderReady withCart(String cartId);

  /// Records the originating platform (`web`, `mobile`, `ios`, ...).
  RecommenderFeedbackBuilderReady withRequestSource(String source);

  RecommenderFeedbackBuilderReady fromUser({
    String? id,
    String? sessionId,
    String? ip,
    String? country,
  });

  /// Sends the event through the SDK repository resolved from the locator.
  Future<void> send();

  /// Builds the request by delegating to the repository method parameters.
  ///
  /// This is useful for testing and debugging; it does not hit the network.
  RecommenderFeedbackEventPayload build();
}

/// Immutable payload produced by the builder.
class RecommenderFeedbackEventPayload {
  final String handler;
  final String sourceId;
  final String targetId;
  final SearchFeedbackEventType? eventType;
  final String? sourceTitle;
  final String? sourceUrl;
  final String? targetTitle;
  final String? targetUrl;
  final int? itemOrder;
  final double? itemPrice;
  final int? itemQuantity;
  final String? cartId;
  final String? sessionId;
  final String? userId;
  final String? userIp;
  final String? userCountry;
  final String? requestSource;

  const RecommenderFeedbackEventPayload({
    required this.handler,
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
  });
}

/// Fluent builder for Recommendation Feedback events.
///
/// This is a step builder: the two required ids are enforced at compile-time
/// by only exposing `.send()` after `forRecommendation(...)`.
class RecommenderFeedbackBuilder
    implements
        RecommenderFeedbackBuilderStart,
        RecommenderFeedbackBuilderEvent,
        RecommenderFeedbackBuilderReady {
  String _handler = 'default';
  String? _sourceId;
  String? _targetId;
  SearchFeedbackEventType? _eventType;
  String? _sourceTitle;
  String? _sourceUrl;
  String? _targetTitle;
  String? _targetUrl;
  int? _itemOrder;
  double? _itemPrice;
  int? _itemQuantity;
  String? _cartId;
  String? _sessionId;
  String? _userId;
  String? _userIp;
  String? _userCountry;
  String? _requestSource;

  @override
  RecommenderFeedbackBuilderEvent forRecommendation({
    required String sourceId,
    required String targetId,
  }) {
    assert(sourceId.trim().isNotEmpty, 'sourceId is required');
    assert(targetId.trim().isNotEmpty, 'targetId is required');
    _sourceId = sourceId;
    _targetId = targetId;
    return this;
  }

  @override
  RecommenderFeedbackBuilderReady event(SearchFeedbackEventType type) {
    _eventType = type;
    return this;
  }

  @override
  RecommenderFeedbackBuilderReady atOrder(
    int order, {
    double? price,
    int? quantity,
  }) {
    assert(order >= 1, 'item order must be >= 1');
    assert(quantity == null || quantity >= 1, 'item quantity must be >= 1');
    _itemOrder = order;
    _itemPrice = price;
    _itemQuantity = quantity;
    return this;
  }

  @override
  RecommenderFeedbackBuilderReady withSourceDetails({
    String? title,
    String? url,
  }) {
    _sourceTitle = title;
    _sourceUrl = url;
    return this;
  }

  @override
  RecommenderFeedbackBuilderReady withTargetDetails({
    String? title,
    String? url,
  }) {
    _targetTitle = title;
    _targetUrl = url;
    return this;
  }

  @override
  RecommenderFeedbackBuilderReady withHandler(String handler) {
    assert(handler.trim().isNotEmpty, 'handler cannot be empty');
    _handler = handler;
    return this;
  }

  @override
  RecommenderFeedbackBuilderReady withCart(String cartId) {
    assert(cartId.trim().isNotEmpty, 'cartId cannot be empty');
    _cartId = cartId;
    return this;
  }

  @override
  RecommenderFeedbackBuilderReady withRequestSource(String source) {
    assert(source.trim().isNotEmpty, 'request source cannot be empty');
    _requestSource = source;
    return this;
  }

  @override
  RecommenderFeedbackBuilderReady fromUser({
    String? id,
    String? sessionId,
    String? ip,
    String? country,
  }) {
    _userId = id;
    _sessionId = sessionId;
    _userIp = ip;
    _userCountry = country;
    return this;
  }

  @override
  RecommenderFeedbackEventPayload build() {
    final sourceId = _sourceId;
    final targetId = _targetId;

    assert(
      sourceId != null && sourceId.trim().isNotEmpty,
      'sourceId is required',
    );
    assert(
      targetId != null && targetId.trim().isNotEmpty,
      'targetId is required',
    );

    return RecommenderFeedbackEventPayload(
      handler: _handler,
      sourceId: sourceId!,
      targetId: targetId!,
      eventType: _eventType,
      sourceTitle: _sourceTitle,
      sourceUrl: _sourceUrl,
      targetTitle: _targetTitle,
      targetUrl: _targetUrl,
      itemOrder: _itemOrder,
      itemPrice: _itemPrice,
      itemQuantity: _itemQuantity,
      cartId: _cartId,
      sessionId: _sessionId,
      userId: _userId,
      userIp: _userIp,
      userCountry: _userCountry,
      requestSource: _requestSource,
    );
  }

  @override
  Future<void> send() async {
    final payload = build();

    // Enforce locator-based execution.
    final repo = GetIt.instance<FeedbackRepository>();
    // ignore: deprecated_member_use_from_same_package
    await repo.submitRecommendFeedbackEvent(
      handler: payload.handler,
      sourceId: payload.sourceId,
      targetId: payload.targetId,
      eventType: payload.eventType,
      sourceTitle: payload.sourceTitle,
      sourceUrl: payload.sourceUrl,
      targetTitle: payload.targetTitle,
      targetUrl: payload.targetUrl,
      itemOrder: payload.itemOrder,
      itemPrice: payload.itemPrice,
      itemQuantity: payload.itemQuantity,
      cartId: payload.cartId,
      sessionId: payload.sessionId,
      userId: payload.userId,
      userIp: payload.userIp,
      userCountry: payload.userCountry,
      requestSource: payload.requestSource,
    );
  }
}
