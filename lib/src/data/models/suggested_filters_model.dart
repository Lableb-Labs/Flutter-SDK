/// Model representing a suggested filter.
class SuggestedFiltersModel {
  /// The full filter string (e.g., "tags:تجارة واستثمار").
  final String filter;

  /// The filter name (e.g., "tags").
  final String filter_name;

  /// The filter value (e.g., "تجارة واستثمار").
  final String filter_value;

  SuggestedFiltersModel({
    required this.filter,
    required this.filter_name,
    required this.filter_value,
  });

  /// Creates a [SuggestedFiltersModel] from a JSON map.
  factory SuggestedFiltersModel.fromJson(Map<String, dynamic> json) {
    return SuggestedFiltersModel(
      filter: json['filter'] as String,
      filter_name: json['filter_name'] as String,
      filter_value: json['filter_value'] as String,
    );
  }

  /// Converts the [SuggestedFiltersModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'filter': filter,
      'filter_name': filter_name,
      'filter_value': filter_value,
    };
  }
}
