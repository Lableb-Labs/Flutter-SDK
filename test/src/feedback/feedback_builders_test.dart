import 'package:flutter_test/flutter_test.dart';
import 'package:lableb_flutter_sdk/src/domain/repositories/feedback_repository.dart';
import 'package:lableb_flutter_sdk/src/feedback/autocomplete_feedback_builder.dart';
import 'package:lableb_flutter_sdk/src/feedback/recommender_feedback_builder.dart';
import 'package:lableb_flutter_sdk/src/feedback/search_feedback_event_builder.dart';

/// These exercise `build()` only: no locator, no network. They pin the step
/// interfaces so a future change to the fluent API cannot silently drop a
/// field on its way to the repository.
void main() {
  group('SearchFeedbackEventBuilder', () {
    test('carries the commerce and attribution fields through build()', () {
      final payload = SearchFeedbackEventBuilder()
          .forQuery('product')
          .event(SearchFeedbackEventType.addToCart)
          .forItem(id: 'item-1', order: 1, price: 95.5, quantity: 2)
          .withCart('CART_98765')
          .withRequestSource('mobile')
          .build();

      expect(payload.itemQuantity, 2);
      expect(payload.cartId, 'CART_98765');
      expect(payload.requestSource, 'mobile');
      expect(payload.handler, 'default');
    });
  });

  group('AutocompleteFeedbackBuilder', () {
    test('builds the documented payload from the fluent chain', () {
      final payload = AutocompleteFeedbackBuilder()
          .forQuery('samsu')
          .event(SearchFeedbackEventType.click)
          .forItem(id: '153-ar', order: 4)
          .withHandler('suggest')
          .fromUser(id: '2313', sessionId: '1c4CqE')
          .build();

      expect(payload.query, 'samsu');
      expect(payload.eventType, SearchFeedbackEventType.click);
      expect(payload.itemId, '153-ar');
      expect(payload.itemOrder, 4);
      expect(payload.handler, 'suggest');
      expect(payload.userId, '2313');
      expect(payload.sessionId, '1c4CqE');
    });

    test('defaults the handler and leaves optional fields null', () {
      final payload = AutocompleteFeedbackBuilder()
          .forQuery('samsu')
          .event(SearchFeedbackEventType.click)
          .forItem(id: '153-ar', order: 1)
          .build();

      expect(payload.handler, 'default');
      expect(payload.itemPrice, isNull);
      expect(payload.itemQuantity, isNull);
      expect(payload.cartId, isNull);
      expect(payload.url, isNull);
      expect(payload.requestSource, isNull);
    });
  });

  group('RecommenderFeedbackBuilder', () {
    test('builds the documented payload from the fluent chain', () {
      final payload = RecommenderFeedbackBuilder()
          .forRecommendation(sourceId: '153-en', targetId: '154-ar')
          .event(SearchFeedbackEventType.click)
          .atOrder(2)
          .build();

      expect(payload.sourceId, '153-en');
      expect(payload.targetId, '154-ar');
      expect(payload.eventType, SearchFeedbackEventType.click);
      expect(payload.itemOrder, 2);
      expect(payload.handler, 'default');
    });

    test('leaves eventType null when not supplied', () {
      final payload = RecommenderFeedbackBuilder()
          .forRecommendation(sourceId: '153-en', targetId: '154-ar')
          .build();

      expect(payload.eventType, isNull);
      expect(payload.itemOrder, isNull);
    });

    test('carries source and target details', () {
      final payload = RecommenderFeedbackBuilder()
          .forRecommendation(sourceId: '153-en', targetId: '154-ar')
          .withSourceDetails(title: 'Source', url: 'https://example.com/153')
          .withTargetDetails(title: 'Target', url: 'https://example.com/154')
          .withCart('CART_98765')
          .withRequestSource('web')
          .fromUser(id: '2313', ip: '167.114.64.183', country: 'DE')
          .build();

      expect(payload.sourceTitle, 'Source');
      expect(payload.sourceUrl, 'https://example.com/153');
      expect(payload.targetTitle, 'Target');
      expect(payload.targetUrl, 'https://example.com/154');
      expect(payload.cartId, 'CART_98765');
      expect(payload.requestSource, 'web');
      expect(payload.userCountry, 'DE');
    });
  });
}
