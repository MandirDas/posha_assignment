import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posha/domain/entities/recipe.dart';
import 'package:posha/presentation/widgets/recipe_card.dart';
import 'package:mocktail/mocktail.dart';

// Helper to ignore network images in tests
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  setUpAll(() {
    registerFallbackValue(MaterialPageRoute(builder: (_) => Container()));
  });

  const tRecipe = Recipe(
    id: '1',
    name: 'Test Meal',
    category: 'Test Category',
    area: 'Test Area',
    instructions: 'Inst',
    thumbUrl: 'http://example.com/image.jpg',
    ingredients: [],
  );

  testWidgets('RecipeCard displays recipe info', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecipeCard(
            recipe: tRecipe,
            onTap: () {},
          ),
        ),
      ),
    );

    // Verify Title
    expect(find.text('Test Meal'), findsOneWidget);
    // Verify Category Tag
    expect(find.text('Test Category'), findsOneWidget);
    // Verify Area Tag
    expect(find.text('Test Area'), findsOneWidget);
    // Verify Image is present (CachedNetworkImage)
    expect(find.byType(CachedNetworkImage), findsOneWidget);
  });
}
