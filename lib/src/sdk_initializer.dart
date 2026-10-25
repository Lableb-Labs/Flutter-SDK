import 'package:flutter/widgets.dart';

import 'api/api_client.dart';
import 'api/interceptors/auth_interceptor.dart';
import 'di/locator.dart';
import 'domain/repositories/index_repository.dart';
import 'domain/repositories/search_repository.dart';
import 'domain/repositories/autocomplete_repository.dart';
import 'domain/repositories/recommender_repository.dart';
import 'domain/repositories/feedback_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/entities/global_settings_entity.dart';
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
///   platformName: 'your-platform-name', // the search key comes from settings
/// );
/// 
/// // Use the repositories
/// final results = await sdk.search.search(query: 'example');
/// ```
class LablebSDK {
  static LablebSDK? _instance;
  static bool _isEnabled = false;
  static String? _lang;
  static String? _sessionId;

  /// The `request_source` sent when the app passes no `requestSource` (or
  /// null) to the constructor or [init]. Lableb accepts `'mobile'` or
  /// `'web'`; an empty string stops sending it.
  static const String defaultRequestSource = 'mobile';

  /// Whether the SDK is currently enabled for the active merchant.
  static bool get isEnabled => _isEnabled;

  /// Whether the Lableb recommender feature is enabled for this merchant,
  /// per the Lableb dashboard's global settings.
  static bool get hasRecommendation => locator.isRegistered<GlobalSettings>()
      ? locator<GlobalSettings>().hasRecommendation
      : false;

  /// Whether out-of-stock products should be included in search/autocomplete
  /// results, per the Lableb dashboard's global settings.
  static bool get showOutOfStockProducts =>
      locator.isRegistered<GlobalSettings>()
          ? locator<GlobalSettings>().showOutofStackProducts
          : false;

  /// Whether the `quantity_from` search/autocomplete filter is disabled,
  /// per the Lableb dashboard's global settings.
  static bool get disableQuantityFilter =>
      locator.isRegistered<GlobalSettings>()
          ? locator<GlobalSettings>().disableQuantityFilter
          : false;

  /// The language sent as `lang` on search, autocomplete and recommend
  /// requests, or null when none is sent.
  static String? get lang => _lang;

  /// Changes the language sent as `lang` on search, autocomplete and
  /// recommend requests. Pass null or an empty string to stop sending it.
  ///
  /// Call this whenever the app's language changes; the next request uses
  /// the new value. Safe to call at any time, including before the SDK is
  /// initialized, in which case the value is applied on initialization.
  ///
  /// ```dart
  /// LablebSDK.setLang(locale.languageCode);
  /// ```
  static void setLang(String? lang) {
    _lang = lang;
    _applyRuntimeOptions();
  }

  /// The session identifier sent as `session_id` on search, autocomplete and
  /// recommend requests, or null when none is sent.
  static String? get sessionId => _sessionId;

  /// Changes the session identifier sent as `session_id` on search,
  /// autocomplete and recommend requests. Pass null or an empty string to
  /// stop sending it.
  ///
  /// Call this whenever the app starts a new session (e.g. on launch or
  /// login); the next request uses the new value. Safe to call at any time,
  /// including before the SDK is initialized, in which case the value is
  /// applied on initialization.
  ///
  /// ```dart
  /// LablebSDK.setSessionId(sessionId);
  /// ```
  static void setSessionId(String? sessionId) {
    _sessionId = sessionId;
    _applyRuntimeOptions();
  }

