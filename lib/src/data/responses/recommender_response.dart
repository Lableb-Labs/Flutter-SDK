import '../models/recommender_model.dart';

/// Response model for recommendation operations.
/// 
/// This model represents the response from the recommender API.
class RecommenderResponse {
  /// List of recommendations.
  final List<RecommenderModel> recommendations;
  
  /// Query execution time in milliseconds.
  final int? executionTime;

  RecommenderResponse({
    required this.recommendations,
    this.executionTime,
  });

  /// Creates a [RecommenderResponse] from a JSON map.
  factory RecommenderResponse.fromJson(Map<String, dynamic> json) {
    return RecommenderResponse(
      recommendations: (json['recommendations'] as List? ?? 
                        json['results'] as List? ?? [])
          .map((item) => RecommenderModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      executionTime: json['execution_time'] as int?,
    );
  }

  /// Converts the [RecommenderResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'recommendations': recommendations.map((rec) => rec.toJson()).toList(),
      if (executionTime != null) 'execution_time': executionTime,
    };
  }
}

