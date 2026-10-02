import 'package:flutter/material.dart';

import 'screens/auth/auth_gate.dart';
import 'theme/app_colors.dart';

class TravelPlannerApp extends StatelessWidget {
  /// Pantalla inicial. Los tests pasan la app directa, sin login.
  final Widget home;

  const TravelPlannerApp({super.key, this.home = const AuthGate()});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Planner',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.fondo,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primario, // Celeste vibrante para acentos
          secondary: Color(0xFF818CF8),
          surface: AppColors.superficie, // Superficie de cards
        ),
        cardTheme: CardThemeData(
          color: AppColors.superficie,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppColors.borde, width: 1),
          ),
        ),
      ),
      home: home,
    );
  }
}
