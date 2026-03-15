/// Request model for search operations.
/// 
/// This model is used to structure the request parameters when
/// performing a search query.
class SearchRequest {
  /// The search query string.
  final String query;
  
  /// Optional filters to apply to the search.
  final Map<String, dynamic>? filters;
  
  /// Optional sort parameters.
  final Map<String, String>? sort;
  
  /// Page number for pagination (default: 1).
  final int page;
  
  /// Number of results per page (default: 10).
  final int pageSize;
  
  /// Optional fields to return in results.
  final List<String>? fields;
  
  /// Optional fields to highlight.
  final List<String>? highlightFields;

  SearchRequest({
    required this.query,
    this.filters,
    this.sort,
    this.page = 1,
    this.pageSize = 10,
    this.fields,
    this.highlightFields,
  });

  /// Converts the [SearchRequest] to query parameters.
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'q': query,
      'page': page,
      'page_size': pageSize,
    };

    if (filters != null && filters!.isNotEmpty) {
      params['filters'] = filters;
    }

    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort;
    }

    if (fields != null && fields!.isNotEmpty) {
      params['fields'] = fields!.join(',');
    }

    if (highlightFields != null && highlightFields!.isNotEmpty) {
      params['highlight_fields'] = highlightFields!.join(',');
    }

    return params;
  }
}

