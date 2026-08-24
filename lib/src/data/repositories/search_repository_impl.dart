import '../../api/api_client.dart';
import '../../di/locator.dart';
import '../../domain/entities/global_settings_entity.dart';
import '../../domain/repositories/search_repository.dart';
import '../../exceptions/exceptions.dart';
import '../requests/search_request.dart';
import '../responses/search_response.dart';

/// Implementation of [SearchRepository] for search operations.
///
/// Per Lableb's REST API docs (docs.lableb.com/docs/cse/rest), search is
/// scoped to `/v2/projects/{platformName}/indices/{indexName}/search/{handler}`
/// and authenticates via an `apikey` query parameter — not the
/// `Authorization: Bearer` header the rest of this SDK's [ApiClientBase]
/// sends by default (that header is harmless to leave in place).
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
    String handler = 'default',
  }) async {
    try {
      final options = locator<LablebSdkOptions>();
      final platformName = options.platformName;
      if (platformName == null || platformName.trim().isEmpty) {
        throw ValidationException(
          'platformName is required to perform search. Pass platformName '
          'when constructing LablebSDK (see docs.lableb.com/docs/cse/rest).',
        );
      }

      final request = SearchRequest(
        query: query,
        filters: filters,
        sort: sort,
        page: page,
        pageSize: pageSize,
      );

      final queryParameters = request.toQueryParameters();
      queryParameters['apikey'] = _apiClient.apiKey;
      final globalSettings = locator<GlobalSettings>();
      if (!globalSettings.showOutofStackProducts) {
        queryParameters['is_available'] = true;
        if (!globalSettings.disableQuantityFilter) {
          queryParameters['quantity_from'] = 1;
        }
      }

      final response = await _apiClient.get(
        '/v2/projects/$platformName/indices/${options.indexName}/search/$handler',
        queryParameters: queryParameters,
      );

      final searchResponse = SearchResponse.fromJson(
        response.data as Map<String, dynamic>,
        page: page,
        pageSize: pageSize,
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

