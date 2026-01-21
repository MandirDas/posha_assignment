import '../../domain/entities/filter_items.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.thumbUrl,
    required super.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['idCategory'] ?? '',
      name: json['strCategory'] ?? '',
      thumbUrl: json['strCategoryThumb'] ?? '',
      description: json['strCategoryDescription'] ?? '',
    );
  }
}

class AreaModel extends Area {
  const AreaModel({required super.name});

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      name: json['strArea'] ?? '',
    );
  }
}
