import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

class ManageFavoritesUseCase {
  final RecipeRepository repository;

  ManageFavoritesUseCase(this.repository);

  Future<Either<Failure, List<Recipe>>> getFavorites() {
    return repository.getFavorites();
  }

  Future<Either<Failure, void>> addFavorite(Recipe recipe) {
    return repository.addFavorite(recipe);
  }

  Future<Either<Failure, void>> removeFavorite(String id) {
    return repository.removeFavorite(id);
  }

  Future<Either<Failure, bool>> isFavorite(String id) {
    return repository.isFavorite(id);
  }
}
