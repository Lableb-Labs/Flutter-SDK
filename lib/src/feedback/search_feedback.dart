import '../di/locator.dart';
import '../sdk_initializer.dart';
import 'autocomplete_feedback_builder.dart';
import 'legacy_search_feedback_builder.dart';
import 'recommender_feedback_builder.dart';
import 'search_feedback_event_builder.dart';

/// Fluent builders for Search Feedback events.
extension SearchFeedbackModule on LablebSDK {
  /// Starts a fluent builder for search feedback events.
  ///
  /// Example:
  /// ```dart
  /// await sdk
  ///     .searchFeedbackEvent()
  ///     .forQuery('product')
  ///     .event(SearchFeedbackEventType.click)
  ///     .forItem(id: 'item-1', order: 1)
  ///     .withHandler('suggest')
  ///     .fromUser(id: 'user-123', sessionId: 'session-123')
  ///     .send();
  /// ```
  ///
  /// The final `.send()` call executes through the SDK service locator.
  SearchFeedbackEventBuilderStart searchFeedbackEvent() =>
      locator<SearchFeedbackEventBuilderStart>();

  /// Starts a fluent builder for autocomplete feedback submission.
  ///
  /// Example:
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
  /// The suggestion the user took is identified by `forItem`; `event`
  /// records what they did with it.
  AutocompleteFeedbackBuilderStart autocompleteFeedback() =>
      locator<AutocompleteFeedbackBuilderStart>();

  /// Starts a fluent builder for recommender feedback submission.
  ///
  /// Example:
  /// ```dart
  /// await sdk
  ///     .recommenderFeedback()
  ///     .forRecommendation(sourceId: '153-en', targetId: '154-ar')
  ///     .event(SearchFeedbackEventType.click)
  ///     .atOrder(2)
  ///     .send();
  /// ```
  ///
  /// This is the one feedback endpoint that takes a source/target pair
  /// instead of a query: it reports that a user moved from the document the
  /// recommendation was shown on to the recommended document.
  RecommenderFeedbackBuilderStart recommenderFeedback() =>
      locator<RecommenderFeedbackBuilderStart>();

  /// Starts a fluent builder for the legacy search feedback endpoint.
  ///
  /// Prefer [searchFeedbackEvent]: it sends the documented
  /// click/add_to_cart/purchase events. This legacy builder reaches the same
  /// endpoint, mapping best-effort metadata keys onto the event fields.
  LegacySearchFeedbackBuilderStart legacySearchFeedback() =>
      locator<LegacySearchFeedbackBuilderStart>();
}

