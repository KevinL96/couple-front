import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CoupleApp());
}

class CoupleApp extends StatelessWidget {
  const CoupleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Us — Couple App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppRouter(),
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    switch (authProvider.status) {
      case AuthStatus.initial:
        return const SplashScreen();
      case AuthStatus.loading:
        return const SplashScreen();
      case AuthStatus.authenticated:
        return const DashboardScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }
}
