import 'package:flutter/material.dart';

import 'screens/auth/auth_gate.dart';

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
        scaffoldBackgroundColor: const Color(0xFF0B111E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8), // Celeste vibrante para acentos
          secondary: Color(0xFF818CF8),
          surface: Color(0xFF131D31), // Superficie de cards
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF131D31),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFF1E293B), width: 1),
          ),
        ),
      ),
      home: home,
    );
  }
}
