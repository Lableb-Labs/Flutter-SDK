import '../entities/recommender_entity.dart';
import '../../exceptions/exceptions.dart';

/// Abstract repository interface for recommendation operations.
/// 
/// This defines the contract for getting recommendations.
abstract class RecommenderRepository {
  /// Gets personalized recommendations.
  ///
  /// Prefer the fluent builder:
  /// ```dart
  /// final recs = await sdk
  ///     .recommendations()
  ///     .fromUser('user-123')
  ///     .limit(10)
  ///     .withContext({'page': 'home'})
  ///     .send();
  /// ```
  /// 
  /// [userId] - Optional user ID for personalized recommendations.
  /// [itemId] - Optional item ID for item-based recommendations.
  /// [limit] - Maximum number of recommendations to return (default: 10).
  /// [filters] - Optional filters to apply.
  /// [context] - Optional context data for recommendations.
  /// 
  /// Returns a list of recommendations.
  /// Throws [LablebException] if the request fails.
  @Deprecated('Use sdk.recommendations() fluent builder instead.')
  Future<List<RecommenderEntity>> getRecommendations({
    String? userId,
    String? itemId,
    int limit = 10,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? context,
  });
}

