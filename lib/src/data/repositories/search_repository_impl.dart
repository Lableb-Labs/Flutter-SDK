import '../../api/api_client.dart';
import '../../domain/repositories/search_repository.dart';
import '../requests/search_request.dart';
import '../responses/search_response.dart';

/// Implementation of [SearchRepository] for search operations.
/// 
/// This repository handles all communication with the search API endpoints.
class SearchRepositoryImpl implements SearchRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  SearchRepositoryImpl(this._apiClient);

  @override
  Future<SearchResult> search({
    required String query,
    Map<String, dynamic>? filters,
    Map<String, String>? sort,
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final request = SearchRequest(
        query: query,
        filters: filters,
        sort: sort,
        page: page,
        pageSize: pageSize,
      );

      final response = await _apiClient.get(
        '/search',
        queryParameters: request.toQueryParameters(),
      );

      final searchResponse = SearchResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return SearchResult(
        results: searchResponse.results
            .map((model) => model.toEntity())
            .toList(),
        pagination: searchResponse.pagination,
        totalResults: searchResponse.totalResults,
        executionTime: searchResponse.executionTime,
      );
    } catch (e) {
      rethrow;
    }
  }
}

