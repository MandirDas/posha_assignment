# 🍊 Posha - The Ultimate Recipe Finder

Posha is a modern, beautifully designed Flutter application that helps users discover, organize, and cook delicious meals from around the world. Built with a focus on **user experience** and **visual engagement**, it goes beyond a simple list of recipes to provide an immersive cooking companion.

---

## ✨ Key Features (The "Wow" Factor)

We went beyond the basics to deliver a premium feel:

### 👨‍🍳 Interactive Cooking Mode
A dedicated, gamified experience for cooking:
- **Preparation Phase**: Ingredients float on screen in a "bubble cloud." Tap them as you gather items to move them to your dock.
- **Step-by-Step Guide**: Large, focused instruction cards with progress tracking.
- **Interactive UI**: Fun animations and "confetti-style" random ingredient layouts make prep less boring.

### 🌊 Parallax Onboarding
A cinematic introduction to the app:
- **Depth Effects**: Background layers move at different speeds as you swipe, creating a 3D parallax effect.
- **Storytelling**: Smoothly transitions between "Discover," "Offline," and "Cook" value propositions.

### 🎨 Modern, Polished UI
- **Glassmorphism**: Translucent, blurred overlays for a sleek, modern look.
- **Hero Animations**: Seamless transitions when opening recipe details.
- **Custom Design System**: Consistent use of the "Posha Orange" brand color, rounded corners, and custom typography.
- **Custom Logo**: A unique vector logo (Chef Hat + Heart) designed specifically for this app.
- **Splash Screen**: Animated entry with scale and fade transitions.

---

## 📱 Core Functionality

- **Smart Search**: Find recipes by name with debounced search for optimized API calls.
- **Robust Filtering**: Filter by **Category** (e.g., Seafood, Vegan) and **Area** (e.g., Italian, Indian).
- **Recipe Details**:
    - **Video Player**: Integrated YouTube player to watch cooking tutorials directly in the app.
    - **Pinch-to-Zoom**: Inspect food images in high detail.
    - **Favorites**: Save recipes locally (SQLite) to access them offline.
- **Offline Capable**: Your favorite recipes are saved to the device database.

---

## 🛠 Tech Stack & Architecture

The project follows **Clean Architecture** principles to ensuring maintainability and testability.

- **Framework**: Flutter (Dart)
- **State Management**: **Riverpod** (AsyncNotifier, Providers)
- **Navigation**: **GoRouter** (Deep linking, Shell routes for bottom nav)
- **Networking**: **Dio** (with Interceptors and Error Handling)
- **Local Storage**: **SQLite** (via `sqflite`) for persisting favorites.
- **UI Libraries**: `flutter_animate`, `shimmer`, `cached_network_image`, `youtube_player_flutter`.

### Directory Structure
```
lib/
├── core/           # Constants, Errors, Themes, Utils
├── data/           # Models, Datasources (Remote/Local), Repositories
├── domain/         # Entities, Usecases, Repository Interfaces
├── presentation/   # Screens, Widgets, Providers
└── main.dart
```

---

## 🚀 Getting Started

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/MandirDas/posha_assignment
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

---

## 🧪 Testing

The project includes unit and widget tests:
- **Unit Tests**: Repository logic, JSON parsing, Usecases.
- **Widget Tests**: Verifying UI components like Recipe Cards and Buttons.

To run tests:
```bash
flutter test
```
