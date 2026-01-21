import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recipe.dart';
import 'dependency_injection.dart';
import 'filter_provider.dart';

final recipeListProvider =
    FutureProvider.autoDispose<List<Recipe>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  final category = ref.watch(selectedCategoryProvider);
  final area = ref.watch(selectedAreaProvider);

  final getRecipesUseCase = ref.read(getRecipesUseCaseProvider);

  List<Recipe> recipes = [];

  // Strategy:
  // 1. If query exists, search by query.
  // 2. Else if category exists, filter by category.
  // 3. Else if area exists, filter by area.
  // 4. Else, maybe return random or empty? Let's return empty initially or maybe some random standard search.

  // Note: TheMealDB doesn't allow combined filtering easily on server.
  // We will fetch based on the highest priority filter and then filter locally for the others.

  if (query.isNotEmpty) {
    // Priority 1: Search
    final result = await getRecipesUseCase.execute(query);
    result.fold(
      (failure) => throw failure,
      (data) => recipes = data,
    );
  } else if (category != null) {
    // Priority 2: Category
    final result = await getRecipesUseCase.filterByCategory(category);
    result.fold(
      (failure) => throw failure,
      (data) => recipes = data,
    );
  } else if (area != null) {
    // Priority 3: Area
    final result = await getRecipesUseCase.filterByArea(area);
    result.fold(
      (failure) => throw failure,
      (data) => recipes = data,
    );
  } else {
    // Default: Show something? Maybe search for a common letter like 'b' (Burgers, etc) or random.
    // Spec doesn't say what to show initially. Let's show nothing or a prompt.
    // But "Browse" implies seeing something.
    // Let's search for 'a' to fill the list.
    final result = await getRecipesUseCase.execute('a');
    result.fold(
      (failure) => throw failure,
      (data) => recipes = data,
    );
  }

  // Apply local filtering for secondary criteria
  if (recipes.isNotEmpty) {
    if (category != null && query.isNotEmpty) {
      recipes = recipes.where((r) => r.category == category).toList();
    }
    if (area != null) {
      recipes = recipes.where((r) => r.area == area).toList();
    }
  }

  return recipes;
});
