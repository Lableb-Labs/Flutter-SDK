import '../models/document_model.dart';
import '../models/facet_model.dart';
import '../models/suggested_filters_model.dart';
import '../../domain/entities/document_entity.dart';

/// Unified response model for search, autocomplete, and recommendation operations.
///
/// This model represents the API response with support for results, total counts,
/// facets, and other metadata.
class MatchingResponse {
  /// List of result documents.
  final List<DocumentModel> results;

  /// Total number of results found (for search).
  final int totalResults;

  /// Query execution time in milliseconds.
  final int? executionTime;

  /// Facets for filtering results.
  final Map<String, FacetModel>? facets;

  /// Suggested filters from the API.
  final List<SuggestedFiltersModel>? suggestedFilters;

  MatchingResponse({
    required this.results,
    required this.totalResults,
    this.executionTime,
    this.facets,
    this.suggestedFilters,
  });

  /// Entity versions of the response results.
  List<DocumentEntity> get entities =>
      results.map((result) => result.toEntity()).toList();

  /// Creates a [MatchingResponse] from a JSON map.
  factory MatchingResponse.fromJson(Map<String, dynamic> json) {
    final body = json['response'] as Map<String, dynamic>? ?? json;

    final resultsJson = body['results'] as List? ?? [];
    final results = resultsJson
        .map((item) => DocumentModel.fromJson(item as Map<String, dynamic>))
        .toList();

    final totalResults = body['found_documents'] as int? ??
        body['total_results'] as int? ??
        body['total'] as int? ??
        results.length;

    final facetsJson = body['facets'] as Map<String, dynamic>? ?? {};
    final facets = <String, FacetModel>{};
    facetsJson.forEach((key, value) {
      if (value is Map<String, dynamic> && key != 'count') {
        facets[key] = FacetModel.fromJson(key, value);
      }
    });

    return MatchingResponse(
      results: results,
      totalResults: totalResults,
      executionTime: body['execution_time'] as int? ?? body['time'] as int?,
      facets: facets.isNotEmpty ? facets : null,
      suggestedFilters: body['suggested_filters'] != null
          ? (body['suggested_filters'] as List)
              .map((item) =>
                  SuggestedFiltersModel.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Converts the [MatchingResponse] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'results': results.map((result) => result.toJson()).toList(),
      'total_results': totalResults,
      if (executionTime != null) 'execution_time': executionTime,
      if (facets != null)
        'facets':
            facets?.map((key, facet) => MapEntry(key, facet.toJson())) ?? {},
      if (suggestedFilters != null)
        'suggested_filters':
            suggestedFilters?.map((filter) => filter.toJson()).toList(),
    };
  }
}
