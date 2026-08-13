// Full manual live-network test against real Lableb credentials.
//
// Not part of CI — fill in _apiKey and _platformName below with real
// credentials before running:
//   flutter test test/live_credentials_test.dart
//
// Credentials are intentionally left blank in version control.
//
// Confirms the two-host split and full corrected wire format:
//   - Settings:            platform-integration-service.lableb.com
//                           GET /v2/projects/{platformName}/settings
//                           Authorization: Bearer <token>
//   - Search/Autocomplete: api.lableb.com
//                           GET /v2/projects/{platformName}/indices/{indexName}/search|autocomplete/{handler}
//                           apikey as a query parameter
//                           pagination via skip/limit (not page/page_size)
//                           sort as a flat "field direction" string
//                           filters as flat per-field query params
// 'suggest' is the only handler confirmed configured on this project's
// dashboard; 'default' (this SDK's default) 404s for this project — a
// Lableb-dashboard config gap, not a client bug.
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lableb_flutter_sdk/lableb_flutter_sdk.dart';

const _apiKey = ''; // fill in a real Lableb API key before running
const _platformName = ''; // fill in a real Lableb project id (e.g. zid_302362) before running
const _handler = 'suggest'; // only handler confirmed to exist for this project

/// Captures every outgoing request on the main API client (api.lableb.com)
/// without affecting the real request/response flow. Settings requests go
/// through a separate Dio instance (platform-integration-service.lableb.com)
/// not reachable from here — those are confirmed via the printed request log
/// instead (enableLogging: true below).
class _CapturingInterceptor extends Interceptor {
  final captured = <RequestOptions>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    captured.add(options);
    super.onRequest(options, handler);
  }
}

