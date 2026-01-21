import 'package:equatable/equatable.dart';

class Recipe extends Equatable {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbUrl;
  final String? youtubeUrl;
  final List<Ingredient> ingredients;

  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbUrl,
    this.youtubeUrl,
    required this.ingredients,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        area,
        instructions,
        thumbUrl,
        youtubeUrl,
        ingredients
      ];
}

class Ingredient extends Equatable {
  final String name;
  final String measure;

  const Ingredient({required this.name, required this.measure});

  @override
  List<Object?> get props => [name, measure];
}
