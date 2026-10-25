import '../../api/api_client.dart';
import '../../di/locator.dart';
import '../../domain/entities/global_settings_entity.dart';
import '../../domain/entities/recommender_entity.dart';
import '../../domain/repositories/recommender_repository.dart';
import '../../exceptions/exceptions.dart';
import '../requests/recommender_request.dart';
import '../responses/recommender_response.dart';

/// Implementation of [RecommenderRepository] for recommendation operations.
///
/// Per Lableb's REST API docs (docs.lableb.com/docs/cse/rest/recommendations),
/// recommendations are scoped to
/// `/v2/projects/{platformName}/indices/{indexName}/recommend`, take the
/// source document as an `id` query parameter, and authenticate via an
/// `apikey` query parameter. The handler segment is optional and omitted, so
/// the project's default handler is used.
///
/// The docs label the method `POST`, but the live API answers `POST` with
/// `405 Method Not Allowed`; it is a `GET`, like search.
class RecommenderRepositoryImpl implements RecommenderRepository {
  /// The API client for making HTTP requests.
  final ApiClientBase _apiClient;

  RecommenderRepositoryImpl(this._apiClient);

  @override
  Future<List<RecommenderEntity>> getRecommendations({
    String? userId,
    String? itemId,
    int limit = 10,
    Map<String, dynamic>? filters,
    Map<String, dynamic>? context,
  }) async {
    await sdkSettingsReady();
    if (!locator<GlobalSettings>().hasRecommendation) {
      return const <RecommenderEntity>[];
    }

    try {
      final options = locator.isRegistered<LablebSdkOptions>()
          ? locator<LablebSdkOptions>()
          : null;
      final platformName = options?.platformName;
      if (options == null ||
          platformName == null ||
          platformName.trim().isEmpty) {
        throw ValidationException(
          'platformName is required to get recommendations. Pass '
          'platformName when constructing LablebSDK (see '
          'docs.lableb.com/docs/cse/rest/recommendations).',
        );
      }
      if (itemId == null || itemId.trim().isEmpty) {
        throw ValidationException(
          'An item id is required to get recommendations: Lableb recommends '
          'documents similar to a source item. Use forItem(...) or '
          'fromUserForItem(...) (see '
          'docs.lableb.com/docs/cse/rest/recommendations).',
        );
      }

      final request = RecommenderRequest(
        userId: userId,
        itemId: itemId,
        limit: limit,
        filters: filters,
        context: context,
        requestSource: options.requestSource,
        lang: options.lang,
        sessionId: options.sessionId,
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
        '/v2/projects/$platformName/indices/${options.indexName}/recommend',
        queryParameters: queryParameters,
      );

      final recommenderResponse = RecommenderResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return recommenderResponse.recommendations
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

