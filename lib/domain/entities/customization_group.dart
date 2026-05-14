import 'customization_option.dart';

class CustomizationGroup {
  final int id;
  final String name;
  final bool required;
  final int maxSelections;
  final List<CustomizationOption> options;

  const CustomizationGroup({
    required this.id,
    required this.name,
    required this.required,
    required this.maxSelections,
    required this.options,
  });
}
