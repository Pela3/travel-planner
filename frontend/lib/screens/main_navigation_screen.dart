import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'mis_viajes/mis_viajes_screen.dart';
import 'planner/planner_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _indiceActual = 0;
  String? _destinoPreseleccionado;
  String? _estiloPreseleccionado;

  @override
  Widget build(BuildContext context) {
    // Lista de pantallas activas
    final List<Widget> pantallas = [
      HomeScreen(
        onSeleccionarDestino: (ciudad, estilo) {
          setState(() {
            _destinoPreseleccionado = ciudad;
            _estiloPreseleccionado = estilo;
            _indiceActual = 1; // Cambia a la pestaña "Planificar" (índice 1)
          });
        },
      ),
      PlannerScreen(
        destinoInicial: _destinoPreseleccionado,
        estiloInicial: _estiloPreseleccionado,
      ),
      const MisViajesScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0B111E),
      body: IndexedStack(
        index: _indiceActual,
        children: pantallas,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: const Color(0xFF38BDF8).withValues(alpha: 0.2),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12);
            }
            return const TextStyle(color: Color(0xFF64748B), fontSize: 12);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF38BDF8));
            }
            return const IconThemeData(color: Color(0xFF64748B));
          }),
        ),
        child: NavigationBar(
          backgroundColor: const Color(0xFF0B111E),
          selectedIndex: _indiceActual,
          onDestinationSelected: (idx) {
            setState(() {
              _indiceActual = idx;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle),
              label: 'Planificar',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: 'Mis Viajes',
            ),
          ],
        ),
      ),
    );
  }
}
