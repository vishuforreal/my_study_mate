class CategoryModel {
  final String id;
  final String name;
  final String type;
  final List<SubcategoryModel> subcategories;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.subcategories,
    required this.createdAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      subcategories: (json['subcategories'] as List?)
          ?.map((sub) => SubcategoryModel.fromJson(sub))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class SubcategoryModel {
  final String id;
  final String name;
  final DateTime createdAt;

  SubcategoryModel({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}