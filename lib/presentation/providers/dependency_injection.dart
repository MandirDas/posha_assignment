import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/local/database_helper.dart';
import '../../data/datasources/local/favorites_local_datasource.dart';
import '../../data/datasources/remote/meal_api_service.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/usecases/get_filter_items_usecase.dart';
import '../../domain/usecases/get_recipe_detail_usecase.dart';
import '../../domain/usecases/get_recipes_usecase.dart';
import '../../domain/usecases/manage_favorites_usecase.dart';

// Core
final dioProvider = Provider<Dio>((ref) => Dio());
final apiClientProvider =
    Provider<ApiClient>((ref) => ApiClient(dio: ref.read(dioProvider)));
final databaseHelperProvider =
    Provider<DatabaseHelper>((ref) => DatabaseHelper());

// Data Sources
final remoteDataSourceProvider = Provider<MealApiService>(
    (ref) => MealApiService(ref.read(apiClientProvider)));
final localDataSourceProvider = Provider<FavoritesLocalDataSource>(
    (ref) => FavoritesLocalDataSourceImpl(ref.read(databaseHelperProvider)));

// Repository
final recipeRepositoryProvider =
    Provider<RecipeRepository>((ref) => RecipeRepositoryImpl(
          remoteDataSource: ref.read(remoteDataSourceProvider),
          localDataSource: ref.read(localDataSourceProvider),
        ));

// UseCases
final getRecipesUseCaseProvider = Provider<GetRecipesUseCase>(
    (ref) => GetRecipesUseCase(ref.read(recipeRepositoryProvider)));
final getRecipeDetailUseCaseProvider = Provider<GetRecipeDetailUseCase>(
    (ref) => GetRecipeDetailUseCase(ref.read(recipeRepositoryProvider)));
final manageFavoritesUseCaseProvider = Provider<ManageFavoritesUseCase>(
    (ref) => ManageFavoritesUseCase(ref.read(recipeRepositoryProvider)));
final getFilterItemsUseCaseProvider = Provider<GetFilterItemsUseCase>(
    (ref) => GetFilterItemsUseCase(ref.read(recipeRepositoryProvider)));
