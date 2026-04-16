/// Model representing a facet bucket in search results.
class FacetBucket {
  /// The facet value.
  final dynamic value;

  /// The count of items with this facet value.
  final int count;

  FacetBucket({required this.value, required this.count});

  /// Creates a [FacetBucket] from a JSON map.
  factory FacetBucket.fromJson(Map<String, dynamic> json) {
    return FacetBucket(
      value: json['value'],
      count: json['count'] as int? ?? 0,
    );
  }

  /// Converts the [FacetBucket] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'count': count,
    };
  }
}

/// Model representing a single facet (e.g., brand, category).
class FacetModel {
  /// The facet name/key.
  final String facetName;

  /// List of buckets for this facet.
  final List<FacetBucket> buckets;

  FacetModel({
    required this.facetName,
    required this.buckets,
  });

  /// Creates a [FacetModel] from a JSON map.
  factory FacetModel.fromJson(String facetName, Map<String, dynamic> json) {
    return FacetModel(
      facetName: json['facet_name'] as String? ?? facetName,
      buckets: (json['buckets'] as List? ?? [])
          .map((item) => FacetBucket.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts the [FacetModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'facet_name': facetName,
      'buckets': buckets.map((bucket) => bucket.toJson()).toList(),
    };
  }
}
