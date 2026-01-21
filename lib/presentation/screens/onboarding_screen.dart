import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _pageOffset = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0;
      });
    });
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) context.go('/recipes');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: -200,
            child: Transform.translate(
              offset: Offset(-_pageOffset * 50, 0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.orange.shade100, Colors.white],
                  ),
                ),
              ),
            ),
          ),

          // Floating shapes
          Positioned(
            top: 100,
            right: -50 - (_pageOffset * 100),
            child: Icon(Icons.circle,
                size: 200, color: Colors.orange.withOpacity(0.1)),
          ),
          Positioned(
            bottom: 150,
            left: -50 - (_pageOffset * 80),
            child: Icon(Icons.circle,
                size: 300, color: Colors.red.withOpacity(0.05)),
          ),

          // Content
          PageView(
            controller: _pageController,
            children: [
              _buildPage(
                  icon: Icons.search,
                  title: "Discover Recipes",
                  desc:
                      "Find thousands of recipes from around the world at your fingertips.",
                  color: Colors.orange),
              _buildPage(
                  icon: Icons.wifi_off,
                  title: "Cook Offline",
                  desc:
                      "Save your favorite recipes and access them anytime, anywhere.",
                  color: Colors.redAccent),
              _buildPage(
                  icon: Icons.restaurant,
                  title: "Become a Chef",
                  desc:
                      "Follow step-by-step instructions and master the art of cooking.",
                  color: Colors.deepOrange,
                  isLast: true),
            ],
          ),

          // Pagination Dots
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  height: 10,
                  width: (index == _pageOffset.round()) ? 20 : 10,
                  decoration: BoxDecoration(
                    color: (index == _pageOffset.round())
                        ? Colors.orange
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPage(
      {required IconData icon,
      required String title,
      required String desc,
      required Color color,
      bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 100, color: color),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Text(
            desc,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (isLast) ...[
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _completeOnboarding,
                child: const Text("Get Started",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )
          ]
        ],
      ),
    );
  }
}
