import 'package:get_it/get_it.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/index_repository_impl.dart';

import '../api/api_client.dart';
import '../data/repositories/autocomplete_repository_impl.dart';
import '../data/repositories/feedback_repository_impl.dart';
import '../data/repositories/recommender_repository_impl.dart';
import '../data/repositories/search_repository_impl.dart';
import '../domain/repositories/autocomplete_repository.dart';
import '../domain/repositories/feedback_repository.dart';
import '../domain/repositories/index_repository.dart';
import '../domain/repositories/recommender_repository.dart';
import '../domain/repositories/search_repository.dart';

/// Global service locator for the SDK.
final GetIt locator = GetIt.instance;

/// Immutable configuration for initializing the SDK.
class LablebSdkOptions {
  final String baseUrl;
  final String apiKeySearch;
  final String apiKeyIndex;
  final String? projectId;
  final String? indexName;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final bool enableLogging;
  final Map<String, String>? defaultHeaders;

  const LablebSdkOptions(
      {required this.baseUrl,
      required this.apiKeySearch,
      required this.apiKeyIndex,
      this.projectId,
      this.indexName,
      this.connectTimeout = const Duration(seconds: 30),
      this.receiveTimeout = const Duration(seconds: 30),
      this.sendTimeout = const Duration(seconds: 30),
      this.enableLogging = false,
      this.defaultHeaders});
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

  // Core services (registered against abstract base types).
  _replaceLazySingleton<ApiClientBase>(
    () => ApiClient(
      baseUrl: options.baseUrl,
      apiKeySearch: options.apiKeySearch,
      apiKeyIndex: options.apiKeyIndex,
      projectId: options.projectId,
      indexName: options.indexName,
      connectTimeout: options.connectTimeout,
      receiveTimeout: options.receiveTimeout,
      sendTimeout: options.sendTimeout,
      enableLogging: options.enableLogging,
      defaultHeaders: options.defaultHeaders,
    ),
  );

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
}

void _unregisterAll() {
  _safeUnregister<RecommenderRepository>();
  _safeUnregister<AutocompleteRepository>();
  _safeUnregister<SearchRepository>();
  _safeUnregister<IndexRepository>();
  _safeUnregister<ApiClientBase>();
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

/// Await readiness for async-registered singletons.
///
/// This is a no-op today (we don't have async registrations yet), but it
/// becomes important as soon as `registerSingletonAsync` is introduced.
Future<void> sdkAllReady() => locator.allReady();
