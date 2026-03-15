import '../../api/api_client.dart';
import '../../domain/entities/recommender_entity.dart';
import '../../domain/repositories/recommender_repository.dart';
import '../requests/recommender_request.dart';
import '../responses/recommender_response.dart';

/// Implementation of [RecommenderRepository] for recommendation operations.
/// 
/// This repository handles all communication with the recommender API endpoints.
class RecommenderRepositoryImpl implements RecommenderRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  RecommenderRepositoryImpl(this._apiClient);

  @override
  Future<List<RecommenderEntity>> getRecommendations({
    String? userId,
    String? itemId,
    int limit = 10,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? context,
  }) async {
    try {
      final request = RecommenderRequest(
        userId: userId,
        itemId: itemId,
        limit: limit,
        filters: filters,
        context: context,
      );

      final response = await _apiClient.post(
        '/recommender',
        data: request.toJson(),
      );

      final recommenderResponse = RecommenderResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return recommenderResponse.recommendations
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

