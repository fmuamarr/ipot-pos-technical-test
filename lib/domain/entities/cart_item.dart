import 'menu_item.dart';
import 'selected_customization.dart';

class CartItem {
  final String cartItemId;
  final MenuItem menuItem;
  int quantity;
  final List<SelectedCustomization> customizations;

  CartItem({
    required this.cartItemId,
    required this.menuItem,
    required this.quantity,
    required this.customizations,
  });

  double get itemUnitPrice {
    final customizationTotal = customizations.fold<double>(
      0.0,
      (sum, c) => sum + (c.option.priceModifier * c.quantity),
    );
    return menuItem.price + customizationTotal;
  }

  double get totalPrice => itemUnitPrice * quantity;
}
