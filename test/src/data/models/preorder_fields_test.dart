import 'package:flutter_test/flutter_test.dart';
import 'package:lableb_flutter_sdk/src/data/models/search_model.dart';
import 'package:lableb_flutter_sdk/src/data/models/autocomplete_model.dart';

void main() {
  final campaignJson = {
    'badge_text': 'Pre-order now',
    'show_countdown': true,
    'release_note': 'Ships next month',
    'end_date': '2026-09-01T00:00:00.000Z',
  };

  group('SearchModel pre-order fields', () {
    test('parses documented pre-order fields from a flat product document', () {
      final model = SearchModel.fromJson({
        'id': 'p1',
        'name': 'Product One',
        'can_be_preordered': true,
        'preorder_campaign': campaignJson,
        'effective_preorder_campaign': campaignJson,
        'preorder_stock_behavior': 'OUT_OF_STOCK_ONLY',
        'preorder_slots_available': true,
      });

      expect(model.canBePreordered, isTrue);
      expect(model.preorderStockBehavior, 'OUT_OF_STOCK_ONLY');
      expect(model.preorderSlotsAvailable, isTrue);
      expect(model.preorderCampaign?.badgeText, 'Pre-order now');
      expect(model.preorderCampaign?.showCountdown, isTrue);
      expect(model.preorderCampaign?.releaseNote, 'Ships next month');
      expect(model.preorderCampaign?.endDate, DateTime.parse('2026-09-01T00:00:00.000Z'));
      expect(model.effectivePreorderCampaign?.badgeText, 'Pre-order now');

      final entity = model.toEntity();
      expect(entity.canBePreordered, isTrue);
      expect(entity.preorderCampaign?.badgeText, 'Pre-order now');
      expect(entity.effectivePreorderCampaign?.releaseNote, 'Ships next month');
    });

    test('defaults to false/null when pre-order fields are absent', () {
      final model = SearchModel.fromJson({'id': 'p1', 'name': 'Product One'});

      expect(model.canBePreordered, isFalse);
      expect(model.preorderCampaign, isNull);
      expect(model.effectivePreorderCampaign, isNull);
      expect(model.preorderStockBehavior, isNull);
      expect(model.preorderSlotsAvailable, isFalse);
    });
  });

  group('AutocompleteModel pre-order fields', () {
    test('parses documented pre-order fields from a flat product document', () {
      final model = AutocompleteModel.fromJson({
        'name': 'Product One',
        'can_be_preordered': true,
        'preorder_campaign': campaignJson,
        'preorder_stock_behavior': 'IN_STOCK_ONLY',
        'preorder_slots_available': false,
      });

      expect(model.canBePreordered, isTrue);
      expect(model.preorderStockBehavior, 'IN_STOCK_ONLY');
      expect(model.preorderSlotsAvailable, isFalse);
      expect(model.preorderCampaign?.badgeText, 'Pre-order now');

      final entity = model.toEntity();
      expect(entity.canBePreordered, isTrue);
      expect(entity.preorderCampaign?.showCountdown, isTrue);
    });

    test('defaults to false/null when pre-order fields are absent', () {
      final model = AutocompleteModel.fromJson({'name': 'Product One'});

      expect(model.canBePreordered, isFalse);
      expect(model.preorderCampaign, isNull);
      expect(model.preorderStockBehavior, isNull);
      expect(model.preorderSlotsAvailable, isFalse);
    });
  });
}
