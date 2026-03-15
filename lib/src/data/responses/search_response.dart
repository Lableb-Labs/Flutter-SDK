import '../models/search_model.dart';
import '../../core/pagination_model.dart';

/// Response model for search operations.
/// 
/// This model represents the response from the search API.
class SearchResponse {
  /// List of search results.
  final List<SearchModel> results;
  
  /// Pagination information.
  final PaginationModel pagination;
  
  /// Total number of results found.
  final int totalResults;
  
  /// Query execution time in milliseconds.
  final int? executionTime;
  
  /// Optional query suggestions.
  final List<String>? suggestions;

  SearchResponse({
    required this.results,
    required this.pagination,
    required this.totalResults,
    this.executionTime,
    this.suggestions,
  });

  /// Creates a [SearchResponse] from a JSON map.
  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      results: (json['results'] as List? ?? [])
          .map((item) => SearchModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>? ?? {},
      ),
      totalResults: json['total_results'] as int? ?? 
                    json['total'] as int? ?? 
                    (json['results'] as List? ?? []).length,
      executionTime: json['execution_time'] as int?,
      suggestions: json['suggestions'] != null
          ? List<String>.from(json['suggestions'] as List)
          : null,
    );
  }

  /// Converts the [SearchResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'results': results.map((result) => result.toJson()).toList(),
      'pagination': pagination.toJson(),
      'total_results': totalResults,
      if (executionTime != null) 'execution_time': executionTime,
      if (suggestions != null) 'suggestions': suggestions,
    };
  }
}

