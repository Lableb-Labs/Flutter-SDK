import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/recommender_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/di/locator.dart';
import 'package:lableb_flutter_sdk/src/domain/entities/global_settings_entity.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late RecommenderRepositoryImpl repository;

  void setGlobalSettings(GlobalSettings settings) {
    if (locator.isRegistered<GlobalSettings>()) {
      locator.unregister<GlobalSettings>();
    }
    locator.registerSingleton<GlobalSettings>(settings);
  }

  setUp(() {
    mockApiClient = MockApiClientBase();
    repository = RecommenderRepositoryImpl(mockApiClient);
    // hasRecommendation enabled by default; individual tests override.
    setGlobalSettings(const GlobalSettings(hasRecommendation: true));
  });

  tearDown(() {
    if (locator.isRegistered<GlobalSettings>()) {
      locator.unregister<GlobalSettings>();
    }
  });

  final requestOptions = RequestOptions(path: '/recommender');

  group('RecommenderRepositoryImpl.getRecommendations', () {
    test('returns [] and never hits the network when hasRecommendation is false', () async {
      setGlobalSettings(const GlobalSettings(hasRecommendation: false));

      final result = await repository.getRecommendations(itemId: 'item-1');

      expect(result, isEmpty);
      verifyNever(mockApiClient.post(any, data: anyNamed('data')));
    });

    test('POSTs to /recommender and parses recommendations on success', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {
              'recommendations': [
                {'id': 'rec-1', 'data': {'title': 'Recommended Item'}, 'score': 0.9},
              ],
              'execution_time': 12,
            },
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      final result = await repository.getRecommendations(itemId: 'item-123', limit: 5);

      expect(result.length, 1);
      expect(result.first.id, 'rec-1');
      expect(result.first.data['title'], 'Recommended Item');
      expect(result.first.score, 0.9);

      verify(mockApiClient.post(
        '/recommender',
        data: {
          'limit': 5,
          'item_id': 'item-123',
        },
      )).called(1);
    });

    test('sends userId/filters/context when provided', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {'recommendations': []},
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      await repository.getRecommendations(
        userId: 'user-1',
        itemId: 'item-1',
        filters: {'category': 'electronics'},
        context: {'page': 'home'},
      );

      verify(mockApiClient.post(
        '/recommender',
        data: {
          'limit': 10,
          'user_id': 'user-1',
          'item_id': 'item-1',
          'filters': {'category': 'electronics'},
          'context': {'page': 'home'},
        },
      )).called(1);
    });

    test('propagates errors from the API client', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
      )).thenThrow(Exception('API Error'));

      await expectLater(
        repository.getRecommendations(itemId: 'item-1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
