/// Response model for Search Feedback Event API.
///
/// Example response:
/// ```json
/// {
///   "time": 6,
///   "code": 200,
///   "response": null
/// }
/// ```
class FeedbackEventResponse {
  /// Request time (ms or server-reported duration).
  final int? time;

  /// HTTP-like response code returned by the API.
  final int code;

  /// Response payload (often null).
  final dynamic response;

  FeedbackEventResponse({
    required this.code,
    this.time,
    this.response,
  });

  /// Creates a [FeedbackEventResponse] from JSON.
  factory FeedbackEventResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackEventResponse(
      time: json['time'] is int ? json['time'] as int : null,
      code: json['code'] as int? ?? 200,
      response: json['response'],
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {
      if (time != null) 'time': time,
      'code': code,
      'response': response,
    };
  }

  /// Whether the API considered this request successful.
  bool get isSuccess => code >= 200 && code < 300;
}

