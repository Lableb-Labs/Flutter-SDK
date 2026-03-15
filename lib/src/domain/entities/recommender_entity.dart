/// Domain entity representing a recommendation.
/// 
/// This entity represents a single recommendation returned by
/// the recommender API.
class RecommenderEntity {
  /// Unique identifier of the recommended item.
  final String id;
  
  /// The recommended item data.
  final Map<String, dynamic> data;
  
  /// Confidence score for this recommendation.
  final double? score;
  
  /// Reason or explanation for the recommendation.
  final String? reason;

  RecommenderEntity({
    required this.id,
    required this.data,
    this.score,
    this.reason,
  });
}

