import 'package:get_it/get_it.dart';

import '../domain/repositories/feedback_repository.dart';

/// Entry point step for building and sending a Search Feedback Event.
abstract interface class SearchFeedbackEventBuilderStart {
  SearchFeedbackEventBuilderQuery forCollection({
    required String project,
    required String collection,
    String handler,
  });
}

/// Step requiring the search query.
abstract interface class SearchFeedbackEventBuilderQuery {
  SearchFeedbackEventBuilderEvent forQuery(String query);
}

/// Step requiring the event type.
abstract interface class SearchFeedbackEventBuilderEvent {
  SearchFeedbackEventBuilderItem event(SearchFeedbackEventType type);
}

/// Step requiring the item info.
abstract interface class SearchFeedbackEventBuilderItem {
  SearchFeedbackEventBuilderReady forItem({
    required String id,
    required int order,
    double? price,
  });
}

/// Final step: optional enrichment + terminal send/build.
abstract interface class SearchFeedbackEventBuilderReady {
  SearchFeedbackEventBuilderReady withUrl(String url);

  SearchFeedbackEventBuilderReady fromUser({
    String? id,
    String? sessionId,
    String? ip,
    String? country,
  });

  SearchFeedbackEventBuilderReady withToken(String token);

  /// Sends the event through the SDK repository resolved from [locator].
  Future<void> send();

  /// Builds the request by delegating to the repository method parameters.
  ///
  /// This is useful for testing and debugging; it does not hit the network.
  SearchFeedbackEventPayload build();
}

/// Immutable payload produced by the builder.
class SearchFeedbackEventPayload {
  final String project;
  final String collection;
  final String handler;
  final String query;
  final SearchFeedbackEventType eventType;
  final String itemId;
  final int itemOrder;
  final double? itemPrice;
  final String? url;
  final String? sessionId;
  final String? userId;
  final String? userIp;
  final String? userCountry;
  final String? token;

  const SearchFeedbackEventPayload({
    required this.project,
    required this.collection,
    required this.handler,
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
  });
}

/// Fluent builder for Search Feedback events.
///
/// This is a step builder: required fields are enforced at compile-time by
/// only exposing `.send()` after mandatory steps are completed.
class SearchFeedbackEventBuilder
    implements
        SearchFeedbackEventBuilderStart,
        SearchFeedbackEventBuilderQuery,
        SearchFeedbackEventBuilderEvent,
        SearchFeedbackEventBuilderItem,
        SearchFeedbackEventBuilderReady {
  String? _project;
  String? _collection;
  String _handler = 'default';
  String? _query;
  SearchFeedbackEventType? _eventType;
  String? _itemId;
  int? _itemOrder;
  double? _itemPrice;

  String? _url;
  String? _sessionId;
  String? _userId;
  String? _userIp;
  String? _userCountry;
  String? _token;

  @override
  SearchFeedbackEventBuilderQuery forCollection({
    required String project,
    required String collection,
    String handler = 'default',
  }) {
    assert(project.trim().isNotEmpty, 'project is required');
    assert(collection.trim().isNotEmpty, 'collection is required');
    assert(handler.trim().isNotEmpty, 'handler cannot be empty');
    _project = project;
    _collection = collection;
    _handler = handler;
    return this;
  }

  @override
  SearchFeedbackEventBuilderEvent forQuery(String query) {
    assert(query.trim().isNotEmpty, 'query is required');
    _query = query;
    return this;
  }

  @override
  SearchFeedbackEventBuilderItem event(SearchFeedbackEventType type) {
    _eventType = type;
    return this;
  }

  @override
  SearchFeedbackEventBuilderReady forItem({
    required String id,
    required int order,
    double? price,
  }) {
    assert(id.trim().isNotEmpty, 'item id is required');
    assert(order >= 1, 'item order must be >= 1');
    _itemId = id;
    _itemOrder = order;
    _itemPrice = price;
    return this;
  }

  @override
  SearchFeedbackEventBuilderReady withUrl(String url) {
    assert(url.trim().isNotEmpty, 'url cannot be empty');
    _url = url;
    return this;
  }

  @override
  SearchFeedbackEventBuilderReady fromUser({
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
  SearchFeedbackEventBuilderReady withToken(String token) {
    assert(token.trim().isNotEmpty, 'token cannot be empty');
    _token = token;
    return this;
  }

  @override
  SearchFeedbackEventPayload build() {
    final project = _project;
    final collection = _collection;
    final query = _query;
    final eventType = _eventType;
    final itemId = _itemId;
    final itemOrder = _itemOrder;

    assert(project != null && project.trim().isNotEmpty, 'project is required');
    assert(
      collection != null && collection.trim().isNotEmpty,
      'collection is required',
    );
    assert(query != null && query.trim().isNotEmpty, 'query is required');
    assert(eventType != null, 'eventType is required');
    assert(itemId != null && itemId.trim().isNotEmpty, 'itemId is required');
    assert(itemOrder != null && itemOrder >= 1, 'itemOrder must be >= 1');

    return SearchFeedbackEventPayload(
      project: project!,
      collection: collection!,
      handler: _handler,
      query: query!,
      eventType: eventType!,
      itemId: itemId!,
      itemOrder: itemOrder!,
      itemPrice: _itemPrice,
      url: _url,
      sessionId: _sessionId,
      userId: _userId,
      userIp: _userIp,
      userCountry: _userCountry,
      token: _token,
    );
  }

  @override
  Future<void> send() async {
    final payload = build();

    // Enforce locator-based execution.
    final repo = GetIt.instance<FeedbackRepository>();
    // ignore: deprecated_member_use_from_same_package
    await repo.submitSearchFeedbackEvent(
      project: payload.project,
      collection: payload.collection,
      handler: payload.handler,
      query: payload.query,
      eventType: payload.eventType,
      itemId: payload.itemId,
      itemOrder: payload.itemOrder,
      itemPrice: payload.itemPrice,
      url: payload.url,
      sessionId: payload.sessionId,
      userId: payload.userId,
      userIp: payload.userIp,
      userCountry: payload.userCountry,
      token: payload.token,
    );
  }
}

