import '../../exceptions/exceptions.dart';
import '../../data/responses/matching_response.dart';

/// Abstract repository interface for recommendation operations.
///
/// This defines the contract for getting recommendations.
abstract class RecommenderRepository {
  /// Gets personalized recommendations.
  ///
  /// [itemId] - Optional item ID for item-based recommendations (moved to query param 'id').
  /// [limit] - Maximum number of recommendations to return (default: 10).
  /// [filters] - Optional filters to apply.
  /// [context] - Optional context data for recommendations.
  /// [sessionId] - Optional session identifier for analytics.
  /// [userId] - Optional user identifier for analytics.
  /// [userIp] - Optional user IP address for analytics.
  /// [userCountry] - Optional user country for analytics.
  /// [requestSource] - Optional request source for analytics.
  ///
  /// Returns a unified recommendation response.
  /// Throws [LablebException] if the request fails.
  Future<MatchingResponse> getRecommendations({
    String? handler,
    String? itemId,
    int limit = 10,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? context,
    String? sessionId,
    String? userId,
    String? userIp,
    String? userCountry,
    String? requestSource,
  });
}
