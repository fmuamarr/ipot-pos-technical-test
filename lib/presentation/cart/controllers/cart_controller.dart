import 'package:get/get.dart';

import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/menu_item.dart';
import '../../../domain/entities/selected_customization.dart';

class CartController extends GetxController {
  final RxList<CartItem> items = <CartItem>[].obs;
  final RxString tableId = ''.obs;

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  bool get isEmpty => items.isEmpty;

  /// Adds a menu item with optional customizations to the cart.
  void addItem(
    MenuItem menuItem, {
    List<SelectedCustomization> customizations = const [],
    int quantity = 1,
  }) {
    // Check if an identical entry already exists (same item + same customizations)
    final existingIndex = items.indexWhere(
      (ci) =>
          ci.menuItem.id == menuItem.id &&
          _customizationsMatch(ci.customizations, customizations),
    );

    if (existingIndex >= 0) {
      items[existingIndex].quantity += quantity;
      items.refresh();
    } else {
      items.add(
        CartItem(
          cartItemId: '${menuItem.id}_${DateTime.now().millisecondsSinceEpoch}',
          menuItem: menuItem,
          quantity: quantity,
          customizations: customizations,
        ),
      );
    }
  }

  void incrementItem(String cartItemId) {
    final index = items.indexWhere((ci) => ci.cartItemId == cartItemId);
    if (index >= 0) {
      items[index].quantity++;
      items.refresh();
    }
  }

  void decrementItem(String cartItemId) {
    final index = items.indexWhere((ci) => ci.cartItemId == cartItemId);
    if (index >= 0) {
      if (items[index].quantity <= 1) {
        items.removeAt(index);
      } else {
        items[index].quantity--;
        items.refresh();
      }
    }
  }

  void updateItem(
    String cartItemId,
    List<SelectedCustomization> customizations,
    int quantity,
  ) {
    final index = items.indexWhere((ci) => ci.cartItemId == cartItemId);
    if (index < 0) return;
    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = CartItem(
        cartItemId: items[index].cartItemId,
        menuItem: items[index].menuItem,
        quantity: quantity,
        customizations: customizations,
      );
      items.refresh();
    }
  }

  void removeItem(String cartItemId) {
    items.removeWhere((ci) => ci.cartItemId == cartItemId);
  }

  void clearCart() => items.clear();

  bool _customizationsMatch(
    List<SelectedCustomization> a,
    List<SelectedCustomization> b,
  ) {
    if (a.length != b.length) return false;
    final aIds = a.map((c) => c.option.id).toSet();
    final bIds = b.map((c) => c.option.id).toSet();
    return aIds.containsAll(bIds) && bIds.containsAll(aIds);
  }

  /// Returns a formatted price string.
  String formatPrice(double amount) => '\$${amount.toStringAsFixed(2)}';
}
