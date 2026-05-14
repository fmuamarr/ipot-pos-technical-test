import 'menu_category.dart';
import 'menu_item.dart';
import 'restaurant.dart';

class MenuResponse {
  final Restaurant restaurant;
  final List<MenuCategory> categories;
  final List<MenuItem> items;

  const MenuResponse({
    required this.restaurant,
    required this.categories,
    required this.items,
  });
}
