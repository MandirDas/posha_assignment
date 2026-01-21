import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recipe.dart';
import 'dependency_injection.dart';

class FavoritesNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    return _fetchFavorites();
  }

  Future<List<Recipe>> _fetchFavorites() async {
    final useCase = ref.read(manageFavoritesUseCaseProvider);
    final result = await useCase.getFavorites();
    return result.fold(
      (failure) => [], // Return empty on error for now
      (data) => data,
    );
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final useCase = ref.read(manageFavoritesUseCaseProvider);
    final isFav = await useCase.isFavorite(recipe.id);

    isFav.fold(
      (failure) => null,
      (isFavorite) async {
        if (isFavorite) {
          await useCase.removeFavorite(recipe.id);
        } else {
          await useCase.addFavorite(recipe);
        }
        // Refresh state
        state = await AsyncValue.guard(() => _fetchFavorites());
      },
    );
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, List<Recipe>>(() {
  return FavoritesNotifier();
});

// Helper provider to check if a specific ID is favorite
final isFavoriteProvider = Provider.family<bool, String>((ref, id) {
  final favoritesState = ref.watch(favoritesProvider);
  return favoritesState.value?.any((r) => r.id == id) ?? false;
});
