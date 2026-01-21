import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:posha/data/models/recipe_model.dart';
import 'package:posha/domain/entities/recipe.dart';

void main() {
  const tRecipeModel = RecipeModel(
    id: '1',
    name: 'Test Meal',
    category: 'Test Category',
    area: 'Test Area',
    instructions: 'Test Instructions',
    thumbUrl: 'thumb.jpg',
    youtubeUrl: 'youtube.com',
    ingredients: [Ingredient(name: 'Ingredient 1', measure: '1 cup')],
  );

  test('should be a subclass of Recipe entity', () {
    expect(tRecipeModel, isA<Recipe>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      final Map<String, dynamic> jsonMap = {
        'idMeal': '1',
        'strMeal': 'Test Meal',
        'strCategory': 'Test Category',
        'strArea': 'Test Area',
        'strInstructions': 'Test Instructions',
        'strMealThumb': 'thumb.jpg',
        'strYoutube': 'youtube.com',
        'strIngredient1': 'Ingredient 1',
        'strMeasure1': '1 cup',
        'strIngredient2': '',
      };

      final result = RecipeModel.fromJson(jsonMap);
      expect(result, tRecipeModel);
    });
  });

  group('toMap', () {
    test('should return a JSON map containing proper data', () {
      final result = tRecipeModel.toJson();
      final expectedMap = {
        'idMeal': '1',
        'strMeal': 'Test Meal',
        'strCategory': 'Test Category',
        'strArea': 'Test Area',
        'strInstructions': 'Test Instructions',
        'strMealThumb': 'thumb.jpg',
        'strYoutube': 'youtube.com',
      };
      // We are not testing ingredients in toJson because we decided toJson is mainly for API (which we don't Post to)
      // or for simple debugging. But for SQLite we use toMap.
      expect(result, expectedMap);
    });
  });
}
