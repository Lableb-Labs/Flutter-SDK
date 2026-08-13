import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/feedback_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/domain/repositories/feedback_repository.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late FeedbackRepositoryImpl repository;

  setUp(() {
    mockApiClient = MockApiClientBase();
    when(mockApiClient.apiKey).thenReturn('test-api-key');
    repository = FeedbackRepositoryImpl(mockApiClient);
  });

  Response<dynamic> eventResponse({int code = 200}) => Response<dynamic>(
        data: {'time': 6, 'code': code, 'response': null},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/feedback'),
      );

  group('FeedbackRepositoryImpl.submitSearchFeedbackEvent', () {
    test('POSTs to the documented path with query params, defaulting token to the API key', () async {
      when(mockApiClient.post(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitSearchFeedbackEvent(
        project: 'wptest',
        collection: 'posts',
        query: 'product',
        eventType: SearchFeedbackEventType.click,
        itemId: 'item-1',
        itemOrder: 1,
        itemPrice: 95.5,
        sessionId: '1c4Hb23',
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured[0], '/api/v1/wptest/collections/posts/search/default/feedback/events');
      expect(captured[1], {
        'query': 'product',
        'event_type': 'click',
        'item_id': 'item-1',
        'item_order': 1,
        'item_price': 95.5,
        'session_id': '1c4Hb23',
        'token': 'test-api-key',
      });
    });

    test('uses a custom handler when provided', () async {
      when(mockApiClient.post(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitSearchFeedbackEvent(
        project: 'wptest',
        collection: 'posts',
        handler: 'custom',
        query: 'product',
        eventType: SearchFeedbackEventType.purchase,
        itemId: 'item-1',
        itemOrder: 2,
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured[0], '/api/v1/wptest/collections/posts/search/custom/feedback/events');
      expect(captured[1]['event_type'], 'purchase');
    });

    test('throws when the API returns a non-2xx code', () async {
      when(mockApiClient.post(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse(code: 500));

      await expectLater(
        repository.submitSearchFeedbackEvent(
          project: 'wptest',
          collection: 'posts',
          query: 'product',
          eventType: SearchFeedbackEventType.click,
          itemId: 'item-1',
          itemOrder: 1,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('FeedbackRepositoryImpl.submitSearchFeedback (legacy)', () {
    test('delegates to submitSearchFeedbackEvent when project/collection are in metadata', () async {
      when(mockApiClient.post(
        any,
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitSearchFeedback(
        query: 'product',
        resultId: 'item-1',
        feedbackValue: 'clicked',
        metadata: {'project': 'wptest', 'collection': 'posts'},
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured[0], '/api/v1/wptest/collections/posts/search/default/feedback/events');
      expect(captured[1]['item_id'], 'item-1');
      expect(captured[1]['event_type'], 'click');
    });

    test('falls back to POST /feedback/search when metadata has no project/collection', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {'success': true, 'message': 'ok'},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/feedback/search'),
          ));

      await repository.submitSearchFeedback(
        query: 'product',
        resultId: 'item-1',
        feedbackValue: 'clicked',
      );

      verify(mockApiClient.post(
        '/feedback/search',
        data: {
          'feedback_type': 'search',
          'query': 'product',
          'result_id': 'item-1',
          'feedback_value': 'clicked',
        },
      )).called(1);
    });
  });

  group('FeedbackRepositoryImpl.submitAutocompleteFeedback', () {
    test('POSTs to /feedback/autocomplete', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {'success': true, 'message': 'ok'},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/feedback/autocomplete'),
          ));

      await repository.submitAutocompleteFeedback(
        query: 'prod',
        suggestion: 'product',
        feedbackValue: 'clicked',
      );

      verify(mockApiClient.post(
        '/feedback/autocomplete',
        data: {
          'feedback_type': 'autocomplete',
          'query': 'prod',
          'result_id': 'product',
          'feedback_value': 'clicked',
        },
      )).called(1);
    });

    test('throws when the response reports failure', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {'success': false, 'message': 'rejected'},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/feedback/autocomplete'),
          ));

      await expectLater(
        repository.submitAutocompleteFeedback(
          query: 'prod',
          suggestion: 'product',
          feedbackValue: 'clicked',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('FeedbackRepositoryImpl.submitRecommenderFeedback', () {
    test('POSTs to /feedback/recommender', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response<dynamic>(
            data: {'success': true, 'message': 'ok'},
            statusCode: 200,
            requestOptions: RequestOptions(path: '/feedback/recommender'),
          ));

      await repository.submitRecommenderFeedback(
        recommendationId: 'item-2',
        feedbackValue: 'positive',
        userId: 'user-123',
      );

      verify(mockApiClient.post(
        '/feedback/recommender',
        data: {
          'feedback_type': 'recommender',
          'query': '',
          'result_id': 'item-2',
          'feedback_value': 'positive',
          'user_id': 'user-123',
        },
      )).called(1);
    });
  });
}
