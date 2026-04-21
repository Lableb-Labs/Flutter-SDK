import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/feedback_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/data/models/feedback_event_model.dart';
import 'package:lableb_flutter_sdk/src/domain/repositories/feedback_repository.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late FeedbackRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClientBase();
    when(mockApiClient.apiKeySearch).thenReturn('search-key');
    repository = FeedbackRepositoryImpl(mockApiClient);
  });

  group('FeedbackRepositoryImpl', () {
    final requestOptions = RequestOptions(path: '/search/feedback/events');

    test('submitSearchFeedbackEvent sends correct payload', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {},
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      final event = SearchFeedbackEvent(
        query: 'test',
        eventType: FeedbackEventType.click,
        itemId: 'item-1',
        sessionId: 'sess-123',
      );

      await repository.submitSearchFeedbackEvent(event);

      verify(mockApiClient.post(
        '/search/feedback/events',
        data: [event.toJson()],
        queryParameters: {'apikey': 'search-key'},
      )).called(1);
    });

    test('submitAutocompleteFeedbackEvent sends correct payload', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {},
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      final event = AutocompleteFeedbackEvent(
        query: 'test',
        eventType: FeedbackEventType.click,
        itemId: 'item-1',
        sessionId: 'sess-123',
      );

      await repository.submitAutocompleteFeedbackEvent(event, handler: 'custom');

      verify(mockApiClient.post(
        '/autocomplete/custom/feedback/events',
        data: [event.toJson()],
        queryParameters: {'apikey': 'search-key'},
      )).called(1);
    });

    test('submitRecommendFeedbackEvent sends correct payload', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {},
            statusCode: 200,
            requestOptions: requestOptions,
          ));

      final event = RecommendFeedbackEvent(
        eventType: FeedbackEventType.click,
        sourceId: 'item-1',
        targetId: 'item-2',
        sessionId: 'sess-123',
      );

      await repository.submitRecommendFeedbackEvent(event);

      verify(mockApiClient.post(
        '/recommend/feedback/events',
        data: [event.toJson()],
        queryParameters: {'apikey': 'search-key'},
      )).called(1);
    });

    test('submitSearchFeedbackEvent swallows network exceptions', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) => Future.error(Exception('API Error')));

      final event = SearchFeedbackEvent(
        query: 'test',
        eventType: FeedbackEventType.click,
        itemId: 'item-1',
      );

      // Should not throw an exception
      await repository.submitSearchFeedbackEvent(event);
      
      verify(mockApiClient.post(any, data: anyNamed('data'), queryParameters: anyNamed('queryParameters'))).called(1);
    });

    test('submitAutocompleteFeedbackEvent swallows network exceptions', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) => Future.error(Exception('API Error')));

      final event = AutocompleteFeedbackEvent(
        query: 'test',
        eventType: FeedbackEventType.click,
        itemId: 'item-1',
      );

      // Should not throw an exception
      await repository.submitAutocompleteFeedbackEvent(event);
    });

    test('submitRecommendFeedbackEvent swallows network exceptions', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) => Future.error(Exception('API Error')));

      final event = RecommendFeedbackEvent(
        eventType: FeedbackEventType.click,
        sourceId: 'item-1',
        targetId: 'item-2',
      );

      // Should not throw an exception
      await repository.submitRecommendFeedbackEvent(event);
    });
  });
}
