import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/search_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/di/locator.dart';
import 'package:lableb_flutter_sdk/src/domain/entities/global_settings_entity.dart';
import 'package:lableb_flutter_sdk/src/sdk_initializer.dart';

import '../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late SearchRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClientBase();
    when(mockApiClient.apiKey).thenReturn('test-api-key');
    when(mockApiClient.get(
      any,
      queryParameters: anyNamed('queryParameters'),
    )).thenAnswer((_) async => Response<dynamic>(
          data: {
            'time': 10,
            'code': 200,
            'response': {'found_documents': 0, 'results': []},
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/search'),
        ));
    repository = SearchRepositoryImpl(mockApiClient);
    locator.registerSingleton<GlobalSettings>(const GlobalSettings());
  });

  tearDown(() {
    LablebSDK.setLang(null);
    LablebSDK.setSessionId(null);
    if (locator.isRegistered<LablebSdkOptions>()) {
      locator.unregister<LablebSdkOptions>();
    }
    if (locator.isRegistered<GlobalSettings>()) {
      locator.unregister<GlobalSettings>();
    }
  });

  Future<Map<String, dynamic>> searchParams() async {
    await repository.search(query: 'laptop');
    final captured = verify(mockApiClient.get(
      any,
      queryParameters: captureAnyNamed('queryParameters'),
    )).captured;
    return captured.single as Map<String, dynamic>;
  }

  group('LablebSDK.setLang', () {
    test('switches the lang sent on the next request at runtime', () async {
      locator.registerSingleton<LablebSdkOptions>(const LablebSdkOptions(
        baseUrl: 'https://api.lableb.com',
        apiKey: 'test-api-key',
        platformName: 'test-project',
        indexName: 'custom-index',
        requestSource: 'mobile',
        lang: 'ar',
      ));

      expect((await searchParams())['lang'], 'ar');

      LablebSDK.setLang('en');
      expect(LablebSDK.lang, 'en');
      final params = await searchParams();
      expect(params['lang'], 'en');
      expect(params['request_source'], 'mobile');

      final options = locator<LablebSdkOptions>();
      expect(options.platformName, 'test-project');
      expect(options.indexName, 'custom-index');
      expect(options.requestSource, 'mobile');

      LablebSDK.setLang(null);
      expect((await searchParams()).containsKey('lang'), isFalse);
    });

    test('is safe to call before the SDK is initialized', () {
      expect(locator.isRegistered<LablebSdkOptions>(), isFalse);

      LablebSDK.setLang('ar');

      expect(LablebSDK.lang, 'ar');
      expect(locator.isRegistered<LablebSdkOptions>(), isFalse);
    });

    test('a lang set before construction is applied, an explicit lang wins', () {
      LablebSDK.setLang('ar');
      LablebSDK(baseUrl: 'https://api.lableb.com', apiKey: 'k');
      expect(locator<LablebSdkOptions>().lang, 'ar');

      LablebSDK(baseUrl: 'https://api.lableb.com', apiKey: 'k', lang: 'en');
      expect(locator<LablebSdkOptions>().lang, 'en');
      expect(LablebSDK.lang, 'en');
    });
  });

  // The constructor resolves the option; the repository tests cover how it
  // maps to the wire (sent when set, omitted when null or empty). No
  // platformName here, so the constructor does not fetch settings.
  group('LablebSDK requestSource default', () {
    test('defaults to mobile when the app passes nothing', () {
      LablebSDK(baseUrl: 'https://api.lableb.com', apiKey: 'k');
      expect(LablebSDK.defaultRequestSource, 'mobile');
      expect(locator<LablebSdkOptions>().requestSource, 'mobile');
    });

    test('an explicit requestSource wins over the default', () {
      LablebSDK(baseUrl: 'https://api.lableb.com', apiKey: 'k', requestSource: 'web');
      expect(locator<LablebSdkOptions>().requestSource, 'web');
    });

    test('an explicit null still gets the default, so forwarding wrappers keep it', () {
      // e.g. `MyLableb({String? source}) => LablebSDK(requestSource: source)`.
      String? forwarded;
      LablebSDK(baseUrl: 'https://api.lableb.com', apiKey: 'k', requestSource: forwarded);
      expect(locator<LablebSdkOptions>().requestSource, 'mobile');
    });

    test('an empty string opts out', () {
      LablebSDK(baseUrl: 'https://api.lableb.com', apiKey: 'k', requestSource: '');
      expect(locator<LablebSdkOptions>().requestSource, '');
    });

    test('survives runtime lang and session changes', () {
      LablebSDK(baseUrl: 'https://api.lableb.com', apiKey: 'k');
      LablebSDK.setLang('ar');
      LablebSDK.setSessionId('sess-1');
      expect(locator<LablebSdkOptions>().requestSource, 'mobile');
    });
  });

  group('LablebSDK.setSessionId', () {
    test('switches the session_id sent on the next request at runtime', () async {
      locator.registerSingleton<LablebSdkOptions>(const LablebSdkOptions(
        baseUrl: 'https://api.lableb.com',
        apiKey: 'test-api-key',
        platformName: 'test-project',
        requestSource: 'mobile',
        sessionId: 'sess-1',
      ));

      expect((await searchParams())['session_id'], 'sess-1');

      LablebSDK.setSessionId('sess-2');
      expect(LablebSDK.sessionId, 'sess-2');
      expect((await searchParams())['session_id'], 'sess-2');

      LablebSDK.setSessionId(null);
      expect((await searchParams()).containsKey('session_id'), isFalse);
    });

    test('setLang and setSessionId do not clobber each other or requestSource', () async {
      locator.registerSingleton<LablebSdkOptions>(const LablebSdkOptions(
        baseUrl: 'https://api.lableb.com',
        apiKey: 'test-api-key',
        platformName: 'test-project',
        requestSource: 'mobile',
      ));

      LablebSDK.setLang('ar');
      LablebSDK.setSessionId('sess-1');
      LablebSDK.setLang('en');

      final params = await searchParams();
      expect(params['lang'], 'en');
      expect(params['session_id'], 'sess-1');
      expect(params['request_source'], 'mobile');
    });

    test('is safe to call before the SDK is initialized', () {
      expect(locator.isRegistered<LablebSdkOptions>(), isFalse);

      LablebSDK.setSessionId('sess-1');

      expect(LablebSDK.sessionId, 'sess-1');
      expect(locator.isRegistered<LablebSdkOptions>(), isFalse);
    });

    test('a sessionId set before construction is applied, an explicit sessionId wins', () {
      LablebSDK.setSessionId('sess-1');
      LablebSDK(baseUrl: 'https://api.lableb.com', apiKey: 'k');
      expect(locator<LablebSdkOptions>().sessionId, 'sess-1');

      LablebSDK(baseUrl: 'https://api.lableb.com', apiKey: 'k', sessionId: 'sess-2');
      expect(locator<LablebSdkOptions>().sessionId, 'sess-2');
      expect(LablebSDK.sessionId, 'sess-2');
    });
  });
}
