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

  AutocompleteRequest({
    required this.query,
    this.limit = 10,
    this.filters,
  });

  /// Converts the [AutocompleteRequest] to query parameters.
  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{
      'q': query,
      'limit': limit,
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

    return params;
  }
}
