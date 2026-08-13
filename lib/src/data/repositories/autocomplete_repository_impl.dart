import '../../api/api_client.dart';
import '../../di/locator.dart';
import '../../domain/entities/autocomplete_entity.dart';
import '../../domain/entities/global_settings_entity.dart';
import '../../domain/repositories/autocomplete_repository.dart';
import '../../exceptions/exceptions.dart';
import '../requests/autocomplete_request.dart';
import '../responses/autocomplete_response.dart';

/// Implementation of [AutocompleteRepository] for autocomplete operations.
///
/// Per Lableb's REST API docs, autocomplete is scoped to
/// `/v2/projects/{platformName}/indices/{indexName}/autocomplete/{handler}`
/// and authenticates via an `apikey` query parameter.
class AutocompleteRepositoryImpl implements AutocompleteRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  AutocompleteRepositoryImpl(this._apiClient);

  @override
  Future<List<AutocompleteEntity>> getSuggestions({
    required String query,
    int limit = 10,
    Map<String, dynamic>? filters,
    String handler = 'default',
  }) async {
    try {
      final options = locator<LablebSdkOptions>();
      final platformName = options.platformName;
      if (platformName == null || platformName.trim().isEmpty) {
        throw ValidationException(
          'platformName is required to perform autocomplete. Pass '
          'platformName when constructing LablebSDK '
          '(see docs.lableb.com/docs/cse/rest).',
        );
      }

      final request = AutocompleteRequest(
        query: query,
        limit: limit,
        filters: filters,
      );

      final queryParameters = request.toQueryParameters();
      queryParameters['apikey'] = _apiClient.apiKey;
      if (!locator<GlobalSettings>().showOutofStackProducts) {
        queryParameters['is_available'] = true;
        queryParameters['quantity_from'] = 1;
      }

      final response = await _apiClient.get(
        '/v2/projects/$platformName/indices/${options.indexName}/autocomplete/$handler',
        queryParameters: queryParameters,
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

