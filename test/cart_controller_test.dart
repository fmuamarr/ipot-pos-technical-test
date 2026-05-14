import 'package:flutter_test/flutter_test.dart';
import 'package:ipot_pos/domain/entities/customization_option.dart';
import 'package:ipot_pos/domain/entities/menu_item.dart';
import 'package:ipot_pos/domain/entities/selected_customization.dart';
import 'package:ipot_pos/presentation/cart/controllers/cart_controller.dart';

void main() {
  group('CartController', () {
    late CartController cartController;

    setUp(() {
      cartController = CartController();
    });

    tearDown(() => cartController.clearCart());

    final menuItemA = MenuItem(
      id: 1,
      name: 'Edamame',
      description: 'Steamed soybeans',
      price: 5.99,
      categoryId: 1,
      customizationGroups: [],
    );

    final menuItemB = MenuItem(
      id: 2,
      name: 'Green Tea',
      description: 'Hot green tea',
      price: 3.50,
      categoryId: 3,
      customizationGroups: [],
    );

    final option = CustomizationOption(
      id: 2,
      name: 'Truffle Salt',
      priceModifier: 1.50,
    );

    test('cart starts empty', () {
      expect(cartController.items, isEmpty);
      expect(cartController.totalItemCount, equals(0));
      expect(cartController.subtotal, equals(0.0));
      expect(cartController.isEmpty, isTrue);
    });

    test('addItem adds item to cart', () {
      cartController.addItem(menuItemA);
      expect(cartController.items.length, equals(1));
      expect(cartController.items.first.menuItem.id, equals(1));
      expect(cartController.items.first.quantity, equals(1));
    });

    test('addItem with same item increments quantity', () {
      cartController.addItem(menuItemA);
      cartController.addItem(menuItemA);
      expect(cartController.items.length, equals(1));
      expect(cartController.items.first.quantity, equals(2));
    });

    test('addItem with different items creates separate entries', () {
      cartController.addItem(menuItemA);
      cartController.addItem(menuItemB);
      expect(cartController.items.length, equals(2));
    });

    test('totalItemCount sums quantities across all cart items', () {
      cartController.addItem(menuItemA, quantity: 3);
      cartController.addItem(menuItemB, quantity: 2);
      expect(cartController.totalItemCount, equals(5));
    });

    test('subtotal calculates correctly without customizations', () {
      cartController.addItem(menuItemA, quantity: 2);
      // 5.99 * 2 = 11.98
      expect(cartController.subtotal, closeTo(11.98, 0.001));
    });

    test('subtotal includes customization price modifiers', () {
      final customizations = [
        SelectedCustomization(option: option, quantity: 1),
      ];
      cartController.addItem(
        menuItemA,
        customizations: customizations,
        quantity: 2,
      );
      // (5.99 + 1.50) * 2 = 14.98
      expect(cartController.subtotal, closeTo(14.98, 0.001));
    });

    test('incrementItem increases quantity by 1', () {
      cartController.addItem(menuItemA);
      final id = cartController.items.first.cartItemId;
      cartController.incrementItem(id);
      expect(cartController.items.first.quantity, equals(2));
    });

    test('decrementItem removes item when quantity reaches 0', () {
      cartController.addItem(menuItemA);
      final id = cartController.items.first.cartItemId;
      cartController.decrementItem(id);
      expect(cartController.items, isEmpty);
    });

    test('decrementItem decreases quantity when above 1', () {
      cartController.addItem(menuItemA, quantity: 3);
      final id = cartController.items.first.cartItemId;
      cartController.decrementItem(id);
      expect(cartController.items.first.quantity, equals(2));
    });

    test('removeItem removes specific item from cart', () {
      cartController.addItem(menuItemA);
      cartController.addItem(menuItemB);
      final idA = cartController.items.first.cartItemId;
      cartController.removeItem(idA);
      expect(cartController.items.length, equals(1));
      expect(cartController.items.first.menuItem.id, equals(2));
    });

    test('clearCart empties the cart', () {
      cartController.addItem(menuItemA);
      cartController.addItem(menuItemB);
      cartController.clearCart();
      expect(cartController.isEmpty, isTrue);
    });

    test('items with different customizations are separate entries', () {
      final noCustomization = <SelectedCustomization>[];
      final withCustomization = [
        SelectedCustomization(option: option, quantity: 1),
      ];
      cartController.addItem(menuItemA, customizations: noCustomization);
      cartController.addItem(menuItemA, customizations: withCustomization);
      expect(cartController.items.length, equals(2));
    });

    test('formatPrice formats to 2 decimal places with dollar sign', () {
      expect(cartController.formatPrice(5.99), equals('\$5.99'));
      expect(cartController.formatPrice(100.0), equals('\$100.00'));
      expect(cartController.formatPrice(0.5), equals('\$0.50'));
    });
  });

  group('CartItem.totalPrice', () {
    test('calculates correctly with multiple customizations', () {
      final item = MenuItem(
        id: 1,
        name: 'Ramen',
        description: 'desc',
        price: 14.99,
        categoryId: 2,
        customizationGroups: [],
      );
      final opts = [
        SelectedCustomization(
          option: const CustomizationOption(
            id: 10,
            name: 'Extra Egg',
            priceModifier: 2.0,
          ),
          quantity: 1,
        ),
        SelectedCustomization(
          option: const CustomizationOption(
            id: 12,
            name: 'Corn',
            priceModifier: 1.0,
          ),
          quantity: 1,
        ),
      ];
      final cart = CartController();
      cart.addItem(item, customizations: opts, quantity: 2);
      // (14.99 + 2.0 + 1.0) * 2 = 35.98
      expect(cart.subtotal, closeTo(35.98, 0.001));
    });
  });
}
