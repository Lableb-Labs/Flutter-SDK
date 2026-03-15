import '../di/locator.dart';
import '../sdk_initializer.dart';
import 'autocomplete_feedback_builder.dart';
import 'legacy_search_feedback_builder.dart';
import 'recommender_feedback_builder.dart';
import 'search_feedback_event_builder.dart';

/// Fluent builders for Search Feedback events.
extension SearchFeedbackModule on LablebSDK {
  /// Starts a fluent builder for `submitSearchFeedbackEvent`.
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
  ///     .forQuery('prod')
  ///     .forSuggestion('product')
  ///     .value('clicked')
  ///     .fromUser(id: 'user-123')
  ///     .send();
  /// ```
  AutocompleteFeedbackBuilderStart autocompleteFeedback() =>
      locator<AutocompleteFeedbackBuilderStart>();

  /// Starts a fluent builder for recommender feedback submission.
  ///
  /// Example:
  /// ```dart
  /// await sdk
  ///     .recommenderFeedback()
  ///     .forRecommendation('item-2')
  ///     .value('positive')
  ///     .fromUser(id: 'user-123')
  ///     .send();
  /// ```
  RecommenderFeedbackBuilderStart recommenderFeedback() =>
      locator<RecommenderFeedbackBuilderStart>();

  /// Starts a fluent builder for the legacy search feedback endpoint.
  ///
  /// Prefer [searchFeedbackEvent] when you have `project/collection` and want
  /// click/add_to_cart/purchase events.
  LegacySearchFeedbackBuilderStart legacySearchFeedback() =>
      locator<LegacySearchFeedbackBuilderStart>();
}

