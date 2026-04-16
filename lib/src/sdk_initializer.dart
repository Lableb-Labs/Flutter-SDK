import 'api/api_client.dart';
import 'di/locator.dart';
import 'domain/repositories/index_repository.dart';
import 'domain/repositories/search_repository.dart';
import 'domain/repositories/autocomplete_repository.dart';
import 'domain/repositories/recommender_repository.dart';
import 'domain/repositories/feedback_repository.dart';

/// Main SDK class for initializing and accessing Lableb API functionality.
///
/// This class provides a single entry point for all SDK operations.
/// Initialize it once with your API credentials, then use the repository
/// properties to access different API features.
///
/// Example:
/// ```dart
/// final sdk = LablebSDK(
///   baseUrl: 'https://api.lableb.com',
///   apiKey: 'your-api-key',
/// );
///
/// // Use the repositories
/// final results = await sdk.search.search(query: 'example');
/// ```
class LablebSDK {
  static LablebSDK? _instance;
  static bool _isEnabled = false;

  /// Whether the SDK is currently enabled for the active merchant.
  static bool get isEnabled => _isEnabled;

  /// Global instance used by Zid/AppsBunches integrations.
  static LablebSDK get instance {
    final current = _instance;
    if (current == null) {
      throw StateError(
        'LablebSDK is not initialized. Call LablebSDK.init(...) first.',
      );
    }
    return current;
  }

  /// The API client instance.
  late final ApiClientBase _apiClient;

  /// Repository for index operations.
  late final IndexRepository index;

  /// Repository for search operations.
  late final SearchRepository search;

  /// Repository for autocomplete operations.
  late final AutocompleteRepository autocomplete;

  /// Repository for recommender operations.
  late final RecommenderRepository recommender;

  /// Repository for feedback operations.
  late final FeedbackRepository feedback;

  LablebSDK._fromLocator() {
    _apiClient = locator<ApiClientBase>();
    index = locator<IndexRepository>();
    search = locator<SearchRepository>();
    autocomplete = locator<AutocompleteRepository>();
    recommender = locator<RecommenderRepository>();
    feedback = locator<FeedbackRepository>();
    _instance = this;
  }

  /// Creates a new [LablebSDK] instance.
  ///
  /// [baseUrl] - The base URL of the Lableb API (e.g., 'https://api.lableb.com').
  /// [apiKeySearch] - API key used for search and non-index requests.
  /// [apiKeyIndex] - API key used for index create/update/delete requests.
  /// [connectTimeout] - Connection timeout duration (default: 30 seconds).
  /// [receiveTimeout] - Receive timeout duration (default: 30 seconds).
  /// [sendTimeout] - Send timeout duration (default: 30 seconds).
  /// [enableLogging] - Whether to enable request/response logging (default: false).
  /// [defaultHeaders] - Additional default headers to include in all requests.
  LablebSDK({
    required String baseUrl,
    required String apiKeySearch,
    required String apiKeyIndex,
    required String projectId,
    required String indexName,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
    bool enableLogging = false,
    Map<String, String>? defaultHeaders,
  }) {
    setupSdkLocator(
      LablebSdkOptions(
        baseUrl: baseUrl,
        apiKeySearch: apiKeySearch,
        apiKeyIndex: apiKeyIndex,
        projectId: projectId,
        indexName: indexName,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        enableLogging: enableLogging,
        defaultHeaders: defaultHeaders,
      ),
      reset: true,
    );

    _apiClient = locator<ApiClientBase>();
    index = locator<IndexRepository>();
    search = locator<SearchRepository>();
    autocomplete = locator<AutocompleteRepository>();
    recommender = locator<RecommenderRepository>();
    feedback = locator<FeedbackRepository>();
    _instance = this;
    _isEnabled = true;
  }

  /// Gets the underlying API client (for advanced usage).
  ApiClientBase get apiClient => _apiClient;

  /// Initialize SDK from Zid/AppsBunches JSON configuration.
  ///
  /// This is the preferred entry point for merchant integrations.
  static Future<void> init({
    required Map<String, dynamic> initialJson,
  }) async {
    final status = initialJson['status'] as bool? ?? false;
    _isEnabled = status;
    if (!status) {
      return;
    }

    final apiKey = (initialJson['app_key'] as String?)?.trim() ?? '';

    if (apiKey.isEmpty) {
      _isEnabled = false;
      return;
    }

    final baseUrl = 'https://api.lableb.com';

    setupSdkLocator(
      LablebSdkOptions(
        baseUrl: baseUrl,
        apiKeySearch: apiKey,
        apiKeyIndex: apiKey,
      ),
      reset: true,
    );

    LablebSDK._fromLocator();
  }
}
