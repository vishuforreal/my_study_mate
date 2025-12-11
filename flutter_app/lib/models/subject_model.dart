class SubjectModel {
  final String id;
  final String name;
  final String category;
  final String subcategory;

  SubjectModel({
    required this.id,
    required this.name,
    required this.category,
    required this.subcategory,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] is String ? json['category'] : json['category']['_id'] ?? '',
      subcategory: json['subcategory'] ?? '',
    );
  }
}