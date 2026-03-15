/// Search feedback event types supported by the platform.
///
/// Values map to the REST API `event_type` query parameter.
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
  ///     .forCollection(project: 'wptest', collection: 'posts', handler: 'default')
  ///     .forQuery('product')
  ///     .event(SearchFeedbackEventType.click)
  ///     .forItem(id: 'item-1', order: 1, price: 95.5)
  ///     .fromUser(id: '1', sessionId: '1c4Hb23', ip: '192.111.24.21', country: 'DE')
  ///     .send();
  /// ```
  ///
  /// REST endpoint:
  /// `POST /api/v1/{project}/collections/{collection}/search/{handler}/feedback/events`
  ///
  /// All parameters are sent as **query string parameters** (no request body).
  ///
  /// Required:
  /// - [project], [collection]
  /// - [query]
  /// - [eventType]
  /// - [itemId], [itemOrder] (starting from 1)
  ///
  /// Optional:
  /// - [handler] (defaults to `default`)
  /// - [itemPrice], [url]
  /// - [sessionId], [userId], [userIp], [userCountry]
  /// - [token] (if the API expects `token` in the query string)
  ///
  /// Throws [LablebException] if submission fails.
  @Deprecated('Use sdk.searchFeedbackEvent() fluent builder instead.')
  Future<void> submitSearchFeedbackEvent({
    required String project,
    required String collection,
    String handler = 'default',
    required String query,
    required SearchFeedbackEventType eventType,
    required String itemId,
    required int itemOrder,
    double? itemPrice,
    String? url,
    String? sessionId,
    String? userId,
    String? userIp,
    String? userCountry,
    String? token,
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

  /// Submits feedback for an autocomplete suggestion.
  /// 
  /// [query] - The autocomplete query.
  /// [suggestion] - The suggestion that received feedback.
  /// [feedbackValue] - Type of feedback.
  /// [metadata] - Optional additional metadata.
  /// 
  /// Throws [LablebException] if submission fails.
  @Deprecated('Use sdk.autocompleteFeedback() fluent builder instead.')
  Future<void> submitAutocompleteFeedback({
    required String query,
    required String suggestion,
    required String feedbackValue,
    String? userId,
    Map<String, dynamic>? metadata,
  });

  /// Submits feedback for a recommendation.
  /// 
  /// [recommendationId] - ID of the recommendation that received feedback.
  /// [feedbackValue] - Type of feedback.
  /// [userId] - Optional user ID.
  /// [metadata] - Optional additional metadata.
  /// 
  /// Throws [LablebException] if submission fails.
  @Deprecated('Use sdk.recommenderFeedback() fluent builder instead.')
  Future<void> submitRecommenderFeedback({
    required String recommendationId,
    required String feedbackValue,
    String? userId,
    Map<String, dynamic>? metadata,
  });
}

