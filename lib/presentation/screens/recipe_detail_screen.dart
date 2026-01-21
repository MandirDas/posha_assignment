import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/recipe.dart';
import '../providers/dependency_injection.dart';
import '../providers/favorites_provider.dart';
import 'dart:ui'; // For window info or backdropfilter if needed

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  YoutubePlayerController? _videoController;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _videoController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initVideoController(String? url) {
    if (url != null && _videoController == null) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null) {
        _videoController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
        );
      }
    }
  }

  void _showImageViewer(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white)),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(imageUrl: imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync =
        ref.watch(getRecipeDetailUseCaseProvider).execute(widget.recipeId);

    return Scaffold(
      floatingActionButton: FutureBuilder(
        future: detailAsync,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final recipe = snapshot.data!.fold((l) => null, (r) => r);
            if (recipe != null) {
              return FloatingActionButton.extended(
                onPressed: () => context.push('/cooking_mode', extra: recipe),
                label: const Text("Cooking Mode"),
                icon: const Icon(Icons.restaurant_menu),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              );
            }
          }
          return const SizedBox.shrink();
        },
      ),
      body: FutureBuilder(
        future: detailAsync,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          return snapshot.data!.fold(
            (failure) => Center(child: Text("Error: ${failure.message}")),
            (recipe) {
              _initVideoController(recipe.youtubeUrl);
              final isFavorite = ref.watch(isFavoriteProvider(recipe.id));

              return Stack(
                children: [
                  // 1. Full Screen Image with Hero
                  Positioned.fill(
                    bottom: MediaQuery.of(context).size.height *
                        0.55, // Image takes top ~45%
                    child: GestureDetector(
                      onTap: () => _showImageViewer(context, recipe.thumbUrl),
                      child: Hero(
                        tag: 'recipe_image_${recipe.id}',
                        child: CachedNetworkImage(
                          imageUrl: recipe.thumbUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // 2. Custom Back Button & Actions
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 10,
                    left: 16,
                    right: 16,
                    child:
                        _buildHeaderActions(context, recipe, isFavorite, ref),
                  ),

                  // 3. Draggable/Scrollable Sheet
                  DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    minChildSize: 0.6,
                    maxChildSize: 1.0,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(30)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, -5))
                          ],
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                        child: ListView(
                          controller: scrollController,
                          padding: EdgeInsets.zero,
                          children: [
                            // Drag Handle
                            Center(
                              child: Container(
                                width: 50,
                                height: 5,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),

                            // Title & Badges
                            Text(
                              recipe.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black87,
                                    letterSpacing: -0.5,
                                  ),
                            ),
                            const SizedBox(height: 16),

                            // Quick Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildStatBadge(Icons.public, recipe.area),
                                Container(
                                    width: 1,
                                    height: 20,
                                    color: Colors.grey.shade300),
                                _buildStatBadge(
                                    Icons.category, recipe.category),
                                Container(
                                    width: 1,
                                    height: 20,
                                    color: Colors.grey.shade300),
                                _buildStatBadge(Icons.check_circle_outline,
                                    "${recipe.ingredients.length} Items"),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Ingredients Section
                            Row(
                              children: [
                                const Icon(Icons.shopping_basket_outlined,
                                    color: Colors.orange),
                                const SizedBox(width: 8),
                                Text("Ingredients",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildIngredientsGrid(recipe),

                            const SizedBox(height: 32),

                            // Instructions Section
                            Row(
                              children: [
                                const Icon(Icons.menu_book_outlined,
                                    color: Colors.orange),
                                const SizedBox(width: 8),
                                Text("Instructions",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildInstructionsList(recipe),

                            const SizedBox(height: 32),

                            // Video Section
                            if (_videoController != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.play_circle_outline,
                                      color: Colors.orange),
                                  const SizedBox(width: 8),
                                  Text("Watch Tutorial",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                              fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      )
                                    ]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: YoutubePlayer(
                                    controller: _videoController!,
                                    showVideoProgressIndicator: true,
                                    progressColors: const ProgressBarColors(
                                      playedColor: Colors.orange,
                                      handleColor: Colors.orangeAccent,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 50),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Helper Widgets

  Widget _buildStatBadge(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.orange),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildHeaderActions(
      BuildContext context, Recipe recipe, bool isFavorite, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildCircleButton(
          icon: Icons.arrow_back_ios_new, // Modern arrow
          onTap: () => Navigator.pop(context),
        ),
        _buildCircleButton(
          icon: isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite
              ? Colors.red
              : Colors
                  .white, // White when not selected looks cleaner on dark bg
          onTap: () {
            ref.read(favoritesProvider.notifier).toggleFavorite(recipe);
          },
        ),
      ],
    );
  }

  Widget _buildCircleButton(
      {required IconData icon, required VoidCallback onTap, Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12), // Slightly larger tap area
            decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.3), // Darker tint for better contrast
                shape: BoxShape.circle,
                border:
                    Border.all(color: Colors.white.withOpacity(0.2), width: 1)),
            child: Icon(icon, color: color ?? Colors.white, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientsGrid(Recipe recipe) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: recipe.ingredients.map((ingredient) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.orange),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    ingredient.measure,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInstructionsList(Recipe recipe) {
    final steps = recipe.instructions
        .split(RegExp(r'\r\n|\n|\r'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    return ListView.builder(
      physics: const ClampingScrollPhysics(), // Important for nested list
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final isLast = index == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4))
                        ]),
                    alignment: Alignment.center,
                    child: Text("${index + 1}",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.orange.shade100,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: 24.0), // Space between steps
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100)),
                    child: Text(
                      steps[index],
                      style: const TextStyle(
                          fontSize: 15, height: 1.6, color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
