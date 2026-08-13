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

  AutocompleteRequest({
    required this.query,
    this.limit = 10,
    this.filters,
    this.field,
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

    return params;
  }
}

