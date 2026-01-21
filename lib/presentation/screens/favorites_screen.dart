import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/favorites_provider.dart';
import '../widgets/recipe_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: favoritesAsync.when(
        data: (recipes) {
          if (recipes.isEmpty) {
            return const Center(child: Text("No favorites yet."));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return Stack(
                children: [
                  RecipeCard(
                    recipe: recipe,
                    onTap: () => context.go('/favorites/detail/${recipe.id}'),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: IconButton(
                        iconSize: 16,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          ref
                              .read(favoritesProvider.notifier)
                              .toggleFavorite(recipe);
                        },
                      ),
                    ),
                  )
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
