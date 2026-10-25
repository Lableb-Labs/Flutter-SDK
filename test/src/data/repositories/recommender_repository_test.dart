import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/recommender_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/di/locator.dart';
import 'package:lableb_flutter_sdk/src/domain/entities/global_settings_entity.dart';
import 'package:lableb_flutter_sdk/src/exceptions/exceptions.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late RecommenderRepositoryImpl repository;

  const path = '/v2/projects/test-project/indices/index/recommend';

  void setGlobalSettings(GlobalSettings settings) {
    if (locator.isRegistered<GlobalSettings>()) {
      locator.unregister<GlobalSettings>();
    }
    locator.registerSingleton<GlobalSettings>(settings);
  }

  void setSdkOptions({
    String? platformName = 'test-project',
    String indexName = 'index',
    String? requestSource,
    String? lang,
    String? sessionId,
  }) {
    if (locator.isRegistered<LablebSdkOptions>()) {
      locator.unregister<LablebSdkOptions>();
    }
    locator.registerSingleton<LablebSdkOptions>(LablebSdkOptions(
      baseUrl: 'https://api.lableb.com',
      apiKey: 'test-api-key',
      platformName: platformName,
      indexName: indexName,
      requestSource: requestSource,
      lang: lang,
      sessionId: sessionId,
    ));
  }

  setUp(() {
    mockApiClient = MockApiClientBase();
    when(mockApiClient.apiKey).thenReturn('test-api-key');
    repository = RecommenderRepositoryImpl(mockApiClient);
    // hasRecommendation enabled and the out-of-stock filter off by default, so
    // the expected query only holds what each test is about; individual tests
    // override.
    setGlobalSettings(const GlobalSettings(
      hasRecommendation: true,
      showOutofStackProducts: true,
    ));
    setSdkOptions();
  });

  tearDown(() {
    if (locator.isRegistered<GlobalSettings>()) {
      locator.unregister<GlobalSettings>();
    }
    if (locator.isRegistered<LablebSdkOptions>()) {
      locator.unregister<LablebSdkOptions>();
    }
  });

  final requestOptions = RequestOptions(path: path);

  void stubPost(Map<String, dynamic> data) {
    when(mockApiClient.get(
      any,
      queryParameters: anyNamed('queryParameters'),
    )).thenAnswer((_) async => Response<dynamic>(
          data: data,
          statusCode: 200,
          requestOptions: requestOptions,
        ));
  }

  Map<String, dynamic> capturedQuery() {
    final captured = verify(mockApiClient.get(
      any,
      queryParameters: captureAnyNamed('queryParameters'),
    )).captured;
    return captured.single as Map<String, dynamic>;
  }

  group('RecommenderRepositoryImpl.getRecommendations', () {
    test('returns [] and never hits the network when hasRecommendation is false', () async {
      setGlobalSettings(const GlobalSettings(hasRecommendation: false));

      final result = await repository.getRecommendations(itemId: 'item-1');

      expect(result, isEmpty);
      verifyNever(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      ));
    });

    test('GETs the documented recommend route with apikey, id and limit', () async {
      stubPost({'response': {'results': []}});

      await repository.getRecommendations(itemId: 'item-123', limit: 5);

      verify(mockApiClient.get(
        path,
        queryParameters: {
          'id': 'item-123',
          'limit': 5,
          'apikey': 'test-api-key',
        },
      )).called(1);
    });

    test('uses the configured indexName in the path', () async {
      setSdkOptions(indexName: 'products');
      stubPost({'response': {'results': []}});

      await repository.getRecommendations(itemId: 'item-1');

      verify(mockApiClient.get(
        '/v2/projects/test-project/indices/products/recommend',
        queryParameters: anyNamed('queryParameters'),
      )).called(1);
    });

    test('parses the documented response envelope with flat documents', () async {
      stubPost({
        'time': 66,
        'code': 200,
        'response': {
          'found_documents': 20,
          'spelling': null,
          'results': [
            {
              'id': '1',
              'title': 'Million reason to use Lableb cloud search',
              'url': 'http://mysite.com/index/million-reason-to-use-lableb',
              'tags': ['Fast', 'Accurate'],
            },
            {'id': 2, 'title': 'Numeric id'},
          ],
          'facets': {'count': 3},
        },
      });

      final result = await repository.getRecommendations(itemId: '1');

      expect(result.length, 2);
      expect(result.first.id, '1');
      expect(result.first.data['title'], 'Million reason to use Lableb cloud search');
      expect(result.first.data['tags'], ['Fast', 'Accurate']);
      expect(result.first.data.containsKey('id'), isFalse);
      expect(result[1].id, '2');
    });

    test('still parses the legacy recommendations shape', () async {
      stubPost({
        'recommendations': [
          {'id': 'rec-1', 'data': {'title': 'Recommended Item'}, 'score': 0.9},
        ],
        'execution_time': 12,
      });

      final result = await repository.getRecommendations(itemId: 'item-123');

      expect(result.length, 1);
      expect(result.first.id, 'rec-1');
      expect(result.first.data['title'], 'Recommended Item');
      expect(result.first.score, 0.9);
    });

    test('sends user_id, flattened filters and scalar context entries', () async {
      stubPost({'response': {'results': []}});

      await repository.getRecommendations(
        userId: 'user-1',
        itemId: 'item-1',
        filters: {
          'category': 'electronics',
          'price': {'gte': 10, 'lte': 50},
          'filter': '(color:"white" AND size:"xl")',
        },
        context: {
          'user_ip': '192.111.24.21',
          'user_country': 'DE',
          'nested': {'dropped': true},
        },
      );

      expect(capturedQuery(), {
        'user_ip': '192.111.24.21',
        'user_country': 'DE',
        'category': 'electronics',
        'price_from': 10,
        'price_to': 50,
        'filter': '(color:"white" AND size:"xl")',
        'id': 'item-1',
        'limit': 10,
        'user_id': 'user-1',
        'apikey': 'test-api-key',
      });
    });

    test('adds is_available and quantity_from when out-of-stock products are hidden', () async {
      setGlobalSettings(const GlobalSettings(hasRecommendation: true));
      stubPost({'response': {'results': []}});

      await repository.getRecommendations(itemId: 'item-1');

      final query = capturedQuery();
      expect(query['is_available'], true);
      expect(query['quantity_from'], 1);
    });

    test('omits quantity_from when the quantity filter is disabled', () async {
      setGlobalSettings(const GlobalSettings(
        hasRecommendation: true,
        disableQuantityFilter: true,
      ));
      stubPost({'response': {'results': []}});

      await repository.getRecommendations(itemId: 'item-1');

      final query = capturedQuery();
      expect(query['is_available'], true);
      expect(query.containsKey('quantity_from'), isFalse);
    });

    test('sends request_source, lang and session_id when configured', () async {
      setSdkOptions(requestSource: 'mobile', lang: 'ar', sessionId: 'sess-1');
      stubPost({'response': {'results': []}});

      await repository.getRecommendations(itemId: 'item-1');

      final query = capturedQuery();
      expect(query['request_source'], 'mobile');
      expect(query['lang'], 'ar');
      expect(query['session_id'], 'sess-1');
    });

    test('omits request_source, lang and session_id when they are empty', () async {
      setSdkOptions(requestSource: '', lang: '', sessionId: '');
      stubPost({'response': {'results': []}});

      await repository.getRecommendations(itemId: 'item-1');

      expect(capturedQuery(), {
        'id': 'item-1',
        'limit': 10,
        'apikey': 'test-api-key',
      });
    });

    test('throws ValidationException without a network call when platformName is missing', () async {
      setSdkOptions(platformName: null);

      await expectLater(
        repository.getRecommendations(itemId: 'item-1'),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      ));
    });

    test('throws ValidationException without a network call when itemId is missing', () async {
      await expectLater(
        repository.getRecommendations(userId: 'user-1'),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      ));
    });

    test('propagates errors from the API client', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(Exception('API Error'));

      await expectLater(
        repository.getRecommendations(itemId: 'item-1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
