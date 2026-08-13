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
  ///
  /// Per Lableb's REST API docs, pagination is `skip`/`limit` (not
  /// `page`/`page_size`), and filters are individual top-level query
  /// parameters per field (range filters use `{field}_from`/`{field}_to`),
  /// not a nested `filters` object.
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'q': query,
      'skip': (page - 1) * pageSize,
      'limit': pageSize,
    };

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

    if (sort != null && sort!.isNotEmpty) {
      params['sort'] = sort!.entries.map((e) => '${e.key} ${e.value}').join(',');
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

