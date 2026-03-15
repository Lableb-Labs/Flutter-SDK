import '../../api/api_client.dart';
import '../../domain/entities/autocomplete_entity.dart';
import '../../domain/repositories/autocomplete_repository.dart';
import '../requests/autocomplete_request.dart';
import '../responses/autocomplete_response.dart';

/// Implementation of [AutocompleteRepository] for autocomplete operations.
/// 
/// This repository handles all communication with the autocomplete API endpoints.
class AutocompleteRepositoryImpl implements AutocompleteRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  AutocompleteRepositoryImpl(this._apiClient);

  @override
  Future<List<AutocompleteEntity>> getSuggestions({
    required String query,
    int limit = 10,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final request = AutocompleteRequest(
        query: query,
        limit: limit,
        filters: filters,
      );

      final response = await _apiClient.get(
        '/autocomplete',
        queryParameters: request.toQueryParameters(),
      );

      final autocompleteResponse = AutocompleteResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return autocompleteResponse.suggestions
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

