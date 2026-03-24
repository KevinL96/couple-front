# 💑 Us — Couple App

A beautiful Flutter app for couples with Firebase authentication and a shared dashboard.

## Features

- 🔐 **Firebase Authentication** — Email/password sign-in, registration, and Google Sign-In
- 🎨 **Smooth Animations** — Floating elements, slide-in transitions, scale presses, and shimmer effects
- 💕 **Couple Dashboard** — 8 action cards: Photos, Date Night, Love Notes, Bucket List, Our Songs, Food Diary, Travel Map, and Milestones
- 🌸 **Beautiful UI** — Pink-purple gradient theme with custom Poppins typography
- 🔄 **Forgot Password** — Password reset via email

## Screens

| Splash | Login | Register | Dashboard |
|--------|-------|----------|-----------|
| Animated heart + loading | Email/password & Google | Full registration form | 8 action cards grid |

## Getting Started

### Prerequisites

- Flutter 3.x SDK
- Firebase project ([Firebase Console](https://console.firebase.google.com/))
- Android Studio / Xcode

### Setup

1. **Clone & install dependencies**
   ```bash
   flutter pub get
   ```

2. **Configure Firebase**
   - Create a project in [Firebase Console](https://console.firebase.google.com/)
   - Enable **Email/Password** and **Google** sign-in providers under *Authentication → Sign-in method*
   - Run `flutterfire configure` to generate `lib/firebase_options.dart` automatically, OR
   - Manually replace the placeholder values in `lib/firebase_options.dart` and `android/app/google-services.json`

3. **Add Poppins fonts**  
   Download from [Google Fonts](https://fonts.google.com/specimen/Poppins) and place in `assets/fonts/`:
   - `Poppins-Regular.ttf`
   - `Poppins-Medium.ttf`
   - `Poppins-SemiBold.ttf`
   - `Poppins-Bold.ttf`

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                  # Entry point & routing
├── firebase_options.dart      # Firebase config (replace with yours)
├── theme/
│   └── app_theme.dart         # Colors, gradients, text styles
├── services/
│   ├── auth_service.dart      # Firebase Auth wrapper
│   └── auth_provider.dart     # ChangeNotifier state management
├── screens/
│   ├── splash_screen.dart     # Animated splash
│   ├── login_screen.dart      # Login / Register / Forgot Password
│   └── dashboard_screen.dart  # Couple dashboard
└── widgets/
    ├── couple_action_card.dart   # Dashboard action cards
    ├── anniversary_banner.dart   # Couple invite banner
    ├── gradient_button.dart      # Animated gradient button
    └── social_sign_in_button.dart # Google sign-in button
```

## Architecture

- **State management**: `provider` package with `ChangeNotifier`
- **Auth flow**: Firebase Auth → `AuthService` → `AuthProvider` → `AppRouter`
- **Animations**: `flutter_animate` package for declarative animations

## License

MIT