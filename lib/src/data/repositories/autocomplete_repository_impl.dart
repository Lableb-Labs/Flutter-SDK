import '../../api/api_client.dart';
import '../../domain/repositories/autocomplete_repository.dart';
import '../requests/autocomplete_request.dart';
import '../responses/matching_response.dart';

/// Implementation of [AutocompleteRepository] for autocomplete operations.
///
/// This repository handles all communication with the autocomplete API endpoints.
class AutocompleteRepositoryImpl implements AutocompleteRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  AutocompleteRepositoryImpl(this._apiClient);

  @override
  Future<MatchingResponse> getSuggestions({
    String? handler,
    required String query,
    int limit = 10,
    Map<String, dynamic>? filters,
    String? sessionId,
    String? userId,
    String? userIp,
    String? userCountry,
    String? requestSource,
  }) async {
    try {
      final request = AutocompleteRequest(
        query: query,
        limit: limit,
        filters: filters,
      );

      final queryParams = request.toQueryParameters();
      if (sessionId != null) queryParams['session_id'] = sessionId;
      if (userId != null) queryParams['user_id'] = userId;
      if (userIp != null) queryParams['user_ip'] = userIp;
      if (userCountry != null) queryParams['user_country'] = userCountry;
      if (requestSource != null) queryParams['request_source'] = requestSource;

      final path = (handler?.isNotEmpty ?? false)
          ? '/autocomplete/$handler'
          : '/autocomplete';

      final response = await _apiClient.get(
        path,
        queryParameters: queryParams,
      );

      final autocompleteResponse = MatchingResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return autocompleteResponse;
    } catch (e) {
      rethrow;
    }
  }
}
