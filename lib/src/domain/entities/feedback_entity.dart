/// Domain entity representing feedback data.
/// 
/// This entity represents feedback submitted for search, autocomplete,
/// or recommendation results.
class FeedbackEntity {
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

  FeedbackEntity({
    required this.feedbackType,
    required this.query,
    required this.resultId,
    required this.feedbackValue,
    this.metadata,
    this.timestamp,
  });
}

