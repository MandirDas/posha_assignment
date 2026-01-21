import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/screens/main_wrapper.dart';
import '../../presentation/screens/recipe_list_screen.dart';
import '../../presentation/screens/favorites_screen.dart';
import '../../presentation/screens/recipe_detail_screen.dart';
import '../../presentation/screens/splash_screen.dart';
import '../../presentation/screens/cooking_mode_screen.dart';
import '../../presentation/screens/onboarding_screen.dart';
import '../../domain/entities/recipe.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainWrapper(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recipes',
                builder: (context, state) => const RecipeListScreen(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return RecipeDetailScreen(recipeId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
                routes: [
                  GoRoute(
                    path: 'detail/:id',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return RecipeDetailScreen(recipeId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/cooking_mode',
        builder: (context, state) {
          final recipe = state.extra as Recipe; // Expect Recipe object
          return CookingModeScreen(recipe: recipe);
        },
      ),
    ],
  );
});
