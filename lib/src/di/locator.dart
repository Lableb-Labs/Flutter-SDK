import 'package:get_it/get_it.dart';

import '../api/api_client.dart';
import '../api/interceptors/auth_interceptor.dart';
import '../api/settings_api_client.dart';
import '../data/repositories/autocomplete_repository_impl.dart';
import '../data/repositories/feedback_repository_impl.dart';
import '../data/repositories/index_repository_impl.dart';
import '../data/repositories/recommender_repository_impl.dart';
import '../data/repositories/search_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';
import '../domain/entities/global_settings_entity.dart';
import '../domain/repositories/autocomplete_repository.dart';
import '../domain/repositories/feedback_repository.dart';
import '../domain/repositories/index_repository.dart';
import '../domain/repositories/recommender_repository.dart';
import '../domain/repositories/search_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../feedback/search_feedback_event_builder.dart';
import '../feedback/autocomplete_feedback_builder.dart';
import '../feedback/legacy_search_feedback_builder.dart';
import '../feedback/recommender_feedback_builder.dart';
import '../recommender/recommendations_builder.dart';
import '../search/search_request_builder.dart';
import '../zid/zid_config.dart';
import '../zid/zid_secure_storage.dart';
import '../analytics/analytics_builder.dart';
import '../analytics/analytics_service.dart';
import '../cart/cart_event_bus.dart';
import '../cart/cart_event_builder.dart';

/// Global service locator for the SDK.
final GetIt locator = GetIt.instance;

/// Immutable configuration for initializing the SDK.
class LablebSdkOptions {
  final String baseUrl;
  final String apiKey;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
  final AuthType authType;
  final String? customHeaderName;
  final Map<String, String>? defaultHeaders;
  final String? zidStoreId;
  final String? primaryColorHex;
  final bool isSandbox;
  final bool isZidIntegration;
  final String? platformName;

  /// Lableb index name for this project (`/indices/{indexName}/...`).
  ///
  /// Per Lableb's REST docs, every search/autocomplete request is scoped to
  /// a specific index under the project. Defaults to `'index'`, which is
  /// the convention Zid-integrated projects are provisioned with.
  final String indexName;

  const LablebSdkOptions({
    required this.baseUrl,
    required this.apiKey,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.enableLogging = false,
    this.authType = AuthType.bearer,
    this.customHeaderName,
    this.defaultHeaders,
    this.zidStoreId,
    this.primaryColorHex,
    this.isSandbox = false,
    this.isZidIntegration = false,
    this.platformName,
    this.indexName = 'index',
  });
}

