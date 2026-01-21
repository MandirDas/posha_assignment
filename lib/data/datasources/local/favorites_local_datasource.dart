import '../../models/recipe_model.dart';
import 'database_helper.dart';

abstract class FavoritesLocalDataSource {
  Future<List<RecipeModel>> getFavorites();
  Future<void> cacheFavorite(RecipeModel recipe);
  Future<void> removeFavorite(String id);
  Future<bool> isFavorite(String id);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final DatabaseHelper _databaseHelper;

  FavoritesLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<List<RecipeModel>> getFavorites() async {
    final result = await _databaseHelper.getFavorites();
    return result.map((e) => RecipeModel.fromMap(e)).toList();
  }

  @override
  Future<void> cacheFavorite(RecipeModel recipe) async {
    await _databaseHelper.insertFavorite(recipe.toMap());
  }

  @override
  Future<void> removeFavorite(String id) async {
    await _databaseHelper.removeFavorite(id);
  }

  @override
  Future<bool> isFavorite(String id) async {
    return await _databaseHelper.isFavorite(id);
  }
}
