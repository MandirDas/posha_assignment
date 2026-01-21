import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dependency_injection.dart';
import '../providers/filter_provider.dart';

class SearchAndFilterWidget extends ConsumerStatefulWidget {
  const SearchAndFilterWidget({super.key});

  @override
  ConsumerState<SearchAndFilterWidget> createState() =>
      _SearchAndFilterWidgetState();
}

class _SearchAndFilterWidgetState extends ConsumerState<SearchAndFilterWidget> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync =
        ref.watch(getFilterItemsUseCaseProvider).getCategories();
    final areasAsync = ref.watch(getFilterItemsUseCaseProvider).getAreas();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Category Filter
                FutureBuilder(
                  future: categoriesAsync,
                  builder: (context, snapshot) {
                    // Note: FutureBuilder is used here because getCategories returns Future<Either...>.
                    // Ideally we wrap this in a customized hook or separate provider.
                    // For simplicity in this widget, we can use a FutureBuilder or just ignore until loaded.
                    // Better approach: Have a provider for categories.
                    // But let's keep it simple.
                    if (!snapshot.hasData) return const SizedBox.shrink();

                    return snapshot.data!.fold(
                      (l) => const SizedBox.shrink(),
                      (categories) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text('Category'),
                            value: ref.watch(selectedCategoryProvider),
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text("All Categories")),
                              ...categories.map((c) => DropdownMenuItem(
                                  value: c.name, child: Text(c.name))),
                            ],
                            onChanged: (val) {
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .state = val;
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Area Filter
                FutureBuilder(
                  future: areasAsync,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox.shrink();
                    return snapshot.data!.fold(
                      (l) => const SizedBox.shrink(),
                      (areas) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: const Text('Area'),
                            value: ref.watch(selectedAreaProvider),
                            items: [
                              const DropdownMenuItem(
                                  value: null, child: Text("All Areas")),
                              ...areas.map((a) => DropdownMenuItem(
                                  value: a.name, child: Text(a.name))),
                            ],
                            onChanged: (val) {
                              ref.read(selectedAreaProvider.notifier).state =
                                  val;
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Clear Filters
                if (ref.watch(activeFilterCountProvider) > 0)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                      ref.read(selectedAreaProvider.notifier).state = null;
                      ref.read(searchQueryProvider.notifier).state = '';
                      _searchController.clear();
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text("Clear"),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}
