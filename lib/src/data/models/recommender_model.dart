import '../../domain/entities/recommender_entity.dart';

/// Data model representing a recommendation.
/// 
/// This model is used for serialization/deserialization when
/// communicating with the API.
class RecommenderModel {
  /// Unique identifier of the recommended item.
  final String id;
  
  /// The recommended item data.
  final Map<String, dynamic> data;
  
  /// Confidence score for this recommendation.
  final double? score;
  
  /// Reason or explanation for the recommendation.
  final String? reason;

  RecommenderModel({
    required this.id,
    required this.data,
    this.score,
    this.reason,
  });

  /// Creates a [RecommenderModel] from a JSON map.
  ///
  /// Lableb returns each recommended document flat (`{"id", "title", ...}`);
  /// everything but `id`, `score` and `reason` becomes [data]. A nested
  /// `data` map is used as-is when present.
  factory RecommenderModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : (Map<String, dynamic>.from(json)
          ..remove('id')
          ..remove('score')
          ..remove('reason'));

    return RecommenderModel(
      id: json['id']?.toString() ?? '',
      data: data,
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      reason: json['reason'] as String?,
    );
  }

  /// Converts the [RecommenderModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data,
      if (score != null) 'score': score,
      if (reason != null) 'reason': reason,
    };
  }

  /// Converts the model to a domain entity.
  RecommenderEntity toEntity() {
    return RecommenderEntity(
      id: id,
      data: data,
      score: score,
      reason: reason,
    );
  }

  /// Creates a model from a domain entity.
  factory RecommenderModel.fromEntity(RecommenderEntity entity) {
    return RecommenderModel(
      id: entity.id,
      data: entity.data,
      score: entity.score,
      reason: entity.reason,
    );
  }
}

