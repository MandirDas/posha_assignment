import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../domain/entities/filter_items.dart';
import '../../domain/repositories/recipe_repository.dart';

class GetFilterItemsUseCase {
  final RecipeRepository repository;

  GetFilterItemsUseCase(this.repository);

  Future<Either<Failure, List<Category>>> getCategories() {
    return repository.getCategories();
  }

  Future<Either<Failure, List<Area>>> getAreas() {
    return repository.getAreas();
  }
}
