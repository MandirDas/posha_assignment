import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/filter_provider.dart'; // To access active filter count for badge if needed (optional)
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainWrapper extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapper({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: Icon(FontAwesomeIcons.utensils),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(FontAwesomeIcons
                .solidHeart), // We can add badge here if we want
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
