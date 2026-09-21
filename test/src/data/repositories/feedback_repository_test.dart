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

    test('emits item_quantity, cart_id and request_source when supplied',
        () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitSearchFeedbackEvent(
        query: 'product',
        eventType: SearchFeedbackEventType.addToCart,
        itemId: 'item-1',
        itemOrder: 1,
        itemQuantity: 2,
        cartId: 'CART_98765',
        requestSource: 'mobile',
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured[1], [
        {
          'event_type': 'add_to_cart',
          'query': 'product',
          'item_id': 'item-1',
          'item_order': 1,
          'item_quantity': 2,
          'cart_id': 'CART_98765',
          'request_source': 'mobile',
        }
      ]);
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

  group('FeedbackRepositoryImpl.submitAutocompleteFeedbackEvent', () {
    test('POSTs to the documented v2 autocomplete path, authenticating with '
        'apikey and sending the events as a JSON array body', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitAutocompleteFeedbackEvent(
        query: 'samsu',
        eventType: SearchFeedbackEventType.click,
        itemId: '153-ar',
        itemOrder: 4,
        sessionId: '1c4CqE',
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(
        captured[0],
        '/v2/projects/test-project/indices/index/autocomplete/default'
        '/feedback/events',
      );
      expect(captured[1], isA<List<dynamic>>());
      expect(captured[1], [
        {
          'event_type': 'click',
          'query': 'samsu',
          'item_id': '153-ar',
          'item_order': 4,
          'session_id': '1c4CqE',
        }
      ]);
      expect(captured[2], {'apikey': 'test-api-key'});
    });

    test('uses a custom handler when provided', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitAutocompleteFeedbackEvent(
        handler: 'suggest',
        query: 'samsu',
        eventType: SearchFeedbackEventType.purchase,
        itemId: '153-ar',
        itemOrder: 1,
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(
        captured[0],
        '/v2/projects/test-project/indices/index/autocomplete/suggest'
        '/feedback/events',
      );
      expect((captured[1] as List).first['event_type'], 'purchase');
    });

    test('emits every documented optional field', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitAutocompleteFeedbackEvent(
        query: 'samsu',
        eventType: SearchFeedbackEventType.addToCart,
        itemId: '153-ar',
        itemOrder: 4,
        itemPrice: 45.0,
        itemQuantity: 1,
        cartId: 'CART_98765',
        url: 'https://myproject.com/products/153',
        sessionId: '1c4CqE',
        userId: '2313',
        userIp: '167.114.64.183',
        userCountry: 'DE',
        requestSource: 'web',
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured[1], [
        {
          'event_type': 'add_to_cart',
          'query': 'samsu',
          'item_id': '153-ar',
          'item_order': 4,
          'item_price': 45.0,
          'item_quantity': 1,
          'cart_id': 'CART_98765',
          'url': 'https://myproject.com/products/153',
          'session_id': '1c4CqE',
          'user_id': '2313',
          'user_ip': '167.114.64.183',
          'country': 'DE',
          'request_source': 'web',
        }
      ]);
    });

    test('throws ValidationException when platformName is missing', () async {
      setOptions(platformName: null);
      await expectLater(
        repository.submitAutocompleteFeedbackEvent(
          query: 'samsu',
          eventType: SearchFeedbackEventType.click,
          itemId: '153-ar',
          itemOrder: 4,
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws when the API returns a non-2xx code', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse(code: 500));

      await expectLater(
        repository.submitAutocompleteFeedbackEvent(
          query: 'samsu',
          eventType: SearchFeedbackEventType.click,
          itemId: '153-ar',
          itemOrder: 4,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('FeedbackRepositoryImpl.submitRecommendFeedbackEvent', () {
    test('POSTs to the documented v2 recommend path, authenticating with '
        'apikey and sending the events as a JSON array body', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitRecommendFeedbackEvent(
        sourceId: '153-en',
        targetId: '154-ar',
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(
        captured[0],
        '/v2/projects/test-project/indices/index/recommend/default'
        '/feedback/events',
      );
      expect(captured[1], isA<List<dynamic>>());
      // Exact equality also proves event_type is omitted when not supplied.
      expect(captured[1], [
        {'source_id': '153-en', 'target_id': '154-ar'}
      ]);
      expect(captured[2], {'apikey': 'test-api-key'});
    });

    test('does not send query, item_id or url', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitRecommendFeedbackEvent(
        sourceId: '153-en',
        targetId: '154-ar',
        eventType: SearchFeedbackEventType.click,
        sourceTitle: 'Source',
        sourceUrl: 'https://myproject.com/products/153',
        targetTitle: 'Target',
        targetUrl: 'https://myproject.com/products/154',
        itemOrder: 2,
        itemPrice: 45.0,
        itemQuantity: 1,
        cartId: 'CART_98765',
        sessionId: '1c4Hb23',
        userId: '2313',
        userIp: '167.114.64.183',
        userCountry: 'DE',
        requestSource: 'web',
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      final event = (captured[1] as List).first as Map<String, dynamic>;
      expect(event.keys, isNot(contains('query')));
      expect(event.keys, isNot(contains('item_id')));
      expect(event.keys, isNot(contains('url')));
    });

    test('includes event type, order, prices and source/target details when '
        'supplied', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitRecommendFeedbackEvent(
        sourceId: '153-en',
        targetId: '154-ar',
        eventType: SearchFeedbackEventType.click,
        sourceTitle: 'Source',
        sourceUrl: 'https://myproject.com/products/153',
        targetTitle: 'Target',
        targetUrl: 'https://myproject.com/products/154',
        itemOrder: 2,
        itemPrice: 45.0,
        itemQuantity: 1,
        cartId: 'CART_98765',
        sessionId: '1c4Hb23',
        userId: '2313',
        userIp: '167.114.64.183',
        userCountry: 'DE',
        requestSource: 'web',
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(captured[1], [
        {
          'event_type': 'click',
          'source_id': '153-en',
          'target_id': '154-ar',
          'source_title': 'Source',
          'source_url': 'https://myproject.com/products/153',
          'target_title': 'Target',
          'target_url': 'https://myproject.com/products/154',
          'item_order': 2,
          'item_price': 45.0,
          'item_quantity': 1,
          'cart_id': 'CART_98765',
          'session_id': '1c4Hb23',
          'user_id': '2313',
          'user_ip': '167.114.64.183',
          'country': 'DE',
          'request_source': 'web',
        }
      ]);
    });

    test('uses a custom handler when provided', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse());

      await repository.submitRecommendFeedbackEvent(
        handler: 'suggest',
        sourceId: '153-en',
        targetId: '154-ar',
      );

      final captured = verify(mockApiClient.post(
        captureAny,
        data: captureAnyNamed('data'),
        queryParameters: captureAnyNamed('queryParameters'),
      )).captured;
      expect(
        captured[0],
        '/v2/projects/test-project/indices/index/recommend/suggest'
        '/feedback/events',
      );
    });

    test('throws ValidationException when platformName is missing', () async {
      setOptions(platformName: null);
      await expectLater(
        repository.submitRecommendFeedbackEvent(
          sourceId: '153-en',
          targetId: '154-ar',
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws when the API returns a non-2xx code', () async {
      when(mockApiClient.post(
        any,
        data: anyNamed('data'),
        queryParameters: anyNamed('queryParameters'),
      )).thenAnswer((_) async => eventResponse(code: 500));

      await expectLater(
        repository.submitRecommendFeedbackEvent(
          sourceId: '153-en',
          targetId: '154-ar',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
