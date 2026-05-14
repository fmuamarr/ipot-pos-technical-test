import '../../domain/entities/menu_item.dart';
import 'customization_group_model.dart';

class MenuItemModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int categoryId;
  final String? imageUrl;
  final List<CustomizationGroupModel> customizationGroups;

  const MenuItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.imageUrl,
    required this.customizationGroups,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      categoryId: json['category_id'] as int,
      imageUrl: json['image_url'] as String?,
      customizationGroups: (json['customization_groups'] as List<dynamic>)
          .map(
            (g) => CustomizationGroupModel.fromJson(g as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  MenuItem toEntity() => MenuItem(
    id: id,
    name: name,
    description: description,
    price: price,
    categoryId: categoryId,
    imageUrl: imageUrl,
    customizationGroups: customizationGroups.map((g) => g.toEntity()).toList(),
  );
}
