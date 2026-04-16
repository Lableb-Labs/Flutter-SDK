import '../../api/api_client.dart';
import '../../domain/repositories/recommender_repository.dart';
import '../responses/matching_response.dart';

/// Implementation of [RecommenderRepository] for recommendation operations.
///
/// This repository handles all communication with the recommender API endpoints.
class RecommenderRepositoryImpl implements RecommenderRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  RecommenderRepositoryImpl(this._apiClient);

  @override
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
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
      };

      if (itemId != null) queryParams['id'] = itemId;
      if (filters != null) {
        // Assuming filters are flattened as before
        filters.forEach((key, value) {
          queryParams[key] = value;
        });
      }
      if (context != null) {
        // Context might need to be serialized differently, but for now, add as is
        context.forEach((key, value) {
          queryParams['context_$key'] = value; // or something
        });
      }
      if (sessionId != null) queryParams['session_id'] = sessionId;
      if (userId != null) queryParams['user_id'] = userId;
      if (userIp != null) queryParams['user_ip'] = userIp;
      if (userCountry != null) queryParams['user_country'] = userCountry;
      if (requestSource != null) queryParams['request_source'] = requestSource;

      final path =
          (handler?.isNotEmpty ?? false) ? '/recommend/$handler' : '/recommend';

      final response = await _apiClient.get(
        path,
        queryParameters: queryParams,
      );

      final recommenderResponse = MatchingResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return recommenderResponse;
    } catch (e) {
      rethrow;
    }
  }
}
