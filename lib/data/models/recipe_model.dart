import 'dart:convert';
import '../../domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.name,
    required super.category,
    required super.area,
    required super.instructions,
    required super.thumbUrl,
    super.youtubeUrl,
    required super.ingredients,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredients = [];

    for (int i = 1; i <= 20; i++) {
      final ingredientName = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredientName != null &&
          ingredientName.toString().trim().isNotEmpty) {
        ingredients.add(Ingredient(
          name: ingredientName.toString(),
          measure: measure?.toString() ?? '',
        ));
      }
    }

    return RecipeModel(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? 'Unknown',
      area: json['strArea'] ?? 'Unknown',
      instructions: json['strInstructions'] ?? '',
      thumbUrl: json['strMealThumb'] ?? '',
      youtubeUrl: json['strYoutube'],
      ingredients: ingredients,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbUrl,
      'strYoutube': youtubeUrl,
      // Note: Inverting ingredients back to strIngredient1..20 is complex and rarely needed for this app's local storage if we store a JSON blob.
      // But for SQLite I plan to store 'ingredients' as a JSON string column.
    };
  }

  // For SQLite
  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    List<Ingredient> ingredientsList = [];
    if (map['ingredients'] != null) {
      final List<dynamic> decoded = jsonDecode(map['ingredients']);
      ingredientsList = decoded
          .map((e) => Ingredient(name: e['name'], measure: e['measure']))
          .toList();
    }

    return RecipeModel(
      id: map['idStr'],
      name: map['strMeal'],
      category: map['strCategory'],
      area: map['strArea'],
      instructions: map['strInstructions'],
      thumbUrl: map['strMealThumb'],
      youtubeUrl: map['strYoutube'],
      ingredients: ingredientsList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idStr': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbUrl,
      'strYoutube': youtubeUrl,
      'ingredients': jsonEncode(ingredients
          .map((e) => {'name': e.name, 'measure': e.measure})
          .toList()),
    };
  }
}
