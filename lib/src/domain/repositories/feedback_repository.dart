import '../../data/models/feedback_event_model.dart';
import '../../exceptions/exceptions.dart';

/// Feedback event types supported by the platform.
enum FeedbackEventType {
  /// User clicked on an item.
  click,

  /// User added an item to cart.
  addToCart,

  /// User purchased an item.
  purchase,
}

/// Maps [FeedbackEventType] to API string values.
extension FeedbackEventTypeApi on FeedbackEventType {
  /// Converts the enum value to the API `event_type` value.
  String toApiValue() {
    switch (this) {
      case FeedbackEventType.purchase:
        return 'purchase';
      case FeedbackEventType.addToCart:
        return 'add_to_cart';
      case FeedbackEventType.click:
        return 'click';
    }
  }
}

/// Abstract repository interface for feedback operations.
///
/// This defines the contract for submitting feedback.
abstract class FeedbackRepository {
  /// Sends a **Search Feedback Event**.
  ///
  /// REST endpoint: `POST /search/feedback/events`
  ///
  /// [event] - The search feedback event data.
  ///
  /// This is a fire-and-forget method. Network exceptions are swallowed
  /// to prevent blocking the UI.
  Future<void> submitSearchFeedbackEvent(SearchFeedbackEvent event,
      {String? handler});

  /// Sends an **Autocomplete Feedback Event**.
  ///
  /// REST endpoint: `POST /autocomplete/feedback/events`
  ///
  /// [event] - The autocomplete feedback event data.
  ///
  /// This is a fire-and-forget method. Network exceptions are swallowed
  /// to prevent blocking the UI.
  Future<void> submitAutocompleteFeedbackEvent(AutocompleteFeedbackEvent event,
      {String? handler});

  /// Sends a **Recommendation Feedback Event**.
  ///
  /// REST endpoint: `POST /recommend/feedback/events`
  ///
  /// [event] - The recommendation feedback event data.
  ///
  /// This is a fire-and-forget method. Network exceptions are swallowed
  /// to prevent blocking the UI.
  Future<void> submitRecommendFeedbackEvent(RecommendFeedbackEvent event,
      {String? handler});
}
