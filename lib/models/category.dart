enum CategoryType { expense, income }

class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;
  final int iconCode;
  final int colorValue;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconCode,
    required this.colorValue,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'isDefault': isDefault,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: CategoryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CategoryType.expense,
      ),
      iconCode: json['iconCode'] as int,
      colorValue: json['colorValue'] as int,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
