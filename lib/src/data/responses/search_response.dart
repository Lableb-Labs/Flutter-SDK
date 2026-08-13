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
  ///
  /// Lableb's real REST responses wrap the payload in a `{"time", "code",
  /// "response": {...}}` envelope, and use `found_documents` for the total
  /// count with no separate `pagination` object. [page]/[pageSize] (the
  /// values the request was made with) are used to synthesize pagination
  /// when the response doesn't provide one.
  factory SearchResponse.fromJson(
    Map<String, dynamic> json, {
    int page = 1,
    int pageSize = 10,
  }) {
    final body = json['response'] is Map<String, dynamic>
        ? json['response'] as Map<String, dynamic>
        : json;

    final results = (body['results'] as List? ?? [])
        .map((item) => SearchModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final totalResults = body['found_documents'] as int? ??
        body['total_results'] as int? ??
        body['total'] as int? ??
        results.length;

    final pagination = body['pagination'] is Map<String, dynamic>
        ? PaginationModel.fromJson(body['pagination'] as Map<String, dynamic>)
        : PaginationModel(
            currentPage: page,
            totalPages: pageSize > 0 ? (totalResults / pageSize).ceil().clamp(1, 1 << 31) : 1,
            totalItems: totalResults,
            itemsPerPage: pageSize,
          );

    return SearchResponse(
      results: results,
      pagination: pagination,
      totalResults: totalResults,
      executionTime: json['time'] as int? ?? body['execution_time'] as int?,
      suggestions: body['suggestions'] != null
          ? List<String>.from(body['suggestions'] as List)
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

