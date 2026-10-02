import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app.dart';
import 'package:frontend/models/models.dart';
import 'package:frontend/screens/main_navigation_screen.dart';
import 'package:frontend/services/borrador_storage.dart';

BorradorViaje _borrador({Map<String, dynamic>? paradaActual = const {'ciudad_actual': 'Florencia'}}) => BorradorViaje(
      origen: 'Buenos Aires',
      destino: 'Roma',
      fechaSalida: DateTime(2026, 11, 1),
      estilo: 'gastronomico',
      compania: 'amigos',
      diasTotales: 10,
      diasRestantes: 6,
      diasSeleccionados: 3,
      itinerario: [
        ParadaConfirmada(
          ciudad: 'Roma',
          ciudadOrigen: 'Buenos Aires',
          dias: 4,
          fechaInicio: DateTime(2026, 11, 1),
          resumen: 'Llegada a Roma',
          atracciones: const [],
          cronograma: const [],
        ),
      ],
      paradaActual: paradaActual,
    );

Future<void> _conBorradorGuardado(BorradorViaje b) async {
  SharedPreferences.setMockInitialValues({'borrador_viaje': jsonEncode(b.toJson())});
}

void main() {
  setUp(() => BorradorStorage.usuario = null);

  test('el borrador sobrevive a guardarlo y leerlo', () async {
    SharedPreferences.setMockInitialValues({});
    await BorradorStorage.guardar(_borrador());

    final leido = await BorradorStorage.cargar();
    expect(leido!.recorrido, 'Buenos Aires ➔ Roma ➔ Florencia');
    expect(leido.diasPlanificados, 4);
    expect(leido.estilo, 'gastronomico');
    expect(leido.itinerario.single.resumen, 'Llegada a Roma');

    await BorradorStorage.borrar();
    expect(await BorradorStorage.cargar(), isNull);
  });

  test('cada cuenta tiene su propio borrador', () async {
    SharedPreferences.setMockInitialValues({});
    BorradorStorage.usuario = 'ana';
    await BorradorStorage.guardar(_borrador());

    BorradorStorage.usuario = 'beto';
    expect(await BorradorStorage.cargar(), isNull);
  });

  test('un borrador ilegible se descarta sin romper la app', () async {
    SharedPreferences.setMockInitialValues({'borrador_viaje': '{"basura": true}'});
    expect(await BorradorStorage.cargar(), isNull);
    expect(await BorradorStorage.cargar(), isNull);
  });

  testWidgets('al abrir la app ofrece retomar y lleva al itinerario', (tester) async {
    await _conBorradorGuardado(_borrador());
    await tester.pumpWidget(const TravelPlannerApp(home: MainNavigationScreen()));
    await tester.pumpAndSettle();

    expect(find.text('¿Retomar tu viaje?'), findsOneWidget);
    expect(find.textContaining('Buenos Aires ➔ Roma ➔ Florencia'), findsOneWidget);
    expect(find.textContaining('4 de 10 días armados'), findsOneWidget);

    await tester.tap(find.text('Sí, retomar'));
    await tester.pumpAndSettle();

    expect(find.text('Tu Itinerario'), findsOneWidget);
    expect(find.text('Florencia'), findsWidgets);
  });

  testWidgets('si no quiere retomar, borra el borrador y empieza de cero', (tester) async {
    await _conBorradorGuardado(_borrador());
    await tester.pumpWidget(const TravelPlannerApp(home: MainNavigationScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('No, empezar de cero'));
    await tester.pumpAndSettle();

    expect(find.text('¿Retomar tu viaje?'), findsNothing);
    expect(await BorradorStorage.cargar(), isNull);

    await tester.tap(find.text('Planificar'));
    await tester.pumpAndSettle();
    expect(find.text('¿A dónde querés viajar?'), findsOneWidget);
  });

  testWidgets('retomar un borrador guardado entre paradas pide la próxima ciudad', (tester) async {
    await _conBorradorGuardado(_borrador(paradaActual: null));
    await tester.pumpWidget(const TravelPlannerApp(home: MainNavigationScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sí, retomar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Elegí la próxima ciudad'), findsOneWidget);
    expect(find.textContaining('No pudimos armar'), findsNothing);
  });

  testWidgets('si todavía no confirmó ninguna parada lo dice así', (tester) async {
    final b = _borrador();
    await _conBorradorGuardado(BorradorViaje.fromJson({
      ...b.toJson(),
      'dias_restantes': 10,
      'itinerario': [],
    }));
    await tester.pumpWidget(const TravelPlannerApp(home: MainNavigationScreen()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Estabas por confirmar la primera parada'), findsOneWidget);
    expect(find.textContaining('0 de 10'), findsNothing);
  });

  testWidgets('sin borrador no aparece ningún cartel', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const TravelPlannerApp(home: MainNavigationScreen()));
    await tester.pumpAndSettle();

    expect(find.text('¿Retomar tu viaje?'), findsNothing);
  });
}
