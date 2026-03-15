/// Request model for feedback operations.
/// 
/// This model is used to structure the request body when
/// submitting feedback.
class FeedbackRequest {
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
  
  /// Optional user ID.
  final String? userId;

  FeedbackRequest({
    required this.feedbackType,
    required this.query,
    required this.resultId,
    required this.feedbackValue,
    this.metadata,
    this.userId,
  });

  /// Converts the [FeedbackRequest] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'feedback_type': feedbackType,
      'query': query,
      'result_id': resultId,
      'feedback_value': feedbackValue,
      if (metadata != null) 'metadata': metadata,
      if (userId != null) 'user_id': userId,
    };
  }
}

