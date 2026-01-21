import 'package:dio/dio.dart';
import '../../../core/errors/failures.dart';
import '../../../core/network/api_client.dart';
import '../../models/recipe_model.dart';
import '../../models/filter_models.dart';
import '../../../core/utils/constants.dart';

class MealApiService {
  final ApiClient _apiClient;

  MealApiService(this._apiClient);

  Future<List<RecipeModel>> searchRecipes(String query) async {
    final response = await _apiClient
        .get(AppConstants.searchEndpoint, queryParameters: {'s': query});
    if (response.data['meals'] == null) return [];
    return (response.data['meals'] as List)
        .map((e) => RecipeModel.fromJson(e))
        .toList();
  }

  Future<RecipeModel> getRecipeById(String id) async {
    final response = await _apiClient
        .get(AppConstants.lookupEndpoint, queryParameters: {'i': id});
    if (response.data['meals'] == null ||
        (response.data['meals'] as List).isEmpty) {
      throw const ServerFailure('Recipe not found');
    }
    return RecipeModel.fromJson(response.data['meals'][0]);
  }

  Future<List<RecipeModel>> filterByCategory(String category) async {
    final response = await _apiClient
        .get(AppConstants.filterEndpoint, queryParameters: {'c': category});
    if (response.data['meals'] == null) return [];
    // Note: Filter endpoint returns abbreviated recipe info (id, name, thumb). Detailed info requires lookup,
    // but for list view these are enough.
    return (response.data['meals'] as List)
        .map((e) => RecipeModel.fromJson(e))
        .toList();
  }

  Future<List<RecipeModel>> filterByArea(String area) async {
    final response = await _apiClient
        .get(AppConstants.filterEndpoint, queryParameters: {'a': area});
    if (response.data['meals'] == null) return [];
    return (response.data['meals'] as List)
        .map((e) => RecipeModel.fromJson(e))
        .toList();
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(AppConstants.categoriesEndpoint);
    if (response.data['categories'] == null) return [];
    return (response.data['categories'] as List)
        .map((e) => CategoryModel.fromJson(e))
        .toList();
  }

  Future<List<AreaModel>> getAreas() async {
    final response = await _apiClient
        .get(AppConstants.listEndpoint, queryParameters: {'a': 'list'});
    if (response.data['meals'] == null) return [];
    return (response.data['meals'] as List)
        .map((e) => AreaModel.fromJson(e))
        .toList();
  }
}
