import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:lableb_flutter_sdk/src/data/repositories/feedback_repository_impl.dart';
import 'package:lableb_flutter_sdk/src/di/locator.dart';
import 'package:lableb_flutter_sdk/src/exceptions/exceptions.dart';
import 'package:lableb_flutter_sdk/src/domain/repositories/feedback_repository.dart';

import '../../../helpers/test_helpers.mocks.dart';

void main() {
  late MockApiClientBase mockApiClient;
  late FeedbackRepositoryImpl repository;

  void setOptions({String? platformName = 'test-project', String indexName = 'index'}) {
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

  setUp(() {
    mockApiClient = MockApiClientBase();
    when(mockApiClient.apiKey).thenReturn('test-api-key');
    repository = FeedbackRepositoryImpl(mockApiClient);
    setOptions();
  });

  tearDown(() {
    if (locator.isRegistered<LablebSdkOptions>()) {
      locator.unregister<LablebSdkOptions>();
    }
  });

  Response<dynamic> eventResponse({int code = 200}) => Response<dynamic>(
        data: {'time': 6, 'code': code, 'response': null},
        statusCode: 200,
        requestOptions: RequestOptions(path: '/feedback'),
      );

  group('FeedbackRepositoryImpl.submitSearchFeedbackEvent', () {
    test('POSTs to the documented v2 path, authenticating with apikey and '
        'sending the events as a JSON array body', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitSearchFeedbackEvent(
        query: 'product',
        eventType: SearchFeedbackEventType.click,
        itemId: 'item-1',
        itemOrder: 1,
        itemPrice: 95.5,
        sessionId: '1c4Hb23',
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(
        captured[0],
        '/v2/projects/test-project/indices/index/search/default/feedback/events',
      );
      expect(captured[1], [
        {
          'event_type': 'click',
          'query': 'product',
          'item_id': 'item-1',
          'item_order': 1,
          'item_price': 95.5,
          'session_id': '1c4Hb23',
        }
      ]);
      expect(captured[2], {'apikey': 'test-api-key'});
    });

    test('throws ValidationException when platformName is missing', () async {
      setOptions(platformName: null);
      await expectLater(
        repository.submitSearchFeedbackEvent(
          query: 'product',
          eventType: SearchFeedbackEventType.click,
          itemId: 'item-1',
          itemOrder: 1,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('uses a custom handler when provided', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitSearchFeedbackEvent(
        handler: 'custom',
        query: 'product',
        eventType: SearchFeedbackEventType.purchase,
        itemId: 'item-1',
        itemOrder: 2,
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(
        captured[0],
        '/v2/projects/test-project/indices/index/search/custom/feedback/events',
      );
      expect((captured[1] as List).first['event_type'], 'purchase');
    });

    test('throws when the API returns a non-2xx code', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse(code: 500));

      await expectLater(
        repository.submitSearchFeedbackEvent(
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
    test('always delegates to the documented search feedback event endpoint',
        () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitSearchFeedback(
        query: 'product',
        resultId: 'item-1',
        feedbackValue: 'clicked',
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(
        captured[0],
        '/v2/projects/test-project/indices/index/search/default/feedback/events',
      );
      expect((captured[1] as List).first['item_id'], 'item-1');
      expect((captured[1] as List).first['event_type'], 'click');
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
