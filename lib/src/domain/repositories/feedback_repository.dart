/// Search feedback event types supported by the platform.
///
/// Values map to the REST API `event_type` body field.
enum SearchFeedbackEventType {
  /// User clicked one of the search results.
  click,

  /// User added one of the search results to cart.
  addToCart,

  /// User purchased one of the search results.
  purchase,
}

/// Maps [SearchFeedbackEventType] to API string values.
extension SearchFeedbackEventTypeApi on SearchFeedbackEventType {
  /// Converts the enum value to the API `event_type` value.
  String toApiValue() {
    switch (this) {
      case SearchFeedbackEventType.purchase:
        return 'purchase';
      case SearchFeedbackEventType.addToCart:
        return 'add_to_cart';
      case SearchFeedbackEventType.click:
        return 'click';
    }
  }
}

/// Abstract repository interface for feedback operations.
/// 
/// This defines the contract for submitting feedback.
abstract class FeedbackRepository {
  /// Sends a **Search Feedback Event** (click/add_to_cart/purchase).
  ///
  /// Prefer the fluent builder:
  /// ```dart
  /// await sdk
  ///     .searchFeedbackEvent()
  ///     .forQuery('product')
  ///     .event(SearchFeedbackEventType.click)
  ///     .forItem(id: 'item-1', order: 1, price: 95.5)
  ///     .fromUser(id: '1', sessionId: '1c4Hb23', ip: '192.111.24.21', country: 'DE')
  ///     .send();
  /// ```
  ///
  /// REST endpoint:
  /// `POST /v2/projects/{platformName}/indices/{indexName}/search/{handler}/feedback/events`
  ///
  /// The project and index segments are taken from the `platformName` and
  /// `indexName` given to [LablebSDK]; they are not passed per call. The
  /// events travel as a **JSON array body**, authenticated with an `apikey`
  /// query parameter that must carry `Search` permission.
  ///
  /// Required:
  /// - [query]
  /// - [eventType]
  /// - [itemId], [itemOrder] (starting from 1)
  ///
  /// Optional:
  /// - [handler] (defaults to `default`)
  /// - [itemPrice], [itemQuantity], [cartId], [url]
  /// - [sessionId], [userId], [userIp], [userCountry]
  /// - [requestSource] (`web`, `mobile`, `ios`, ...)
  ///
  /// Throws [LablebException] if submission fails.
  @Deprecated('Use sdk.searchFeedbackEvent() fluent builder instead.')
  Future<void> submitSearchFeedbackEvent({
    String handler = 'default',
    required String query,
    required SearchFeedbackEventType eventType,
    required String itemId,
    required int itemOrder,
    double? itemPrice,
    int? itemQuantity,
    String? cartId,
    String? url,
    String? sessionId,
    String? userId,
    String? userIp,
    String? userCountry,
    String? requestSource,
  });

  /// Submits feedback for a search result.
  /// 
  /// [query] - The search query.
  /// [resultId] - ID of the result that received feedback.
  /// [feedbackValue] - Type of feedback (positive, negative, click, etc.).
  /// [metadata] - Optional additional metadata.
  /// 
  /// Throws [LablebException] if submission fails.
  @Deprecated(
    'Use sdk.searchFeedbackEvent() fluent builder (preferred) or submitSearchFeedbackEvent().',
  )
  Future<void> submitSearchFeedback({
    required String query,
    required String resultId,
    required String feedbackValue,
    Map<String, dynamic>? metadata,
  });

