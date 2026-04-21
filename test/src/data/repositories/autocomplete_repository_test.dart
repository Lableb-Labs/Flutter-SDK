import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/autocomplete_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/data/responses/matching_response.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late AutocompleteRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClientBase();
    repository = AutocompleteRepositoryImpl(mockApiClient);
  });

  group('AutocompleteRepositoryImpl', () {
    final mockResponseData = {
      'results': [
        {'id': '1', 'title': 'Test Suggesion 1'},
      ],
      'execution_time': 5
    };

    final requestOptions = RequestOptions(path: '/autocomplete');

    test('getSuggestions returns MatchingResponse on success', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      final result = await repository.getSuggestions(query: 'test');

      expect(result, isA<MatchingResponse>());
      expect(result.results.length, 1);
      expect(result.results.first.id, '1');

      verify(mockApiClient.get(
        '/autocomplete',
        queryParameters: {
          'q': 'test',
          'limit': 10,
        },
      )).called(1);
    });

    test('getSuggestions passes all parameters correctly', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: mockResponseData,
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      await repository.getSuggestions(
        handler: 'custom-handler',
        query: 'smart',
        limit: 5,
        filters: {'category': 'electronics'},
        sessionId: 'sess-123',
        userId: 'usr-123',
        userIp: '192.168.1.1',
        userCountry: 'US',
        requestSource: 'mobile',
      );

      verify(mockApiClient.get(
        '/autocomplete/custom-handler',
        queryParameters: {
          'q': 'smart',
          'limit': 5,
          'category': 'electronics',
          'session_id': 'sess-123',
          'user_id': 'usr-123',
          'user_ip': '192.168.1.1',
          'user_country': 'US',
          'request_source': 'mobile',
        },
      )).called(1);
    });

    test('getSuggestions throws exception on API error', () async {
      when(mockApiClient.get(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenThrow(Exception('API Error'));

      expect(
        () => repository.getSuggestions(query: 'test'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
