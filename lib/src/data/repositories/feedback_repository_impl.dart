import '../../api/api_client.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../models/feedback_event_model.dart';

/// Implementation of [FeedbackRepository] for feedback operations.
///
/// This repository handles all communication with the feedback API endpoints.
class FeedbackRepositoryImpl implements FeedbackRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  FeedbackRepositoryImpl(this._apiClient);

  /// Constructs the feedback path with optional handler.
  ///
  /// If handler is provided and not empty, returns "/{operation}/{handler}/feedback/events".
  /// Otherwise returns "/{operation}/feedback/events".
  String _constructPath(String operation, String? handler) {
    if (handler != null && handler.isNotEmpty) {
      return '/$operation/$handler/feedback/events';
    }
    return '/$operation/feedback/events';
  }

  @override
  Future<void> submitSearchFeedbackEvent(SearchFeedbackEvent event,
      {String? handler}) async {
    // Fire and forget: don't await, and swallow any network exceptions
    _apiClient.post(
      _constructPath('search', handler),
      data: [event.toJson()],
      queryParameters: {'apikey': _apiClient.apiKeySearch},
    ).then((_) {}, onError: (e) {
      // Swallowed to prevent blocking the client app's flow
    });
  }

  @override
  Future<void> submitAutocompleteFeedbackEvent(AutocompleteFeedbackEvent event,
      {String? handler}) async {
    // Fire and forget: don't await, and swallow any network exceptions
    _apiClient.post(
      _constructPath('autocomplete', handler),
      data: [event.toJson()],
      queryParameters: {'apikey': _apiClient.apiKeySearch},
    ).then((_) {}, onError: (e) {
      // Swallowed to prevent blocking the client app's flow
    });
  }

  @override
  Future<void> submitRecommendFeedbackEvent(RecommendFeedbackEvent event,
      {String? handler}) async {
    // Fire and forget: don't await, and swallow any network exceptions
    _apiClient.post(
      _constructPath('recommend', handler),
      data: [event.toJson()],
      queryParameters: {'apikey': _apiClient.apiKeySearch},
    ).then((_) {}, onError: (e) {
      // Swallowed to prevent blocking the client app's flow
    });
  }
}