/// Initializes and registers all SDK services in [locator].
///
/// This uses:
/// - `registerLazySingleton` for core services + repositories
/// - `registerFactory` for transient builder objects
///
/// If you need to register async-initialized services in the future, add them
/// with `registerSingletonAsync` and call [sdkAllReady] before use.
void setupSdkLocator(
  LablebSdkOptions options, {
  bool reset = true,
}) {
  if (reset) {
    _unregisterAll();
  }

  _replaceSingleton<LablebSdkOptions>(options);

  if (options.isZidIntegration) {
    _replaceSingleton<ZidConfig>(
      ZidConfig(
        storeId: options.zidStoreId ?? '',
        isSandbox: options.isSandbox,
        primaryColorHex: options.primaryColorHex ?? '#000000',
        isEnabled: true,
      ),
    );
  } else {
    _safeUnregister<ZidConfig>();
  }

  // Core services (registered against abstract base types).
  _replaceLazySingleton<ApiClientBase>(
    () => ApiClient(
      baseUrl: options.baseUrl,
      apiKey: options.apiKey,
      connectTimeout: options.connectTimeout,
      receiveTimeout: options.receiveTimeout,
      sendTimeout: options.sendTimeout,
      enableLogging: options.enableLogging,
      authType: options.authType,
      customHeaderName: options.customHeaderName,
      defaultHeaders: options.defaultHeaders,
    ),
  );

  // Repositories (registered against abstract interfaces).
  _replaceLazySingleton<IndexRepository>(
    () => IndexRepositoryImpl(locator<ApiClientBase>()),
  );
  _replaceLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(locator<ApiClientBase>()),
  );
  _replaceLazySingleton<AutocompleteRepository>(
    () => AutocompleteRepositoryImpl(locator<ApiClientBase>()),
  );
  _replaceLazySingleton<RecommenderRepository>(
    () => RecommenderRepositoryImpl(locator<ApiClientBase>()),
  );
  _replaceLazySingleton<FeedbackRepository>(
    () => FeedbackRepositoryImpl(locator<ApiClientBase>()),
  );

  // Settings endpoint (separate host from the rest of the SDK).
  _replaceLazySingleton<SettingsApiClient>(
    () => SettingsApiClient(
      apiKey: options.apiKey,
      enableLogging: options.enableLogging,
    ),
  );
  _replaceLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(locator<SettingsApiClient>()),
  );
  _replaceSingleton<GlobalSettings>(const GlobalSettings.unset());

  // Zid secure storage (lazy, merchant-specific).
  _replaceLazySingleton<ZidSecureStorage>(() => ZidSecureStorageImpl());

  // Analytics + cart services (lazy).
  _replaceLazySingleton<AnalyticsService>(() => ConsoleAnalyticsService());
  _replaceLazySingleton<CartEventBus>(() => CartEventBus());

  // Transient objects.
  _replaceFactory<SearchFeedbackEventBuilderStart>(
    () => SearchFeedbackEventBuilder(),
  );
  _replaceFactory<AutocompleteFeedbackBuilderStart>(
    () => AutocompleteFeedbackBuilder(),
  );
  _replaceFactory<RecommenderFeedbackBuilderStart>(
    () => RecommenderFeedbackBuilder(),
  );
  _replaceFactory<LegacySearchFeedbackBuilderStart>(
    () => LegacySearchFeedbackBuilder(),
  );
  _replaceFactory<SearchRequestBuilderStart>(
    () => SearchRequestBuilder(),
  );
  _replaceFactory<RecommendationsBuilderStart>(
    () => RecommendationsBuilder(),
  );
  _replaceFactory<PageRouteTrackingBuilderStart>(
    () => PageRouteTrackingBuilder(),
  );
  _replaceFactory<CartEventHandlersBuilderStart>(
    () => CartEventHandlersBuilder(),
  );
}

void _unregisterAll() {
  _safeUnregister<GlobalSettings>();
  _safeUnregister<SettingsRepository>();
  _safeUnregister<SettingsApiClient>();
  _safeUnregister<RecommendationsBuilderStart>();
  _safeUnregister<SearchRequestBuilderStart>();
  _safeUnregister<CartEventHandlersBuilderStart>();
  _safeUnregister<PageRouteTrackingBuilderStart>();
  _safeUnregister<LegacySearchFeedbackBuilderStart>();
  _safeUnregister<RecommenderFeedbackBuilderStart>();
  _safeUnregister<AutocompleteFeedbackBuilderStart>();
  _safeUnregister<SearchFeedbackEventBuilderStart>();
  _safeUnregister<CartEventBus>();
  _safeUnregister<AnalyticsService>();
  _safeUnregister<FeedbackRepository>();
  _safeUnregister<RecommenderRepository>();
  _safeUnregister<AutocompleteRepository>();
  _safeUnregister<SearchRepository>();
  _safeUnregister<IndexRepository>();
  _safeUnregister<ApiClientBase>();
  _safeUnregister<ZidSecureStorage>();
  _safeUnregister<ZidConfig>();
  _safeUnregister<LablebSdkOptions>();
}

void _safeUnregister<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}

void _replaceSingleton<T extends Object>(T instance) {
  _safeUnregister<T>();
  locator.registerSingleton<T>(instance);
}

void _replaceLazySingleton<T extends Object>(T Function() factoryFunc) {
  _safeUnregister<T>();
  locator.registerLazySingleton<T>(factoryFunc);
}

void _replaceFactory<T extends Object>(T Function() factoryFunc) {
  _safeUnregister<T>();
  locator.registerFactory<T>(factoryFunc);
}

/// Replaces the registered [GlobalSettings] singleton once settings have
/// been fetched from the Lableb settings endpoint.
void updateGlobalSettings(GlobalSettings settings) {
  _replaceSingleton<GlobalSettings>(settings);
}

/// Await readiness for async-registered singletons.
///
/// This is a no-op today (we don't have async registrations yet), but it
/// becomes important as soon as `registerSingletonAsync` is introduced.
Future<void> sdkAllReady() => locator.allReady();

