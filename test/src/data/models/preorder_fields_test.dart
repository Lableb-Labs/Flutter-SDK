import 'package:flutter_test/flutter_test.dart';
import 'package:lableb_flutter_sdk/src/data/models/search_model.dart';
import 'package:lableb_flutter_sdk/src/data/models/autocomplete_model.dart';

void main() {
  final effectiveCampaignJson = {
    'badge_text': 'Pre-order now',
    'show_countdown': true,
    'release_note': 'Ships next month',
    'end_date': '2026-09-01T00:00:00.000Z',
  };

  final flatCampaignFields = {
    'is_preorder_campaign': true,
    'preorder_campaign_id': 'camp_1',
    'preorder_campaign_name': 'Winter Drop',
    'preorder_campaign_badge_text': 'Pre-order now',
    'preorder_campaign_release_note': 'Ships next month',
    'preorder_campaign_stock_behavior': 'OUT_OF_STOCK_ONLY',
    'preorder_campaign_start_date': '2026-08-01T00:00:00.000Z',
    'preorder_campaign_end_date': '2026-09-01T00:00:00.000Z',
    'preorder_campaign_show_countdown': true,
    'has_options': true,
    'has_fields': true,
    'formatted_sale_price': 'SAR 99.00',
  };

  group('SearchModel pre-order fields', () {
    test('parses flat pre-order campaign fields from a flat product document',
        () {
      final model = SearchModel.fromJson({
        'id': 'p1',
        'name': 'Product One',
        'can_be_preordered': true,
        'effective_preorder_campaign': effectiveCampaignJson,
        'preorder_stock_behavior': 'OUT_OF_STOCK_ONLY',
        'preorder_slots_available': true,
        ...flatCampaignFields,
      });

      expect(model.canBePreordered, isTrue);
      expect(model.preorderStockBehavior, 'OUT_OF_STOCK_ONLY');
      expect(model.preorderSlotsAvailable, isTrue);
      expect(model.effectivePreorderCampaign?.badgeText, 'Pre-order now');

      expect(model.isPreorderCampaign, isTrue);
      expect(model.hasOptions, isTrue);
      expect(model.hasFields, isTrue);
      expect(model.formattedSalePrice, 'SAR 99.00');

      final campaign = model.preorderCampaign;
      expect(campaign?.id, 'camp_1');
      expect(campaign?.name, 'Winter Drop');
      expect(campaign?.badgeText, 'Pre-order now');
      expect(campaign?.releaseNote, 'Ships next month');
      expect(campaign?.stockBehavior, 'OUT_OF_STOCK_ONLY');
      expect(campaign?.startDate, DateTime.parse('2026-08-01T00:00:00.000Z'));
      expect(campaign?.endDate, DateTime.parse('2026-09-01T00:00:00.000Z'));
      expect(campaign?.showCountdown, isTrue);

      final entity = model.toEntity();
      expect(entity.canBePreordered, isTrue);
      expect(entity.isPreorderCampaign, isTrue);
      expect(entity.hasOptions, isTrue);
      expect(entity.hasFields, isTrue);
      expect(entity.formattedSalePrice, 'SAR 99.00');
      expect(entity.preorderCampaign?.id, 'camp_1');
      expect(entity.preorderCampaign?.name, 'Winter Drop');
      expect(entity.effectivePreorderCampaign?.releaseNote, 'Ships next month');
    });

    test('defaults to false/null when pre-order fields are absent', () {
      final model = SearchModel.fromJson({'id': 'p1', 'name': 'Product One'});

      expect(model.canBePreordered, isFalse);
      expect(model.preorderCampaign, isNull);
      expect(model.effectivePreorderCampaign, isNull);
      expect(model.preorderStockBehavior, isNull);
      expect(model.preorderSlotsAvailable, isFalse);
      expect(model.isPreorderCampaign, isFalse);
      expect(model.hasOptions, isFalse);
      expect(model.hasFields, isFalse);
      expect(model.formattedSalePrice, isNull);
    });
  });

  group('AutocompleteModel pre-order fields', () {
    test('parses flat pre-order campaign fields from a flat product document',
        () {
      final model = AutocompleteModel.fromJson({
        'name': 'Product One',
        'can_be_preordered': true,
        'preorder_stock_behavior': 'IN_STOCK_ONLY',
        'preorder_slots_available': false,
        ...flatCampaignFields,
      });

      expect(model.canBePreordered, isTrue);
      expect(model.preorderStockBehavior, 'IN_STOCK_ONLY');
      expect(model.preorderSlotsAvailable, isFalse);
      expect(model.isPreorderCampaign, isTrue);
      expect(model.hasOptions, isTrue);
      expect(model.hasFields, isTrue);
      expect(model.formattedSalePrice, 'SAR 99.00');
      expect(model.preorderCampaign?.id, 'camp_1');
      expect(model.preorderCampaign?.name, 'Winter Drop');
      expect(model.preorderCampaign?.badgeText, 'Pre-order now');

      final entity = model.toEntity();
      expect(entity.canBePreordered, isTrue);
      expect(entity.preorderCampaign?.showCountdown, isTrue);
      expect(entity.isPreorderCampaign, isTrue);
      expect(entity.hasOptions, isTrue);
      expect(entity.hasFields, isTrue);
      expect(entity.formattedSalePrice, 'SAR 99.00');
    });

    test('defaults to false/null when pre-order fields are absent', () {
      final model = AutocompleteModel.fromJson({'name': 'Product One'});

      expect(model.canBePreordered, isFalse);
      expect(model.preorderCampaign, isNull);
      expect(model.preorderStockBehavior, isNull);
      expect(model.preorderSlotsAvailable, isFalse);
      expect(model.isPreorderCampaign, isFalse);
      expect(model.hasOptions, isFalse);
      expect(model.hasFields, isFalse);
      expect(model.formattedSalePrice, isNull);
    });
  });
}
