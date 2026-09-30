import 'package:flutter/material.dart';

import 'screens/main_navigation_screen.dart';

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Planner AI',
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
      home: const MainNavigationScreen(),
    );
  }
}
