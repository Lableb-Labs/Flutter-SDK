import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/search_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/di/locator.dart';
import 'package:lableb_flutter_sdk/src/domain/entities/global_settings_entity.dart';
import 'package:lableb_flutter_sdk/src/exceptions/exceptions.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late SearchRepositoryImpl repository;

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
    repository = SearchRepositoryImpl(mockApiClient);
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
        data: {'time': 10, 'code': 200, 'response': body},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/search'),
      );

  group('SearchRepositoryImpl.search', () {
    test('throws ValidationException when platformName is not set', () async {
      setOptions(platformName: null);

      await expectLater(
        repository.search(query: 'test'),
        throwsA(isA<ValidationException>()),
      );
      verifyZeroInteractions(mockApiClient);
    });

    test('builds the documented path with apikey, skip/limit, and out-of-stock filtering', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => lablebResponse({'found_documents': 0, 'results': []}));

      await repository.search(query: 'laptop', page: 2, pageSize: 20);

      final captured = verify(mockApiClient.get(
        captureAny,
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured[0], '/v2/projects/test-project/indices/index/search/default');
      expect(captured[1], {
        'q': 'laptop',
        'skip': 20,
        'limit': 20,
        'apikey': 'test-api-key',
        'is_available': true,
        'quantity_from': 1,
      });
    });

    test('uses a custom handler and indexName, and flattens sort/filters', () async {
      setOptions(platformName: 'test-project', indexName: 'custom-index');
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => lablebResponse({'found_documents': 0, 'results': []}));

      await repository.search(
        query: 'smartphone',
        handler: 'custom-handler',
        sort: {'price': 'desc'},
        filters: {
          'category': 'electronics',
          'price': {'gte': 50, 'lte': 200},
        },
      );

      final captured = verify(mockApiClient.get(
        captureAny,
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured[0], '/v2/projects/test-project/indices/custom-index/search/custom-handler');
      expect(captured[1], {
        'q': 'smartphone',
        'skip': 0,
        'limit': 10,
        'sort': 'price desc',
        'category': 'electronics',
        'price_from': 50,
        'price_to': 200,
        'apikey': 'test-api-key',
        'is_available': true,
        'quantity_from': 1,
      });
    });

    test('does not add is_available/quantity_from when out-of-stock products are enabled', () async {
      setGlobalSettings(const GlobalSettings(showOutofStackProducts: true));
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => lablebResponse({'found_documents': 0, 'results': []}));

      await repository.search(query: 'test');

      final captured = verify(mockApiClient.get(
        any,
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured.single.containsKey('is_available'), isFalse);
      expect(captured.single.containsKey('quantity_from'), isFalse);
    });

    test('unwraps the response envelope and parses flat result documents', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => lablebResponse({
            'found_documents': 61,
            'results': [
              {'id': 'p1_en', 'name': 'Product One', 'price': 63.48},
            ],
          }));

      final result = await repository.search(query: 'a');

      expect(result.totalResults, 61);
      expect(result.results.length, 1);
      expect(result.results.first.id, 'p1_en');
      expect(result.results.first.data['name'], 'Product One');
      expect(result.results.first.data['price'], 63.48);
      expect(result.results.first.data.containsKey('id'), isFalse);
    });

    test('propagates errors from the API client', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(Exception('API Error'));

      await expectLater(
        repository.search(query: 'test'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
