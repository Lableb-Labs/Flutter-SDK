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

  /// Optional request source (e.g. `'mobile'`), sent as `request_source`.
  final String? requestSource;

  /// Optional language (e.g. `'ar'`), sent as `lang`.
  final String? lang;

  /// Optional session identifier, sent as `session_id`.
  final String? sessionId;

  RecommenderRequest({
    this.userId,
    this.itemId,
    this.limit = 10,
    this.filters,
    this.context,
    this.requestSource,
    this.lang,
    this.sessionId,
  });

  /// Converts the [RecommenderRequest] to the query parameters Lableb's
  /// recommend endpoint takes
  /// (docs.lableb.com/docs/cse/rest/recommendations).
  ///
  /// [itemId] is sent as `id`, the source document to find similar items
  /// for. [filters] are flattened the same way search flattens them: a scalar
  /// becomes `{field}=value`, and a `{gte|from, lte|to}` map becomes
  /// `{field}_from`/`{field}_to`; a `filter` key passes through as the custom
  /// filter expression. Scalar [context] entries (e.g. `user_ip`,
  /// `user_country`) are sent as-is; nested values are dropped.
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};

    if (context != null) {
      for (final entry in context!.entries) {
        final value = entry.value;
        if (value is String || value is num || value is bool) {
          params[entry.key] = value;
        }
      }
    }

    if (filters != null && filters!.isNotEmpty) {
      for (final entry in filters!.entries) {
        final value = entry.value;
        if (value is Map) {
          final from = value['gte'] ?? value['from'];
          final to = value['lte'] ?? value['to'];
          if (from != null) params['${entry.key}_from'] = from;
          if (to != null) params['${entry.key}_to'] = to;
        } else {
          params[entry.key] = value;
        }
      }
    }

    if (itemId != null) {
      params['id'] = itemId;
    }

    params['limit'] = limit;

    if (userId != null) {
      params['user_id'] = userId;
    }

    if (requestSource != null && requestSource!.isNotEmpty) {
      params['request_source'] = requestSource;
    }

    if (lang != null && lang!.isNotEmpty) {
      params['lang'] = lang;
    }

    if (sessionId != null && sessionId!.isNotEmpty) {
      params['session_id'] = sessionId;
    }

    return params;
  }

  /// Converts the [RecommenderRequest] to a JSON body.
  ///
  /// Kept for compatibility; the SDK sends [toQueryParameters] instead.
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

    if (requestSource != null && requestSource!.isNotEmpty) {
      json['request_source'] = requestSource;
    }

    if (lang != null && lang!.isNotEmpty) {
      json['lang'] = lang;
    }

    if (sessionId != null && sessionId!.isNotEmpty) {
      json['session_id'] = sessionId;
    }

    return json;
  }
}

