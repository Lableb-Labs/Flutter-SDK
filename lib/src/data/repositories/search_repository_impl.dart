import 'dart:isolate';
import '../../api/api_client.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/search_repository.dart';
import '../requests/search_request.dart';
import '../../data/responses/matching_response.dart';

/// Implementation of [SearchRepository] for search operations.
///
/// This repository handles all communication with the search API endpoints.
class SearchRepositoryImpl implements SearchRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  SearchRepositoryImpl(this._apiClient);

  @override
  Future<MatchingResponse> search({
    String? handler,
    required String query,
    Map<String, dynamic>? filters,
    String? sort,
    int page = 1,
    int pageSize = 10,
    String? sessionId,
    String? userId,
    String? userIp,
    String? userCountry,
    String? requestSource,
    CancelToken? cancelToken,
  }) async {
    try {
      final request = SearchRequest(
        query: query,
        filters: filters,
        sort: sort,
        page: page,
        pageSize: pageSize,
      );

      final queryParams = request.toQueryParameters();
      if (sessionId != null) queryParams['session_id'] = sessionId;
      if (userId != null) queryParams['user_id'] = userId;
      if (userIp != null) queryParams['user_ip'] = userIp;
      if (userCountry != null) queryParams['user_country'] = userCountry;
      if (requestSource != null) queryParams['request_source'] = requestSource;

      final path =
          (handler?.isNotEmpty ?? false) ? '/search/$handler' : '/search';

      final response = await _apiClient.get(
        path,
        queryParameters: queryParams,
        cancelToken: cancelToken,
      );

      final responseData = response.data as Map<String, dynamic>;
      final searchResponse = await Isolate.run(
        () => MatchingResponse.fromJson(responseData),
      );

      return searchResponse;
    } catch (e) {
      rethrow;
    }
  }
}
