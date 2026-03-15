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
  factory RecommenderModel.fromJson(Map<String, dynamic> json) {
    return RecommenderModel(
      id: json['id'] as String,
      data: json['data'] as Map<String, dynamic>,
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

