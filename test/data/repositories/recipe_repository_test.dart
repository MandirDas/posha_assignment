import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:posha/core/errors/failures.dart';
import 'package:posha/data/datasources/local/favorites_local_datasource.dart';
import 'package:posha/data/datasources/remote/meal_api_service.dart';
import 'package:posha/data/models/recipe_model.dart';
import 'package:posha/data/repositories/recipe_repository_impl.dart';

class MockRemoteDataSource extends Mock implements MealApiService {}

class MockLocalDataSource extends Mock implements FavoritesLocalDataSource {}

void main() {
  late RecipeRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    repository = RecipeRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const tRecipeModel = RecipeModel(
    id: '1',
    name: 'Test Meal',
    category: 'Test Category',
    area: 'Test Area',
    instructions: 'Inst',
    thumbUrl: 'url',
    ingredients: [],
  );

  final List<RecipeModel> tRecipeList = [tRecipeModel];

  group('searchRecipes', () {
    test('should return list of recipes when remote call is successful',
        () async {
      when(() => mockRemoteDataSource.searchRecipes(any()))
          .thenAnswer((_) async => tRecipeList);

      final result = await repository.searchRecipes('query');

      verify(() => mockRemoteDataSource.searchRecipes('query'));
      expect(result, equals(Right(tRecipeList)));
    });

    test('should return ServerFailure when remote call fails', () async {
      when(() => mockRemoteDataSource.searchRecipes(any()))
          .thenThrow(Exception());

      final result = await repository.searchRecipes('query');

      verify(() => mockRemoteDataSource.searchRecipes('query'));
      expect(result, isA<Left>());
      // Casting to specific failure check
      result.fold((l) => expect(l, isA<ServerFailure>()), (r) => null);
    });
  });

  group('getFavorites', () {
    test('should return list of favorites from local datasource', () async {
      when(() => mockLocalDataSource.getFavorites())
          .thenAnswer((_) async => tRecipeList);

      final result = await repository.getFavorites();

      verify(() => mockLocalDataSource.getFavorites());
      expect(result, equals(Right(tRecipeList)));
    });
  });
}
