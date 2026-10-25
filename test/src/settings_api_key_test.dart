import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lableb_flutter_sdk/lableb_flutter_sdk.dart';
import 'package:lableb_flutter_sdk/src/api/settings_api_client.dart';

/// Records every request and answers with [body].
class _Stub implements HttpClientAdapter {
  _Stub(this.body);

  final Map<String, dynamic> body;
  final List<RequestOptions> requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const _searchBody = {
  'time': 1,
  'code': 200,
  'response': {'found_documents': 0, 'results': []},
};

Map<String, dynamic> _settings(Map<String, dynamic> response) =>
    {'response': response};

void main() {
  late _Stub settingsStub;
  late _Stub apiStub;

  /// Builds the SDK and swaps both transports before the settings fetch
  /// started by the constructor is dispatched.
  LablebSDK build(Map<String, dynamic> settings, {String? apiKey}) {
    final sdk = LablebSDK(
      baseUrl: 'https://api.lableb.com',
      apiKey: apiKey,
      platformName: 'test-project',
    );
    settingsStub = _Stub(_settings(settings));
    apiStub = _Stub(_searchBody);
    locator<SettingsApiClient>().dio.httpClientAdapter = settingsStub;
    sdk.apiClient.dio.httpClientAdapter = apiStub;
    return sdk;
  }

  tearDown(() {
    LablebSDK.setLang(null);
    LablebSDK.setSessionId(null);
  });

  group('SettingsResponse.searchAPIKey', () {
    test('is read, trimmed, and carried to GlobalSettings', () {
      final entity = SettingsResponse.fromJson(_settings({
        'searchAPIKey': ' key-1 ',
        'hasRecommendation': true,
      })).toEntity();
      expect(entity.searchApiKey, 'key-1');
      expect(entity.hasRecommendation, isTrue);
    });

    test('is null when missing or empty', () {
      expect(SettingsResponse.fromJson(_settings({})).searchApiKey, isNull);
      expect(
        SettingsResponse.fromJson(_settings({'searchAPIKey': '  '}))
            .searchApiKey,
        isNull,
      );
    });
  });

  group('LablebSDK API key from settings', () {
    test('without an apiKey, the settings key is used', () async {
      final sdk = build({'searchAPIKey': 'settings-key'});
      await sdkSettingsReady();

      expect(sdk.apiClient.apiKey, 'settings-key');
      expect(locator<LablebSdkOptions>().apiKey, 'settings-key');
      expect(settingsStub.requests.single.path,
          '/v2/projects/test-project/settings');
    });

    test('a request made before settings arrive waits for them', () async {
      final sdk = build({
        'searchAPIKey': 'settings-key',
        'showOutofStackProducts': true,
      });

      // Not awaiting settings first: the request must wait on its own.
      await sdk.searchRequest().forQuery('laptop').withHandler('suggest').send();

      final sent = apiStub.requests.single;
      expect(sent.queryParameters['apikey'], 'settings-key');
      expect(sent.headers['Authorization'], 'Bearer settings-key');
      // Settings were applied too, so no stock filter is added.
      expect(sent.queryParameters.containsKey('is_available'), isFalse);
    });

    test('an apiKey passed by the app wins over the settings key', () async {
      final sdk = build({'searchAPIKey': 'settings-key'}, apiKey: 'app-key');
      await sdk.searchRequest().forQuery('laptop').withHandler('suggest').send();

      expect(sdk.apiClient.apiKey, 'app-key');
      expect(apiStub.requests.single.queryParameters['apikey'], 'app-key');
    });

    test('an empty apiKey is treated like no key', () async {
      final sdk = build({'searchAPIKey': 'settings-key'}, apiKey: '');
      await sdkSettingsReady();
      expect(sdk.apiClient.apiKey, 'settings-key');
    });

    test('settings without a key leave it empty and send no auth header',
        () async {
      final sdk = build({'hasRecommendation': true});
      await sdk.searchRequest().forQuery('laptop').withHandler('suggest').send();

      expect(sdk.apiClient.apiKey, isEmpty);
      expect(apiStub.requests.single.headers.containsKey('Authorization'),
          isFalse);
    });

    test('no platformName and no apiKey still constructs (no fetch)', () {
      final sdk = LablebSDK(baseUrl: 'https://api.lableb.com');
      expect(sdk.apiClient.apiKey, isEmpty);
    });
  });

  group('LablebSDK.init API key from settings', () {
    Future<void> initWith(Map<String, dynamic> settings) async {
      final pending = LablebSDK.init(initialJson: {
        'status': true,
        'token': 't',
        'store_id': '12345',
      });
      // init() sets up the locator synchronously before its first await.
      settingsStub = _Stub(_settings(settings));
      locator<SettingsApiClient>().dio.httpClientAdapter = settingsStub;
      await pending;
    }

    test('without app_key, the settings key enables the SDK', () async {
      await initWith({'searchAPIKey': 'settings-key'});

      expect(LablebSDK.isEnabled, isTrue);
      expect(LablebSDK.instance.apiClient.apiKey, 'settings-key');
      expect(settingsStub.requests.single.path,
          '/v2/projects/zid_12345/settings');
    });

    test('without app_key or a settings key, the SDK stays disabled',
        () async {
      await initWith({});
      expect(LablebSDK.isEnabled, isFalse);
    });
  });

  group('AuthInterceptor', () {
    RequestOptions run(AuthInterceptor interceptor) {
      final options = RequestOptions(path: '/x');
      interceptor.onRequest(options, RequestInterceptorHandler());
      return options;
    }

    test('sends no header for an empty key', () {
      expect(run(AuthInterceptor(apiKey: '')).headers, isEmpty);
    });

    test('apiKeyProvider wins over the constructor key', () {
      final options = run(
        AuthInterceptor(apiKey: 'old', apiKeyProvider: () => 'new'),
      );
      expect(options.headers['Authorization'], 'Bearer new');
    });
  });
}
