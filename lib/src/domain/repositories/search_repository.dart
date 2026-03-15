import '../entities/search_entity.dart';
import '../../core/pagination_model.dart';
import '../../exceptions/exceptions.dart';

/// Abstract repository interface for search operations.
/// 
/// This defines the contract for performing searches in the Lableb system.
abstract class SearchRepository {
  /// Performs a search query.
  ///
  /// Prefer the fluent builder:
  /// ```dart
  /// final result = await sdk
  ///     .searchRequest()
  ///     .forQuery('laptop')
  ///     .withFilters({'brand': 'Dell'})
  ///     .sortBy('price', direction: 'asc')
  ///     .paginate(page: 1, pageSize: 10)
  ///     .send();
  /// ```
  /// 
  /// [query] - The search query string.
  /// [filters] - Optional filters to apply to the search.
  /// [sort] - Optional sort parameters.
  /// [page] - Page number for pagination (default: 1).
  /// [pageSize] - Number of results per page (default: 10).
  /// 
  /// Returns a list of search results and pagination info.
  /// Throws [LablebException] if search fails.
  @Deprecated('Use sdk.searchRequest() fluent builder instead.')
  Future<SearchResult> search({
    required String query,
    Map<String, dynamic>? filters,
    Map<String, String>? sort,
    int page = 1,
    int pageSize = 10,
  });
}

/// Result container for search operations.
class SearchResult {
  /// List of search result entities.
  final List<SearchEntity> results;
  
  /// Pagination information.
  final PaginationModel pagination;
  
  /// Total number of results found.
  final int totalResults;
  
  /// Query execution time in milliseconds.
  final int? executionTime;

  SearchResult({
    required this.results,
    required this.pagination,
    required this.totalResults,
    this.executionTime,
  });
}

