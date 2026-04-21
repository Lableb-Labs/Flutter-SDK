import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/search_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/data/responses/matching_response.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late SearchRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClientBase();
    repository = SearchRepositoryImpl(mockApiClient);
  });

  group('SearchRepositoryImpl', () {
    final mockResponseData = {
      'total_results': 100,
      'results': [
        {'id': '1', 'title': 'Test Document 1'},
      ],
      'execution_time': 10
    };

    final requestOptions = RequestOptions(path: '/search');

    test('search returns MatchingResponse on success', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      final result = await repository.search(query: 'test');

      expect(result, isA<MatchingResponse>());
      expect(result.totalResults, 100);
      expect(result.results.length, 1);
      expect(result.results.first.id, '1');

      verify(mockApiClient.get(
        '/search',
        queryParameters: {
          'q': 'test',
          'skip': 0,
          'limit': 10,
        },
      )).called(1);
    });

    test('search passes all parameters correctly', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      await repository.search(
        handler: 'custom-handler',
        query: 'smartphone',
        filters: {'category': 'electronics'},
        sort: 'price desc',
        page: 2,
        pageSize: 20,
        sessionId: 'sess-123',
        userId: 'usr-123',
        userIp: '192.168.1.1',
        userCountry: 'US',
        requestSource: 'mobile',
      );

      verify(mockApiClient.get(
        '/search/custom-handler',
        queryParameters: {
          'q': 'smartphone',
          'skip': 20,
          'limit': 20,
          'sort': 'price desc',
          'category': 'electronics',
          'session_id': 'sess-123',
          'user_id': 'usr-123',
          'user_ip': '192.168.1.1',
          'user_country': 'US',
          'request_source': 'mobile',
        },
      )).called(1);
    });

    test('search throws exception on API error', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(Exception('API Error'));

      expect(
        () => repository.search(query: 'test'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
