import '../../domain/entities/customization_option.dart';

class CustomizationOptionModel {
  final int id;
  final String name;
  final double priceModifier;

  const CustomizationOptionModel({
    required this.id,
    required this.name,
    required this.priceModifier,
  });

  factory CustomizationOptionModel.fromJson(Map<String, dynamic> json) {
    return CustomizationOptionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      priceModifier: (json['price_modifier'] as num).toDouble(),
    );
  }

  CustomizationOption toEntity() =>
      CustomizationOption(id: id, name: name, priceModifier: priceModifier);
}
