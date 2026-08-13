import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/autocomplete_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/di/locator.dart';
import 'package:lableb_flutter_sdk/src/domain/entities/global_settings_entity.dart';
import 'package:lableb_flutter_sdk/src/exceptions/exceptions.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late AutocompleteRepositoryImpl repository;

  void setOptions({String? platformName, String indexName = 'index'}) {
    if (locator.isRegistered<LablebSdkOptions>()) {
      locator.unregister<LablebSdkOptions>();
    }
    locator.registerSingleton<LablebSdkOptions>(LablebSdkOptions(
      baseUrl: 'https://api.lableb.com',
      apiKey: 'test-api-key',
      platformName: platformName,
      indexName: indexName,
    ));
  }

  void setGlobalSettings(GlobalSettings settings) {
    if (locator.isRegistered<GlobalSettings>()) {
      locator.unregister<GlobalSettings>();
    }
    locator.registerSingleton<GlobalSettings>(settings);
  }

  setUp(() {
    mockApiClient = MockApiClientBase();
    when(mockApiClient.apiKey).thenReturn('test-api-key');
    repository = AutocompleteRepositoryImpl(mockApiClient);
    setOptions(platformName: 'test-project');
    setGlobalSettings(const GlobalSettings());
  });

  tearDown(() {
    if (locator.isRegistered<LablebSdkOptions>()) {
      locator.unregister<LablebSdkOptions>();
    }
    if (locator.isRegistered<GlobalSettings>()) {
      locator.unregister<GlobalSettings>();
    }
  });

  Response<dynamic> lablebResponse(Map<String, dynamic> body) => Response<dynamic>(
        data: {'time': 5, 'code': 200, 'response': body},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/autocomplete'),
      );

  group('AutocompleteRepositoryImpl.getSuggestions', () {
    test('throws ValidationException when platformName is not set', () async {
      setOptions(platformName: null);

      await expectLater(
        repository.getSuggestions(query: 'test'),
        throwsA(isA<ValidationException>()),
      );
      verifyZeroInteractions(mockApiClient);
    });

    test('builds the documented path with apikey and out-of-stock filtering', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => lablebResponse({'results': []}));

      await repository.getSuggestions(query: 'boo', limit: 5);

      final captured = verify(mockApiClient.get(
        captureAny,
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured[0], '/v2/projects/test-project/indices/index/autocomplete/default');
      expect(captured[1], {
        'q': 'boo',
        'limit': 5,
        'apikey': 'test-api-key',
        'is_available': true,
        'quantity_from': 1,
      });
    });

    test('uses a custom handler and indexName', () async {
      setOptions(platformName: 'test-project', indexName: 'custom-index');
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => lablebResponse({'results': []}));

      await repository.getSuggestions(query: 'boo', handler: 'suggest');

      final captured = verify(mockApiClient.get(
        captureAny,
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured[0], '/v2/projects/test-project/indices/custom-index/autocomplete/suggest');
    });

    test('does not add is_available/quantity_from when out-of-stock products are enabled', () async {
      setGlobalSettings(const GlobalSettings(showOutofStackProducts: true));
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => lablebResponse({'results': []}));

      await repository.getSuggestions(query: 'boo');

      final captured = verify(mockApiClient.get(
        any,
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured.single.containsKey('is_available'), isFalse);
      expect(captured.single.containsKey('quantity_from'), isFalse);
    });

    test('unwraps the response envelope and falls back to name/metadata for flat items', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => lablebResponse({
            'results': [
              {'id': 'p1_en', 'name': 'Product One', 'price': 63.48},
            ],
          }));

      final result = await repository.getSuggestions(query: 'a');

      expect(result.length, 1);
      expect(result.first.text, 'Product One');
      expect(result.first.metadata?['price'], 63.48);
      expect(result.first.metadata?.containsKey('text'), isFalse);
    });

    test('propagates errors from the API client', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(Exception('API Error'));

      await expectLater(
        repository.getSuggestions(query: 'test'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
