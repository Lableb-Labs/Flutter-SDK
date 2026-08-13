/// Request model for recommendation operations.
/// 
/// This model is used to structure the request parameters when
/// getting recommendations.
class RecommenderRequest {
  /// Optional user ID for personalized recommendations.
  final String? userId;
  
  /// Optional item ID for item-based recommendations.
  final String? itemId;
  
  /// Maximum number of recommendations to return (default: 10).
  final int limit;
  
  /// Optional filters to apply.
  final Map<String, dynamic>? filters;
  
  /// Optional context data for recommendations.
  final Map<String, dynamic>? context;

  RecommenderRequest({
    this.userId,
    this.itemId,
    int limit = 10,
    this.filters,
    this.context,
  }) : limit = limit;

  /// Converts the [RecommenderRequest] to query parameters or body.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'limit': limit,
    };

    if (userId != null) {
      json['user_id'] = userId;
    }

    if (itemId != null) {
      json['item_id'] = itemId;
    }

    if (filters != null && filters!.isNotEmpty) {
      json['filters'] = filters;
    }

    if (context != null && context!.isNotEmpty) {
      json['context'] = context;
    }

    return json;
  }
}

