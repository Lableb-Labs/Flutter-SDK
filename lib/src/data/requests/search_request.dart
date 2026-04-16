/// Request model for search operations.
///
/// This model is used to structure the request parameters when
/// performing a search query.
class SearchRequest {
  /// The search query string.
  final String query;

  /// Optional filters to apply to the search.
  final Map<String, dynamic>? filters;

  /// Optional sort parameters (e.g., "tags desc", "price asc").
  final String? sort;

  /// Page number for pagination (default: 1).
  final int page;

  /// Number of results per page (default: 10).
  final int pageSize;

  SearchRequest({
    required this.query,
    this.filters,
    this.sort,
    this.page = 1,
    this.pageSize = 10,
  });

  /// Converts the [SearchRequest] to query parameters.
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'q': query,
      'limit': pageSize,
      'skip': (page - 1) * pageSize,
    };

    if (filters != null && filters!.isNotEmpty) {
      // Flatten filters as individual query parameters
      filters!.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          // Handle range filters like {"year": {"from": 2021, "to": 2022}}
          if (value.containsKey('from')) {
            params['${key}_from'] = value['from'];
          }
          if (value.containsKey('to')) {
            params['${key}_to'] = value['to'];
          }
        } else {
          params[key] = value;
        }
      });
    }

    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort;
    }

    return params;
  }
}
