import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/recommender_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/data/responses/matching_response.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late RecommenderRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClientBase();
    repository = RecommenderRepositoryImpl(mockApiClient);
  });

  group('RecommenderRepositoryImpl', () {
    final mockResponseData = {
      'results': [
        {'id': '1', 'title': 'Test Recommendation 1'},
      ],
    };

    final requestOptions = RequestOptions(path: '/recommend');

    test('getRecommendations returns MatchingResponse on success', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      final result = await repository.getRecommendations(itemId: 'item-123');

      expect(result, isA<MatchingResponse>());
      expect(result.results.length, 1);
      expect(result.results.first.id, '1');

      verify(mockApiClient.get(
        '/recommend',
        queryParameters: {
          'limit': 10,
          'id': 'item-123',
        },
      )).called(1);
    });

    test('getRecommendations passes all parameters correctly', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      await repository.getRecommendations(
        handler: 'custom-handler',
        itemId: 'item-123',
        limit: 5,
        filters: {'category': 'electronics'},
        context: {'user_type': 'premium'},
        sessionId: 'sess-123',
        userId: 'usr-123',
        userIp: '192.168.1.1',
        userCountry: 'US',
        requestSource: 'mobile',
      );

      verify(mockApiClient.get(
        '/recommend/custom-handler',
        queryParameters: {
          'id': 'item-123',
          'limit': 5,
          'category': 'electronics',
          'context_user_type': 'premium',
          'session_id': 'sess-123',
          'user_id': 'usr-123',
          'user_ip': '192.168.1.1',
          'user_country': 'US',
          'request_source': 'mobile',
        },
      )).called(1);
    });

    test('getRecommendations throws exception on API error', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(Exception('API Error'));

      expect(
        () => repository.getRecommendations(itemId: 'test'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
