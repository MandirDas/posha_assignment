import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

class GetRecipeDetailUseCase {
  final RecipeRepository repository;

  GetRecipeDetailUseCase(this.repository);

  Future<Either<Failure, Recipe>> execute(String id) {
    return repository.getRecipeById(id);
  }
}
