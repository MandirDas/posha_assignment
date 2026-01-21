import 'package:flutter_riverpod/flutter_riverpod.dart';

// Search Query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected Category
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Selected Area
final selectedAreaProvider = StateProvider<String?>((ref) => null);

// Active Filter Count
final activeFilterCountProvider = Provider<int>((ref) {
  int count = 0;
  if (ref.watch(selectedCategoryProvider) != null) count++;
  if (ref.watch(selectedAreaProvider) != null) count++;
  return count;
});
