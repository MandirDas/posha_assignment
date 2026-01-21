import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

class GetRecipesUseCase {
  final RecipeRepository repository;

  GetRecipesUseCase(this.repository);

  Future<Either<Failure, List<Recipe>>> execute(String query) {
    return repository.searchRecipes(query);
  }

  Future<Either<Failure, List<Recipe>>> filterByCategory(String category) {
    return repository.filterByCategory(category);
  }

  Future<Either<Failure, List<Recipe>>> filterByArea(String area) {
    return repository.filterByArea(area);
  }
}