  /// Sends an **Autocomplete Feedback Event** (click/add_to_cart/purchase).
  ///
  /// Prefer the fluent builder:
  /// ```dart
  /// await sdk
  ///     .autocompleteFeedback()
  ///     .forQuery('samsu')
  ///     .event(SearchFeedbackEventType.click)
  ///     .forItem(id: '153-ar', order: 4)
  ///     .withHandler('suggest')
  ///     .fromUser(id: '2313', sessionId: '1c4CqE')
  ///     .send();
  /// ```
  ///
  /// REST endpoint:
  /// `POST /v2/projects/{platformName}/indices/{indexName}/autocomplete/{handler}/feedback/events`
  ///
  /// The project and index segments are taken from the `platformName` and
  /// `indexName` given to [LablebSDK]; they are not passed per call. The
  /// events travel as a **JSON array body**, authenticated with an `apikey`
  /// query parameter that must carry `Search` permission.
  ///
  /// The suggestion the user took is reported as [itemId] plus [itemOrder];
  /// the kind of interaction is [eventType]. There is no free-text feedback
  /// value in the documented payload.
  ///
  /// Required:
  /// - [query]
  /// - [eventType]
  /// - [itemId], [itemOrder] (starting from 1)
  ///
  /// Optional:
  /// - [handler] (defaults to `default`)
  /// - [itemPrice], [itemQuantity], [cartId], [url]
  /// - [sessionId], [userId], [userIp], [userCountry]
  /// - [requestSource] (`web`, `mobile`, `ios`, ...)
  ///
  /// Throws [ValidationException] when `platformName` is not configured, and
  /// throws if the API returns a non-2xx code.
  @Deprecated('Use sdk.autocompleteFeedback() fluent builder instead.')
  Future<void> submitAutocompleteFeedbackEvent({
    String handler = 'default',
    required String query,
    required SearchFeedbackEventType eventType,
    required String itemId,
    required int itemOrder,
    double? itemPrice,
    int? itemQuantity,
    String? cartId,
    String? url,
    String? sessionId,
    String? userId,
    String? userIp,
    String? userCountry,
    String? requestSource,
  });

  /// Sends a **Recommendation Feedback Event**.
  ///
  /// Prefer the fluent builder:
  /// ```dart
  /// await sdk
  ///     .recommenderFeedback()
  ///     .forRecommendation(sourceId: '153-en', targetId: '154-ar')
  ///     .event(SearchFeedbackEventType.click)
  ///     .atOrder(2)
  ///     .send();
  /// ```
  ///
  /// REST endpoint:
  /// `POST /v2/projects/{platformName}/indices/{indexName}/recommend/{handler}/feedback/events`
  ///
  /// The project and index segments are taken from the `platformName` and
  /// `indexName` given to [LablebSDK]; they are not passed per call. The
  /// events travel as a **JSON array body**, authenticated with an `apikey`
  /// query parameter that must carry `Search` permission.
  ///
  /// This event reports that a user moved from [sourceId] to [targetId], a
  /// document recommended alongside it. Unlike search and autocomplete
  /// feedback it carries no query and no `item_id`.
  ///
  /// Required:
  /// - [sourceId], [targetId]
  ///
  /// Optional:
  /// - [eventType] — the API accepts the event without it
  /// - [handler] (defaults to `default`)
  /// - [sourceTitle], [sourceUrl], [targetTitle], [targetUrl]
  /// - [itemOrder] (starting from 1), [itemPrice], [itemQuantity], [cartId]
  /// - [sessionId], [userId], [userIp], [userCountry]
  /// - [requestSource] (`web`, `mobile`, `ios`, ...)
  ///
  /// Throws [ValidationException] when `platformName` is not configured, and
  /// throws if the API returns a non-2xx code.
  @Deprecated('Use sdk.recommenderFeedback() fluent builder instead.')
  Future<void> submitRecommendFeedbackEvent({
    String handler = 'default',
    required String sourceId,
    required String targetId,
    SearchFeedbackEventType? eventType,
    String? sourceTitle,
    String? sourceUrl,
    String? targetTitle,
    String? targetUrl,
    int? itemOrder,
    double? itemPrice,
    int? itemQuantity,
    String? cartId,
    String? sessionId,
    String? userId,
    String? userIp,
    String? userCountry,
    String? requestSource,
  });
}
