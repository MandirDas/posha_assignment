import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/recipe.dart';
import '../entities/filter_items.dart';

abstract class RecipeRepository {
  Future<Either<Failure, List<Recipe>>> searchRecipes(String query);
  Future<Either<Failure, Recipe>> getRecipeById(String id);
  Future<Either<Failure, List<Recipe>>> filterByCategory(String category);
  Future<Either<Failure, List<Recipe>>> filterByArea(String area);
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, List<Area>>> getAreas();

  // Favorites
  Future<Either<Failure, List<Recipe>>> getFavorites();
  Future<Either<Failure, void>> addFavorite(Recipe recipe);
  Future<Either<Failure, void>> removeFavorite(String id);
  Future<Either<Failure, bool>> isFavorite(String id);
}
