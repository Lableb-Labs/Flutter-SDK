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
  ///
  /// Lableb's real REST responses wrap the payload in a `{"time", "code",
  /// "response": {...}}` envelope with the documents under `results`; a bare
  /// `recommendations`/`results` list is still accepted.
  factory RecommenderResponse.fromJson(Map<String, dynamic> json) {
    final body = json['response'] is Map<String, dynamic>
        ? json['response'] as Map<String, dynamic>
        : json;

    return RecommenderResponse(
      recommendations: (body['results'] as List? ??
                        body['recommendations'] as List? ?? [])
          .map((item) => RecommenderModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      executionTime: json['time'] as int? ?? body['execution_time'] as int?,
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