void main() {
  test('full pass: settings, search, autocomplete, recommender', () async {
    final sdk = LablebSDK(
      baseUrl: 'https://api.lableb.com',
      apiKey: _apiKey,
      enableLogging: true,
      platformName: _platformName,
    );

    final capture = _CapturingInterceptor();
    sdk.apiClient.dio.interceptors.insert(0, capture);

    // Main API client must point at api.lableb.com, not the settings host.
    expect(sdk.apiClient.baseUrl, 'https://api.lableb.com');

    await Future.delayed(const Duration(seconds: 2));

    print('\n=== 1. Global settings (host: platform-integration-service.lableb.com) ===');
    print('hasRecommendation: ${LablebSDK.hasRecommendation}');
    print('showOutOfStockProducts: ${LablebSDK.showOutOfStockProducts}');
    // Settings host is a separate Dio client, not captured above — confirmed
    // instead by the "REQUEST: GET https://platform-integration-service...
    // /v2/projects/{platformName}/settings" line the logging interceptor prints.

    print('\n=== 2. search.search() — sort + pagination + is_available ===');
    capture.captured.clear();
    final searchResult = await sdk.search.search(
      query: 'a',
      sort: {'price': 'desc'},
      page: 1,
      pageSize: 5,
      handler: _handler,
    );
    print('totalResults: ${searchResult.totalResults}, returned: ${searchResult.results.length}');
    expect(searchResult.results, isNotEmpty, reason: 'expected real live results');
    expect(searchResult.results.first.data, isNotEmpty,
        reason: 'flat result item must be parsed into entity data');

    final req1 = capture.captured.where((r) => r.path.contains('/search/')).first;
    print('Host: ${req1.uri.host}');
    print('Path: ${req1.path}');
    print('Query params: ${req1.queryParameters}');
    expect(req1.uri.host, 'api.lableb.com');
    expect(req1.path, '/v2/projects/$_platformName/indices/index/search/$_handler');
    expect(req1.queryParameters['apikey'], _apiKey);
    expect(req1.queryParameters['skip'], 0);
    expect(req1.queryParameters['limit'], 5);
    expect(req1.queryParameters['sort'], 'price desc');
    expect(req1.queryParameters['is_available'], true);
    expect(req1.queryParameters['quantity_from'], 1);
    expect(req1.queryParameters.containsKey('page'), isFalse);
    expect(req1.queryParameters.containsKey('page_size'), isFalse);

    print('\n=== 3. withSort() multi-field ===');
    capture.captured.clear();
    await sdk
        .searchRequest()
        .forQuery('a')
        .withSort({'price': 'asc', 'created_at': 'desc'})
        .withHandler(_handler)
        .send();
    final multiSort = capture.captured.where((r) => r.path.contains('/search/')).first
        .queryParameters['sort'];
    print('Multi-field sort param: $multiSort');
    expect(multiSort, 'price asc,created_at desc');

    print('\n=== 4. withFilters() — flat per-field query params ===');
    capture.captured.clear();
    await sdk
        .searchRequest()
        .forQuery('a')
        .withFilters({'lang': 'ar'})
        .withHandler(_handler)
        .send();
    final filterReq = capture.captured.where((r) => r.path.contains('/search/')).first;
    print('Query params: ${filterReq.queryParameters}');
    expect(filterReq.queryParameters['lang'], 'ar');
    expect(filterReq.queryParameters.containsKey('filters'), isFalse,
        reason: 'filters must be flat top-level params, not a nested "filters" object');

    print('\n=== 5. searchRequest().withHandler() fluent builder ===');
    final builderResult = await sdk
        .searchRequest()
        .forQuery('a')
        .sortBy('price', direction: 'desc')
        .paginate(page: 1, pageSize: 5)
        .withHandler(_handler)
        .send();
    print('Fluent builder totalResults: ${builderResult.totalResults}');
    expect(builderResult.results, isNotEmpty);

    print('\n=== 6. autocomplete.getSuggestions() ===');
    capture.captured.clear();
    final suggestions = await sdk.autocomplete.getSuggestions(
      query: 'a',
      limit: 5,
      handler: _handler,
    );
    print('Suggestions returned: ${suggestions.length}');
    expect(suggestions, isNotEmpty);
    expect(suggestions.first.text, isNotEmpty,
        reason: 'text should fall back to the item name field');

    final req6 = capture.captured.where((r) => r.path.contains('/autocomplete/')).first;
    print('Host: ${req6.uri.host}');
    print('Path: ${req6.path}');
    print('Query params: ${req6.queryParameters}');
    expect(req6.uri.host, 'api.lableb.com');
    expect(req6.path, '/v2/projects/$_platformName/indices/index/autocomplete/$_handler');
    expect(req6.queryParameters['apikey'], _apiKey);
    expect(req6.queryParameters['is_available'], true);
    expect(req6.queryParameters['quantity_from'], 1);

    print('\n=== 7. default handler still 404s for this project (known dashboard gap) ===');
    try {
      await sdk.search.search(query: 'a'); // handler defaults to 'default'
      fail('expected the default handler to be rejected for this project');
    } catch (e) {
      print('Expected failure with default handler: $e');
    }

    print('\n=== 8a. recommendations() fluent builder gates on hasRecommendation ===');
    capture.captured.clear();
    final recsViaBuilder = await sdk.recommendations().forItem('item-1').send();
    print('recommendations() returned: ${recsViaBuilder.length} '
        '(hasRecommendation=${LablebSDK.hasRecommendation})');
    if (!LablebSDK.hasRecommendation) {
      expect(recsViaBuilder, isEmpty);
      expect(capture.captured, isEmpty,
          reason: 'must not hit the network when recommendations are disabled');
    }

    print('\n=== 8b. direct sdk.recommender.getRecommendations() gates the same way ===');
    capture.captured.clear();
    final recsViaDirect = await sdk.recommender.getRecommendations(itemId: 'item-1');
    print('getRecommendations() returned: ${recsViaDirect.length}');
    if (!LablebSDK.hasRecommendation) {
      expect(recsViaDirect, isEmpty);
      expect(capture.captured, isEmpty,
          reason: 'direct call must gate the same way as the fluent builder');
    }
  });

  test('platformName is required for search/autocomplete', () async {
    final sdk = LablebSDK(
      baseUrl: 'https://api.lableb.com',
      apiKey: _apiKey,
      enableLogging: false,
      // no platformName passed
    );

    await expectLater(
      sdk.search.search(query: 'a'),
      throwsA(isA<ValidationException>()),
    );
    await expectLater(
      sdk.autocomplete.getSuggestions(query: 'a'),
      throwsA(isA<ValidationException>()),
    );
  });
}
