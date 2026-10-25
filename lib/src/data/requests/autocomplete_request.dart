/// Request model for autocomplete operations.
/// 
/// This model is used to structure the request parameters when
/// getting autocomplete suggestions.
class AutocompleteRequest {
  /// The partial query string.
  final String query;
  
  /// Maximum number of suggestions to return (default: 10).
  final int limit;
  
  /// Optional filters to apply.
  final Map<String, dynamic>? filters;
  
  /// Optional field to search in.
  final String? field;

  /// Optional request source (e.g. `'mobile'`), sent as `request_source`.
  final String? requestSource;

  /// Optional language (e.g. `'ar'`), sent as `lang`.
  final String? lang;

  /// Optional session identifier, sent as `session_id`.
  final String? sessionId;

  AutocompleteRequest({
    required this.query,
    this.limit = 10,
    this.filters,
    this.field,
    this.requestSource,
    this.lang,
    this.sessionId,
  });

  /// Converts the [AutocompleteRequest] to query parameters.
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'q': query,
      'limit': limit,
    };

    if (filters != null && filters!.isNotEmpty) {
      params['filters'] = filters;
    }

    if (field != null) {
      params['field'] = field;
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
}

