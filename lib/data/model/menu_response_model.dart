import '../../domain/entities/menu_category.dart';
import '../../domain/entities/menu_response.dart';
import '../../domain/entities/restaurant.dart';
import 'menu_item_model.dart';

class RestaurantModel {
  final String id;
  final String name;
  final String tableId;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.tableId,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      tableId: json['table_id'] as String,
    );
  }

  Restaurant toEntity() => Restaurant(id: id, name: name, tableId: tableId);
}

class MenuCategoryModel {
  final int id;
  final String name;
  final int sortOrder;

  const MenuCategoryModel({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  factory MenuCategoryModel.fromJson(Map<String, dynamic> json) {
    return MenuCategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int,
    );
  }

  MenuCategory toEntity() =>
      MenuCategory(id: id, name: name, sortOrder: sortOrder);
}

class MenuResponseModel {
  final RestaurantModel restaurant;
  final List<MenuCategoryModel> categories;
  final List<MenuItemModel> items;

  const MenuResponseModel({
    required this.restaurant,
    required this.categories,
    required this.items,
  });

  factory MenuResponseModel.fromJson(Map<String, dynamic> json) {
    return MenuResponseModel(
      restaurant: RestaurantModel.fromJson(
        json['restaurant'] as Map<String, dynamic>,
      ),
      categories: (json['categories'] as List<dynamic>)
          .map((c) => MenuCategoryModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List<dynamic>)
          .map((i) => MenuItemModel.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  MenuResponse toEntity() => MenuResponse(
    restaurant: restaurant.toEntity(),
    categories: categories.map((c) => c.toEntity()).toList(),
    items: items.map((i) => i.toEntity()).toList(),
  );
}
