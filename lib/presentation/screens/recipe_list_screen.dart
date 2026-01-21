import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/recipe_provider.dart';
import '../widgets/recipe_card.dart';
import '../widgets/search_filter_widget.dart';

final isGridViewProvider = StateProvider<bool>((ref) => true);
final sortAZProvider =
    StateProvider<bool>((ref) => true); // True A-Z, False Z-A

class RecipeListScreen extends ConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.watch(recipeListProvider);
    final isGrid = ref.watch(isGridViewProvider);
    final isSortAZ = ref.watch(sortAZProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Recipe Finder"),
        actions: [
          IconButton(
            icon: Icon(isSortAZ
                ? Icons.sort_by_alpha
                : Icons.sort_by_alpha_outlined), // Simple toggle icon
            tooltip: isSortAZ ? "Sort Z-A" : "Sort A-Z",
            onPressed: () {
              ref.read(sortAZProvider.notifier).update((state) => !state);
            },
          ),
          IconButton(
            icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
            tooltip: "Toggle View",
            onPressed: () {
              ref.read(isGridViewProvider.notifier).update((state) => !state);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SearchAndFilterWidget(),
          Expanded(
            child: recipesAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return const Center(child: Text("No recipes found."));
                }

                // Sorting
                final sortedRecipes = [...recipes];
                sortedRecipes.sort((a, b) => isSortAZ
                    ? a.name.compareTo(b.name)
                    : b.name.compareTo(a.name));

                return isGrid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: sortedRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = sortedRecipes[index];
                          return RecipeCard(
                            recipe: recipe,
                            onTap: () =>
                                context.go('/recipes/detail/${recipe.id}'),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: sortedRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = sortedRecipes[index];
                          return SizedBox(
                            height: 120, // List view height
                            child: RecipeCard(
                              recipe: recipe,
                              onTap: () =>
                                  context.go('/recipes/detail/${recipe.id}'),
                            ),
                          );
                        },
                      );
              },
              loading: () => _buildLoadingShimmer(isGrid),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(bool isGrid) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: isGrid
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (_, __) => Container(
                height: 120,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }
}
