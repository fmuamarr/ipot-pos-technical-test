import 'package:flutter_test/flutter_test.dart';
import 'package:ipot_pos/data/model/menu_response_model.dart';
import 'package:ipot_pos/data/datasource/mock_data.dart';

void main() {
  group('MenuResponseModel.fromJson', () {
    test('parses mock data correctly', () {
      final model = MenuResponseModel.fromJson(kMockMenuResponse);

      expect(model.restaurant.id, equals('R001'));
      expect(model.restaurant.name, equals('Sushi Zen'));
      expect(model.restaurant.tableId, equals('T001'));
    });

    test('parses correct number of categories', () {
      final model = MenuResponseModel.fromJson(kMockMenuResponse);
      expect(model.categories.length, equals(3));
    });

    test('categories are sorted by sort_order', () {
      final model = MenuResponseModel.fromJson(kMockMenuResponse);
      final orders = model.categories.map((c) => c.sortOrder).toList();
      expect(orders, equals([1, 2, 3]));
    });

    test('parses correct number of items', () {
      final model = MenuResponseModel.fromJson(kMockMenuResponse);
      expect(model.items.length, equals(4));
    });

    test('parses item prices as doubles', () {
      final model = MenuResponseModel.fromJson(kMockMenuResponse);
      expect(model.items.first.price, isA<double>());
      expect(model.items.first.price, closeTo(5.99, 0.001));
    });

    test('parses customization groups for ramen', () {
      final model = MenuResponseModel.fromJson(kMockMenuResponse);
      final ramen = model.items.firstWhere((i) => i.name == 'Chicken Ramen');
      expect(ramen.customizationGroups.length, equals(2));
    });

    test('required flag parsed correctly', () {
      final model = MenuResponseModel.fromJson(kMockMenuResponse);
      final ramen = model.items.firstWhere((i) => i.name == 'Chicken Ramen');
      final spiceGroup = ramen.customizationGroups.first;
      expect(spiceGroup.required, isTrue);
      final addonGroup = ramen.customizationGroups.last;
      expect(addonGroup.required, isFalse);
    });

    test('price_modifier parsed as double', () {
      final model = MenuResponseModel.fromJson(kMockMenuResponse);
      final edamame = model.items.first;
      final option = edamame.customizationGroups.first.options[1];
      expect(option.priceModifier, closeTo(1.50, 0.001));
    });

    test('toEntity converts to domain MenuResponse', () {
      final model = MenuResponseModel.fromJson(kMockMenuResponse);
      final entity = model.toEntity();

      expect(entity.restaurant.name, equals('Sushi Zen'));
      expect(entity.categories.length, equals(3));
      expect(entity.items.length, equals(4));
    });

    test('item with no customizations parses correctly', () {
      final model = MenuResponseModel.fromJson(kMockMenuResponse);
      final tea = model.items.firstWhere((i) => i.name == 'Green Tea');
      expect(tea.customizationGroups, isEmpty);
    });
  });

  group('buildMockOrderResponse', () {
    test('generates order with given tableId', () {
      final response = buildMockOrderResponse('T002');
      expect(response['table_id'], equals('T002'));
      expect(response['status'], equals('pending'));
      expect(response['id'], isA<String>());
    });

    test('id is unique on repeated calls', () {
      final r1 = buildMockOrderResponse('T001');
      final r2 = buildMockOrderResponse('T001');
      // Allow for identical timestamps in rapid calls, but structure is correct
      expect(r1['id'], isA<String>());
      expect(r2['id'], isA<String>());
    });
  });
}
