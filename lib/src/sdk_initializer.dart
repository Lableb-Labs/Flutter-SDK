import 'package:flutter/widgets.dart';

import 'api/api_client.dart';
import 'api/interceptors/auth_interceptor.dart';
import 'di/locator.dart';
import 'domain/repositories/index_repository.dart';
import 'domain/repositories/search_repository.dart';
import 'domain/repositories/autocomplete_repository.dart';
import 'domain/repositories/recommender_repository.dart';
import 'domain/repositories/feedback_repository.dart';
import 'analytics/analytics_builder.dart';
import 'cart/cart_event_builder.dart';
import 'cart/cart_event_bus.dart';
import 'ui/lableb_recommendation_widget.dart';
import 'zid/zid_secure_storage.dart';

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
  /// [apiKey] - Your API key for authentication.
  /// [connectTimeout] - Connection timeout duration (default: 30 seconds).
  /// [receiveTimeout] - Receive timeout duration (default: 30 seconds).
  /// [sendTimeout] - Send timeout duration (default: 30 seconds).
  /// [enableLogging] - Whether to enable request/response logging (default: false).
  /// [authType] - Type of authentication to use (default: Bearer token).
  /// [customHeaderName] - Custom header name for API key authentication.
  /// [defaultHeaders] - Additional default headers to include in all requests.
  LablebSDK({
    required String baseUrl,
    required String apiKey,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
    bool enableLogging = false,
    AuthType authType = AuthType.bearer,
    String? customHeaderName,
    Map<String, String>? defaultHeaders,
  }) {
    setupSdkLocator(
      LablebSdkOptions(
        baseUrl: baseUrl,
        apiKey: apiKey,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        enableLogging: enableLogging,
        authType: authType,
        customHeaderName: customHeaderName,
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
    final token = (initialJson['token'] as String?)?.trim() ?? '';
    final primaryColorHex =
        (initialJson['primary_color'] as String?)?.trim() ?? '#000000';
    final storeId = initialJson['store_id']?.toString() ?? '';
    final sandboxFlag = initialJson['sandbox'] as bool? ?? false;

    if (apiKey.isEmpty) {
      _isEnabled = false;
      return;
    }

    // Mandatory: store 166193 must always use sandbox.
    final isSandbox = sandboxFlag || storeId == '166193';
    final baseUrl = isSandbox
        ? 'https://sandbox-api.lableb.com'
        : 'https://api.lableb.com';

    setupSdkLocator(
      LablebSdkOptions(
        baseUrl: baseUrl,
        apiKey: apiKey,
        primaryColorHex: primaryColorHex,
        zidStoreId: storeId,
        isSandbox: isSandbox,
        isZidIntegration: true,
      ),
      reset: true,
    );

    // Persist sensitive token in encrypted storage, but never crash if it fails.
    try {
      final secure = locator<ZidSecureStorage>();
      await secure.saveToken(token);
    } catch (_) {
      // ignore
    }

    LablebSDK._fromLocator();
  }

  /// Track navigation events for analytics (Requirement 6.1).
  static Future<void> trackPageRoute({required String pageName}) async {
    await locator<PageRouteTrackingBuilderStart>()
        .forPage(pageName)
        .send();
  }

  /// Register cart event handlers so Lableb widgets can talk to host app (6.2).
  static Future<void> registerCartEventHandlers({
    required AddToCartCallback onAddToCart,
    required RemoveFromCartCallback onRemoveFromCart,
  }) async {
    await locator<CartEventHandlersBuilderStart>()
        .onAddToCart(onAddToCart)
        .onRemoveFromCart(onRemoveFromCart)
        .send();
  }

  /// Convenience widget factory for product recommendations (6.3/6.6).
  static Widget recommendationsWidget({required String productId}) {
    return LablebRecommendationWidget(productId: productId);
  }
}

