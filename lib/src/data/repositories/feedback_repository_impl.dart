import '../../api/api_client.dart';
import '../../domain/repositories/feedback_repository.dart';
import '../requests/feedback_request.dart';
import '../responses/feedback_response.dart';
import '../requests/search_feedback_event_request.dart';
import '../responses/feedback_event_response.dart';

/// Implementation of [FeedbackRepository] for feedback operations.
/// 
/// This repository handles all communication with the feedback API endpoints.
class FeedbackRepositoryImpl implements FeedbackRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  FeedbackRepositoryImpl(this._apiClient);

  @override
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
  }) async {
    final request = SearchFeedbackEventRequest(
      project: project,
      collection: collection,
      handler: handler,
      query: query,
      eventType: eventType,
      itemId: itemId,
      itemOrder: itemOrder,
      itemPrice: itemPrice,
      url: url,
      sessionId: sessionId,
      userId: userId,
      userIp: userIp,
      userCountry: userCountry,
      // If token isn't supplied, default to the SDK API key since docs show
      // `token=...` in query string.
      token: token ?? _apiClient.apiKey,
    );

    final response = await _apiClient.post(
      request.buildPath(),
      queryParameters: request.toQueryParameters(),
    );

    // Response payload shape differs from other feedback endpoints.
    final feedbackEventResponse = FeedbackEventResponse.fromJson(
      response.data as Map<String, dynamic>,
    );

    if (!feedbackEventResponse.isSuccess) {
      throw Exception(
        'Feedback event failed with code ${feedbackEventResponse.code}',
      );
    }
  }

  @override
  Future<void> submitSearchFeedback({
    required String query,
    required String resultId,
    required String feedbackValue,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Backwards compatibility: map to click event with best-effort fields.
      final itemOrder = (metadata?['item_order'] as int?) ?? 1;
      final itemPrice = metadata?['item_price'] is num
          ? (metadata!['item_price'] as num).toDouble()
          : null;
      final url = metadata?['url'] as String?;
      final sessionId = metadata?['session_id'] as String?;
      final userId = metadata?['user_id'] as String?;
      final userIp = metadata?['user_ip'] as String?;
      final userCountry = metadata?['user_country'] as String?;
      final project = metadata?['project'] as String?;
      final collection = metadata?['collection'] as String?;
      final handler = metadata?['handler'] as String? ?? 'default';

      if (project != null && collection != null) {
        await submitSearchFeedbackEvent(
          project: project,
          collection: collection,
          handler: handler,
          query: query,
          eventType: SearchFeedbackEventType.click,
          itemId: resultId,
          itemOrder: itemOrder,
          itemPrice: itemPrice,
          url: url,
          sessionId: sessionId,
          userId: userId,
          userIp: userIp,
          userCountry: userCountry,
        );
        return;
      }

      final request = FeedbackRequest(
        feedbackType: 'search',
        query: query,
        resultId: resultId,
        feedbackValue: feedbackValue,
        metadata: metadata,
      );

      final response = await _apiClient.post(
        '/feedback/search',
        data: request.toJson(),
      );

      final feedbackResponse = FeedbackResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!feedbackResponse.success) {
        throw Exception(feedbackResponse.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> submitAutocompleteFeedback({
    required String query,
    required String suggestion,
    required String feedbackValue,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final request = FeedbackRequest(
        feedbackType: 'autocomplete',
        query: query,
        resultId: suggestion,
        feedbackValue: feedbackValue,
        metadata: metadata,
        userId: userId,
      );

      final response = await _apiClient.post(
        '/feedback/autocomplete',
        data: request.toJson(),
      );

      final feedbackResponse = FeedbackResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!feedbackResponse.success) {
        throw Exception(feedbackResponse.message);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> submitRecommenderFeedback({
    required String recommendationId,
    required String feedbackValue,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final request = FeedbackRequest(
        feedbackType: 'recommender',
        query: '', // Not required for recommender feedback
        resultId: recommendationId,
        feedbackValue: feedbackValue,
        metadata: metadata,
        userId: userId,
      );

      final response = await _apiClient.post(
        '/feedback/recommender',
        data: request.toJson(),
      );

      final feedbackResponse = FeedbackResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (!feedbackResponse.success) {
        throw Exception(feedbackResponse.message);
      }
    } catch (e) {
      rethrow;
    }
  }
}

