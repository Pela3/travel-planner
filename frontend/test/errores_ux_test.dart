import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/planner/widgets/selector_dias_card.dart';

/// Scrollea hasta el widget (la pantalla de test es de 800x600) y lo toca.
Future<void> tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Inicio', () {
    testWidgets('no muestra filtros de categorías sin destinos', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      expect(find.text('🏛️ Cultura'), findsOneWidget);
      // No hay destinos de naturaleza: el filtro no aparece (antes quedaba vacío).
      expect(find.text('🌲 Naturaleza'), findsNothing);
    });

    testWidgets('al planificar un destino pasa el estilo de su categoría', (tester) async {
      String? ciudad;
      String? estilo;
      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(onSeleccionarDestino: (c, e) {
          ciudad = c;
          estilo = e;
        }),
      ));

      // París es un destino de gastronomía.
      await tocar(tester, find.text('🍷 Gastronomía'));
      await tester.pump();
      await tocar(tester, find.text('Planificar viaje a París'));

      expect(ciudad, 'París');
      expect(estilo, 'gastronomico');
    });
  });

  group('Paso 1 del planificador', () {
    Future<void> irAlPaso1(WidgetTester tester) async {
      await tester.pumpWidget(const TravelPlannerApp());
      await tester.tap(find.text('Planificar'));
      await tester.pumpAndSettle();
    }

    Future<void> conDias(WidgetTester tester, String dias) async {
      await tester.enterText(find.widgetWithText(TextField, 'Días totales'), dias);
      await tocar(tester, find.text('Siguiente'));
      await tester.pumpAndSettle();
    }

    testWidgets('rechaza 0 días con un mensaje claro', (tester) async {
      await irAlPaso1(tester);
      await conDias(tester, '0');

      expect(find.text('Los días totales tienen que estar entre 1 y 60.'), findsOneWidget);
      expect(find.text('¿Qué tipo de viaje querés?'), findsNothing);
    });

    testWidgets('rechaza más de 60 días', (tester) async {
      await irAlPaso1(tester);
      await conDias(tester, '75');

      expect(find.textContaining('entre 1 y 60'), findsOneWidget);
    });

    testWidgets('pide la ciudad de partida antes de avanzar', (tester) async {
      await irAlPaso1(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Ciudad de partida (Origen)'), '');
      await tocar(tester, find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('Ingresá tu ciudad de partida.'), findsOneWidget);
    });

    testWidgets('con datos válidos pasa al paso 2', (tester) async {
      await irAlPaso1(tester);
      await conDias(tester, '12');

      expect(find.text('¿Qué tipo de viaje querés?'), findsOneWidget);
    });

    testWidgets('el campo de días solo acepta números', (tester) async {
      await irAlPaso1(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Días totales'), '1a5');

      expect(find.text('15'), findsOneWidget);
    });
  });

  testWidgets('la tarjeta de días muestra el costo estimado de la parada', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SelectorDiasCard(
          diasRecomendados: 3,
          diasSeleccionados: 4,
          diasRestantes: 10,
          costoParada: 480,
          onChanged: (_) {},
        ),
      ),
    ));

    expect(find.text('Costo estimado de esta parada: ~USD 480'), findsOneWidget);
  });
}
