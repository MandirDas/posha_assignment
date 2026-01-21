import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import '../../domain/entities/recipe.dart';

class CookingModeScreen extends StatefulWidget {
  final Recipe recipe;

  const CookingModeScreen({super.key, required this.recipe});

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen>
    with TickerProviderStateMixin {
  // Phase Control
  bool _isPrepPhase = true;

  final List<Ingredient> _remainingIngredients = [];
  final List<Ingredient> _preparedIngredients = [];
  late List<AnimationController> _controllers;

  // Storing position mappings to keep things frame-stable
  final Map<String, Offset> _ingredientPositions = {};

  int _currentStepIndex = 0;
  late List<String> _instructions;

  @override
  void initState() {
    super.initState();
    _remainingIngredients.addAll(widget.recipe.ingredients);

    // Random floaty animation stuff
    _controllers = List.generate(widget.recipe.ingredients.length, (index) {
      return AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 2000 + Random().nextInt(2000)),
      )..repeat(reverse: true);
    });

    _assignGridPositions();

    // TODO: Ideally this should formated in the data layer not here
    _instructions = widget.recipe.instructions
        .split(RegExp(r'\r\n|\n|\r'))
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  void _assignGridPositions() {
    // Basic grid logic to stop ingredients overlapping
    final int count = widget.recipe.ingredients.length;
    final int cols = 3;
    final int rows = (count / cols).ceil();

    final List<int> slots = List.generate(count, (index) => index);
    slots.shuffle();

    final r = Random();

    for (int i = 0; i < count; i++) {
      final slotIndex = slots[i];
      final row = slotIndex ~/ cols;
      final col = slotIndex % cols;

      // Calculate cell bounds
      final cellWidth = 1.0 / cols;
      final cellHeight = 0.7 / max(rows, 1);

      // Add some jitter so it doesn't look too grid-like
      final jitterX = (r.nextDouble() * 0.4 * cellWidth) + (0.1 * cellWidth);
      final jitterY = (r.nextDouble() * 0.4 * cellHeight) + (0.1 * cellHeight);

      final x = (col * cellWidth) + jitterX;
      final y = 0.1 + (row * cellHeight) + jitterY;

      final ingredientName = widget.recipe.ingredients[i].name;
      _ingredientPositions[ingredientName] = Offset(x, y);
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onIngredientTap(Ingredient ingredient) {
    setState(() {
      _remainingIngredients.remove(ingredient);
      _preparedIngredients.add(ingredient);
    });
  }

  void _startCooking() {
    setState(() {
      _isPrepPhase = false;
    });
  }

  void _nextStep() {
    if (_currentStepIndex < _instructions.length - 1) {
      setState(() {
        _currentStepIndex++;
      });
    } else {
      // Done
      _showCompletionDialog();
    }
  }

  void _prevStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
      });
    }
  }

  void _showAllSteps() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            builder: (context, controller) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  itemCount: _instructions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: index == _currentStepIndex
                            ? Colors.orange
                            : Colors.grey.shade200,
                        child: Text("${index + 1}",
                            style: TextStyle(
                                color: index == _currentStepIndex
                                    ? Colors.white
                                    : Colors.black)),
                      ),
                      title: Text(_instructions[index]),
                      onTap: () {
                        setState(() {
                          _currentStepIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            }));
  }

  void _showCompletionDialog() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Bon Appétit!"),
              content: const Text("You have completed all the steps."),
              actions: [
                TextButton(
                    onPressed: () => context.go('/recipes'),
                    child: const Text("Done"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isPrepPhase
          ? Colors.orange.shade50
          : Colors.white, // Theme color fix
      appBar: AppBar(
        title: Text(_isPrepPhase
            ? "Preparation"
            : "Step ${_currentStepIndex + 1}/${_instructions.length}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isPrepPhase)
            TextButton(
                onPressed: _showAllSteps,
                child: const Text("See All",
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)))
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _isPrepPhase ? _buildPrepView() : _buildInstructionView(),
      ),
    );
  }

  Widget _buildPrepView() {
    return Column(
      children: [
        // Prepared Dock (Top) - Using Wrap for Grid/Column like flow
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 200), // Limit height
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            border: Border(
                bottom: BorderSide(color: Colors.orange.withOpacity(0.2))),
          ),
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _preparedIngredients
                  .map((e) => Chip(
                        avatar: const Icon(Icons.check,
                            size: 16, color: Colors.white),
                        label: Text(e.name),
                        backgroundColor: Colors.orange, // Theme color fix
                        labelStyle:
                            const TextStyle(color: Colors.white, fontSize: 12),
                        padding: const EdgeInsets.all(4),
                      ))
                  .toList(),
            ),
          ),
        ),

        // Floating Ingredients Area
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Start Cooking Button (Background layer to avoid obscuring completely if ingredients float over)
                  if (_remainingIngredients.isEmpty)
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          elevation: 10,
                        ),
                        onPressed: _startCooking,
                        child: const Text("Start Cooking",
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),

                  // Ingredients
                  ..._remainingIngredients.asMap().entries.map((entry) {
                    final index = entry
                        .key; // This is purely for accessing the controller
                    final ingredient = entry.value;
                    final controller =
                        _controllers[index % _controllers.length];

                    // Lookup Stable Position
                    final basePos = _ingredientPositions[ingredient.name] ??
                        const Offset(0.5, 0.5);

                    final leftPos = basePos.dx * constraints.maxWidth;
                    // Ensure y stays within bounds (subtracting approx 80px for height)
                    final topPos = basePos.dy * (constraints.maxHeight - 100);

                    return AnimatedBuilder(
                      animation: controller,
                      builder: (context, child) {
                        return Positioned(
                          left: leftPos,
                          top: topPos +
                              (sin(controller.value * 2 * pi) *
                                  10), // Float up/down
                          child: GestureDetector(
                            onTap: () => _onIngredientTap(ingredient),
                            child: Container(
                              width: 85, // Fixed size bubble
                              height: 85,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.orange.withOpacity(0.3),
                                      width: 1),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.orange.withOpacity(0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5))
                                  ]),
                              alignment: Alignment.center,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Text(
                                  ingredient.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),

                  if (_remainingIngredients.isNotEmpty)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Text(
                          "Tap floating ingredients to prepare them",
                          style: TextStyle(
                              color: Colors.orange.shade800,
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                    )
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionView() {
    return Column(
      children: [
        // Progress Bar
        LinearProgressIndicator(
          value: (_currentStepIndex + 1) / _instructions.length,
          backgroundColor: Colors.grey.shade200,
          color: Colors.orange,
          minHeight: 6,
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              // Center content
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                          position: Tween<Offset>(
                                  begin: const Offset(0, 0.2), end: Offset.zero)
                              .animate(animation),
                          child: child));
                },
                child: Container(
                  key: ValueKey<int>(_currentStepIndex),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10))
                      ]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "${_currentStepIndex + 1}",
                            style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        _instructions[_currentStepIndex],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 22,
                            height: 1.5,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Controls
        Padding(
          padding: const EdgeInsets.all(30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStepIndex > 0)
                ElevatedButton.icon(
                  onPressed: _prevStep,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Previous"),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey.shade300)),
                )
              else
                const SizedBox(width: 100), // Spacer

              ElevatedButton.icon(
                onPressed: _nextStep,
                icon: const Icon(Icons.arrow_forward),
                label: Text(_currentStepIndex == _instructions.length - 1
                    ? "Finish"
                    : "Next"),
                iconAlignment: IconAlignment.end,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
