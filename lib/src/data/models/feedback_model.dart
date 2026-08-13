import '../../domain/entities/feedback_entity.dart';

/// Data model representing feedback data.
/// 
/// This model is used for serialization/deserialization when
/// communicating with the API.
class FeedbackModel {
  /// Type of feedback (search, autocomplete, recommender).
  final String feedbackType;
  
  /// The query or context that generated the result.
  final String query;
  
  /// ID of the result item that received feedback.
  final String resultId;
  
  /// Type of feedback (positive, negative, click, etc.).
  final String feedbackValue;
  
  /// Optional additional metadata.
  final Map<String, dynamic>? metadata;
  
  /// Timestamp when feedback was submitted.
  final DateTime? timestamp;

  FeedbackModel({
    required this.feedbackType,
    required this.query,
    required this.resultId,
    required this.feedbackValue,
    this.metadata,
    this.timestamp,
  });

  /// Creates a [FeedbackModel] from a JSON map.
  factory FeedbackModel.fromJson(Map<String, dynamic> json) {
    return FeedbackModel(
      feedbackType: json['feedback_type'] as String,
      query: json['query'] as String,
      resultId: json['result_id'] as String,
      feedbackValue: json['feedback_value'] as String,
      metadata: json['metadata'] != null
          ? json['metadata'] as Map<String, dynamic>
          : null,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  /// Converts the [FeedbackModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'feedback_type': feedbackType,
      'query': query,
      'result_id': resultId,
      'feedback_value': feedbackValue,
      if (metadata != null) 'metadata': metadata,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  /// Converts the model to a domain entity.
  FeedbackEntity toEntity() {
    return FeedbackEntity(
      feedbackType: feedbackType,
      query: query,
      resultId: resultId,
      feedbackValue: feedbackValue,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  /// Creates a model from a domain entity.
  factory FeedbackModel.fromEntity(FeedbackEntity entity) {
    return FeedbackModel(
      feedbackType: entity.feedbackType,
      query: entity.query,
      resultId: entity.resultId,
      feedbackValue: entity.feedbackValue,
      metadata: entity.metadata,
      timestamp: entity.timestamp,
    );
  }
}

