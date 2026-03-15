/// Response model for feedback operations.
/// 
/// This model represents the response from the feedback API.
class FeedbackResponse {
  /// Whether the feedback was successfully submitted.
  final bool success;
  
  /// Response message.
  final String message;
  
  /// Optional feedback ID.
  final String? feedbackId;

  FeedbackResponse({
    required this.success,
    required this.message,
    this.feedbackId,
  });

  /// Creates a [FeedbackResponse] from a JSON map.
  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      feedbackId: json['feedback_id'] as String?,
    );
  }

  /// Converts the [FeedbackResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      if (feedbackId != null) 'feedback_id': feedbackId,
    };
  }
}