  /// Re-registers [LablebSdkOptions] with the current runtime values
  /// ([lang], [sessionId], and [apiKey] when given) so the next request
  /// picks them up.
  static void _applyRuntimeOptions({String? apiKey}) {
    if (!locator.isRegistered<LablebSdkOptions>()) return;

    final o = locator<LablebSdkOptions>();
    locator.unregister<LablebSdkOptions>();
    locator.registerSingleton<LablebSdkOptions>(LablebSdkOptions(
      baseUrl: o.baseUrl,
      apiKey: apiKey ?? o.apiKey,
      connectTimeout: o.connectTimeout,
      receiveTimeout: o.receiveTimeout,
      sendTimeout: o.sendTimeout,
      enableLogging: o.enableLogging,
      authType: o.authType,
      customHeaderName: o.customHeaderName,
      defaultHeaders: o.defaultHeaders,
      zidStoreId: o.zidStoreId,
      primaryColorHex: o.primaryColorHex,
      isSandbox: o.isSandbox,
      isZidIntegration: o.isZidIntegration,
      platformName: o.platformName,
      indexName: o.indexName,
      requestSource: o.requestSource,
      lang: _lang,
      sessionId: _sessionId,
    ));
  }

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
  /// [apiKey] - Your API key. Optional when [platformName] is set: if it is
  /// omitted (or empty), the SDK uses the project's `searchAPIKey` from the
  /// Lableb settings endpoint. A key passed here always wins.
  /// [connectTimeout] - Connection timeout duration (default: 30 seconds).
  /// [receiveTimeout] - Receive timeout duration (default: 30 seconds).
  /// [sendTimeout] - Send timeout duration (default: 30 seconds).
  /// [enableLogging] - Whether to enable request/response logging (default: false).
  /// [authType] - Type of authentication to use (default: Bearer token).
  /// [customHeaderName] - Custom header name for API key authentication.
  /// [defaultHeaders] - Additional default headers to include in all requests.
  /// [requestSource] - Source sent as `request_source` on search,
  /// autocomplete and recommend requests, and on feedback events that do not
  /// set their own. Null (or omitted) means [defaultRequestSource]
  /// (`'mobile'`); pass `'web'` for a web app, or an empty string to stop
  /// sending it.
  /// [lang] - Optional language (e.g. `'ar'`) sent as `lang` on search,
  /// autocomplete and recommend requests. Change it later with [setLang];
  /// when omitted, the last value passed to [setLang] is kept.
  /// [sessionId] - Optional session identifier sent as `session_id` on
  /// search, autocomplete and recommend requests. Change it later with
  /// [setSessionId]; when omitted, the last value passed to [setSessionId]
  /// is kept.
  LablebSDK({
    required String baseUrl,
    String? apiKey,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
    bool enableLogging = false,
    AuthType authType = AuthType.bearer,
    String? customHeaderName,
    Map<String, String>? defaultHeaders,
    String? platformName,
    String indexName = 'index',
    String? requestSource,
    String? lang,
    String? sessionId,
  }) {
    if (lang != null) _lang = lang;
    if (sessionId != null) _sessionId = sessionId;
    setupSdkLocator(
      LablebSdkOptions(
        baseUrl: baseUrl,
        apiKey: apiKey ?? '',
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        enableLogging: enableLogging,
        authType: authType,
        customHeaderName: customHeaderName,
        defaultHeaders: defaultHeaders,
        platformName: platformName,
        indexName: indexName,
        // Null falls back to the default so wrappers that forward a nullable
        // value do not opt out by accident; '' is the explicit opt-out.
        requestSource: requestSource ?? defaultRequestSource,
        lang: _lang,
        sessionId: _sessionId,
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

    if (platformName != null && platformName.trim().isNotEmpty) {
      // Requests await this, so none goes out before settings (and a
      // settings-provided key) are in place.
      markSettingsLoading(_loadGlobalSettings(platformName));
    }
  }

  /// Gets the underlying API client (for advanced usage).
  ApiClientBase get apiClient => _apiClient;

  /// Initialize SDK from Zid/AppsBunches JSON configuration.
  ///
  /// This is the preferred entry point for merchant integrations.
  ///
  /// `app_key` in [initialJson] is optional: without it the SDK uses the
  /// project's `searchAPIKey` from the Lableb settings endpoint, and stays
  /// disabled only if settings provide no key either.
  ///
  /// [requestSource] - Source sent as `request_source` on search,
  /// autocomplete and recommend requests, and on feedback events that do not
  /// set their own. Null (or omitted) means [defaultRequestSource]
  /// (`'mobile'`); pass `'web'` for a web app, or an empty string to stop
  /// sending it.
  /// [lang] - Optional language (e.g. `'ar'`) sent as `lang` on search,
  /// autocomplete and recommend requests. Change it later with [setLang];
  /// when omitted, the last value passed to [setLang] is kept.
  /// [sessionId] - Optional session identifier sent as `session_id` on
  /// search, autocomplete and recommend requests. Change it later with
  /// [setSessionId]; when omitted, the last value passed to [setSessionId]
  /// is kept.
  static Future<void> init({
    required Map<String, dynamic> initialJson,
    String? requestSource,
    String? lang,
    String? sessionId,
  }) async {
    if (lang != null) _lang = lang;
    if (sessionId != null) _sessionId = sessionId;
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

    // Mandatory: store 166193 must always use sandbox.
    final isSandbox = sandboxFlag || storeId == '166193';
    final baseUrl = isSandbox
        ? 'https://sandbox-api.lableb.com'
        : 'https://api.lableb.com';

    final platformName = 'zid_$storeId';

    setupSdkLocator(
      LablebSdkOptions(
        baseUrl: baseUrl,
        apiKey: apiKey,
        primaryColorHex: primaryColorHex,
        zidStoreId: storeId,
        isSandbox: isSandbox,
        isZidIntegration: true,
        platformName: platformName,
        requestSource: requestSource ?? defaultRequestSource,
        lang: _lang,
        sessionId: _sessionId,
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

    final loading = _loadGlobalSettings(platformName);
    markSettingsLoading(loading);
    await loading;

    if (locator<ApiClientBase>().apiKey.isEmpty) {
      _isEnabled = false;
      return;
    }

    LablebSDK._fromLocator();
  }

  /// Fetches merchant global settings (recommender + out-of-stock toggles)
  /// from Lableb's settings endpoint, updating the [GlobalSettings] singleton
  /// on success. When the app gave no API key, the settings' `searchAPIKey`
  /// becomes the key. Never throws — on failure the existing
  /// [GlobalSettings.unset] defaults registered by [setupSdkLocator] remain.
  static Future<void> _loadGlobalSettings(String platformName) async {
    try {
      final settings = await locator<SettingsRepository>().getSettings(
        platformName: platformName,
      );
      updateGlobalSettings(settings);

      final settingsKey = settings.searchApiKey;
      final client = locator<ApiClientBase>();
      if (client.apiKey.isEmpty &&
          settingsKey != null &&
          settingsKey.isNotEmpty &&
          client is ApiClient) {
        client.updateApiKey(settingsKey);
        _applyRuntimeOptions(apiKey: settingsKey);
      }
    } catch (_) {
      // ignore
    }
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

