/// Request model for recommendation operations.
///
/// This model is used to structure the request parameters when
/// getting recommendations.
class RecommenderRequest {
  /// Optional item ID for item-based recommendations.
  final String? itemId;

  /// Maximum number of recommendations to return (default: 10).
  final int limit;

  /// Optional filters to apply.
  final Map<String, dynamic>? filters;

  RecommenderRequest({
    this.itemId,
    int limit = 10,
    this.filters,
  }) : limit = limit;

  /// Converts the [RecommenderRequest] to JSON body.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'limit': limit,
    };

    if (itemId != null) {
      json['item_id'] = itemId;
    }

    if (filters != null && filters!.isNotEmpty) {
      // Flatten filters as individual parameters in the JSON body
      final flattenedFilters = <String, dynamic>{};
      filters!.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          // Handle range filters like {"year": {"from": 2021, "to": 2022}}
          if (value.containsKey('from')) {
            flattenedFilters['${key}_from'] = value['from'];
          }
          if (value.containsKey('to')) {
            flattenedFilters['${key}_to'] = value['to'];
          }
        } else {
          flattenedFilters[key] = value;
        }
      });
      json.addAll(flattenedFilters);
    }

    return json;
  }
}
