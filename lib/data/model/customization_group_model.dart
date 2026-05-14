import '../../domain/entities/customization_group.dart';
import 'customization_option_model.dart';

class CustomizationGroupModel {
  final int id;
  final String name;
  final bool required;
  final int maxSelections;
  final List<CustomizationOptionModel> options;

  const CustomizationGroupModel({
    required this.id,
    required this.name,
    required this.required,
    required this.maxSelections,
    required this.options,
  });

  factory CustomizationGroupModel.fromJson(Map<String, dynamic> json) {
    return CustomizationGroupModel(
      id: json['id'] as int,
      name: json['name'] as String,
      required: json['required'] as bool,
      maxSelections: json['max_selections'] as int,
      options: (json['options'] as List<dynamic>)
          .map(
            (o) => CustomizationOptionModel.fromJson(o as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  CustomizationGroup toEntity() => CustomizationGroup(
    id: id,
    name: name,
    required: required,
    maxSelections: maxSelections,
    options: options.map((o) => o.toEntity()).toList(),
  );
}
