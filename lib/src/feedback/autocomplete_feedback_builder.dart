import 'package:get_it/get_it.dart';

import '../domain/repositories/feedback_repository.dart';

/// Entry point step for building and sending an Autocomplete Feedback Event.
///
/// The project and index segments of the endpoint come from the `platformName`
/// and `indexName` given to `LablebSDK`, so there is nothing to supply here.
abstract interface class AutocompleteFeedbackBuilderStart {
  AutocompleteFeedbackBuilderEvent forQuery(String query);
}

/// Step requiring the event type.
abstract interface class AutocompleteFeedbackBuilderEvent {
  AutocompleteFeedbackBuilderItem event(SearchFeedbackEventType type);
}

/// Step requiring the taken suggestion.
abstract interface class AutocompleteFeedbackBuilderItem {
  /// Identifies the suggestion the user took.
  ///
  /// [order] is its position in the suggestion list, counting from 1.
  AutocompleteFeedbackBuilderReady forItem({
    required String id,
    required int order,
    double? price,
    int? quantity,
  });
}

/// Final step: optional enrichment + terminal send/build.
abstract interface class AutocompleteFeedbackBuilderReady {
  /// Overrides the autocomplete handler (defaults to `default`).
  ///
  /// A project provisioned only with a named handler (for example `suggest`)
  /// returns 404 on `default`, so set this to whatever the project uses.
  AutocompleteFeedbackBuilderReady withHandler(String handler);

  AutocompleteFeedbackBuilderReady withUrl(String url);

  /// Ties this event to the user's current shopping session.
  AutocompleteFeedbackBuilderReady withCart(String cartId);

  /// Records the originating platform (`web`, `mobile`, `ios`, ...).
  AutocompleteFeedbackBuilderReady withRequestSource(String source);

  AutocompleteFeedbackBuilderReady fromUser({
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
  AutocompleteFeedbackEventPayload build();
}

/// Immutable payload produced by the builder.
class AutocompleteFeedbackEventPayload {
  final String handler;
  final String query;
  final SearchFeedbackEventType eventType;
  final String itemId;
  final int itemOrder;
  final double? itemPrice;
  final int? itemQuantity;
  final String? cartId;
  final String? url;
  final String? sessionId;
  final String? userId;
  final String? userIp;
  final String? userCountry;
  final String? requestSource;

  const AutocompleteFeedbackEventPayload({
    required this.handler,
    required this.query,
    required this.eventType,
    required this.itemId,
    required this.itemOrder,
    this.itemPrice,
    this.itemQuantity,
    this.cartId,
    this.url,
    this.sessionId,
    this.userId,
    this.userIp,
    this.userCountry,
    this.requestSource,
  });
}

/// Fluent builder for Autocomplete Feedback events.
///
/// This is a step builder: required fields are enforced at compile-time by
/// only exposing `.send()` after mandatory steps are completed.
class AutocompleteFeedbackBuilder
    implements
        AutocompleteFeedbackBuilderStart,
        AutocompleteFeedbackBuilderEvent,
        AutocompleteFeedbackBuilderItem,
        AutocompleteFeedbackBuilderReady {
  String _handler = 'default';
  String? _query;
  SearchFeedbackEventType? _eventType;
  String? _itemId;
  int? _itemOrder;
  double? _itemPrice;
  int? _itemQuantity;

  String? _cartId;
  String? _url;
  String? _sessionId;
  String? _userId;
  String? _userIp;
  String? _userCountry;
  String? _requestSource;

  @override
  AutocompleteFeedbackBuilderEvent forQuery(String query) {
    assert(query.trim().isNotEmpty, 'query is required');
    _query = query;
    return this;
  }

  @override
  AutocompleteFeedbackBuilderItem event(SearchFeedbackEventType type) {
    _eventType = type;
    return this;
  }

  @override
  AutocompleteFeedbackBuilderReady forItem({
    required String id,
    required int order,
    double? price,
    int? quantity,
  }) {
    assert(id.trim().isNotEmpty, 'item id is required');
    assert(order >= 1, 'item order must be >= 1');
    assert(quantity == null || quantity >= 1, 'item quantity must be >= 1');
    _itemId = id;
    _itemOrder = order;
    _itemPrice = price;
    _itemQuantity = quantity;
    return this;
  }

  @override
  AutocompleteFeedbackBuilderReady withHandler(String handler) {
    assert(handler.trim().isNotEmpty, 'handler cannot be empty');
    _handler = handler;
    return this;
  }

  @override
  AutocompleteFeedbackBuilderReady withUrl(String url) {
    assert(url.trim().isNotEmpty, 'url cannot be empty');
    _url = url;
    return this;
  }

  @override
  AutocompleteFeedbackBuilderReady withCart(String cartId) {
    assert(cartId.trim().isNotEmpty, 'cartId cannot be empty');
    _cartId = cartId;
    return this;
  }

  @override
  AutocompleteFeedbackBuilderReady withRequestSource(String source) {
    assert(source.trim().isNotEmpty, 'request source cannot be empty');
    _requestSource = source;
    return this;
  }

  @override
  AutocompleteFeedbackBuilderReady fromUser({
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
  AutocompleteFeedbackEventPayload build() {
    final query = _query;
    final eventType = _eventType;
    final itemId = _itemId;
    final itemOrder = _itemOrder;

    assert(query != null && query.trim().isNotEmpty, 'query is required');
    assert(eventType != null, 'eventType is required');
    assert(itemId != null && itemId.trim().isNotEmpty, 'itemId is required');
    assert(itemOrder != null && itemOrder >= 1, 'itemOrder must be >= 1');

    return AutocompleteFeedbackEventPayload(
      handler: _handler,
      query: query!,
      eventType: eventType!,
      itemId: itemId!,
      itemOrder: itemOrder!,
      itemPrice: _itemPrice,
      itemQuantity: _itemQuantity,
      cartId: _cartId,
      url: _url,
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
    await repo.submitAutocompleteFeedbackEvent(
      handler: payload.handler,
      query: payload.query,
      eventType: payload.eventType,
      itemId: payload.itemId,
      itemOrder: payload.itemOrder,
      itemPrice: payload.itemPrice,
      itemQuantity: payload.itemQuantity,
      cartId: payload.cartId,
      url: payload.url,
      sessionId: payload.sessionId,
      userId: payload.userId,
      userIp: payload.userIp,
      userCountry: payload.userCountry,
      requestSource: payload.requestSource,
    );
  }
}
