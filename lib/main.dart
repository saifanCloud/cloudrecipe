import 'package:flutter/material.dart';
import 'package:my_second_app/screens/home_screen.dart';
import 'package:my_second_app/theme/app_theme.dart';
import 'package:my_second_app/services/supabase_service.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart'; // ← tambahkan import splash screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const FoodRecipeApp());
}

class FoodRecipeApp extends StatelessWidget {
  const FoodRecipeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Recipe',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // ← ganti LoginScreen dengan SplashScreen
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}