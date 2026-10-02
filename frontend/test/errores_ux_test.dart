import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app.dart';
import 'package:frontend/data/destinos_populares.dart';
import 'package:frontend/screens/main_navigation_screen.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/screens/planner/widgets/selector_dias_card.dart';
import 'package:frontend/utils/city_images.dart';

/// Scrollea hasta el widget (la pantalla de test es de 800x600) y lo toca.
Future<void> tocar(WidgetTester tester, Finder f) async {
  // Redibujar antes de medir: después de escribir en un campo la pantalla
  // todavía no se actualizó y el toque caía donde estaba el botón antes.
  await tester.pump();
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Inicio', () {
    test('cada categoría tiene al menos 4 destinos', () {
      for (final id in categoriasDestino.keys) {
        final cantidad = destinosPopulares.where((d) => d.categoria == id).length;
        expect(cantidad, greaterThanOrEqualTo(4), reason: 'categoría $id');
      }
    });

    test('las fotos incluidas en la app existen', () {
      for (final d in destinosPopulares.where((d) => d.imagenUrl.startsWith('assets/'))) {
        expect(File(d.imagenUrl).existsSync(), isTrue, reason: d.imagenUrl);
      }
      // El itinerario y Mis Viajes usan la misma foto que el inicio.
      expect(obtenerImagenCiudad('Bariloche'), 'assets/destinos/bariloche.jpg');
    });

    testWidgets('muestra el filtro de todas las categorías', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      for (final cat in categoriasDestino.values) {
        expect(find.text(cat.etiqueta), findsOneWidget);
      }
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
      await tocar(tester, find.text('Gastronomía'));
      await tester.pump();
      await tocar(tester, find.text('Planificar viaje a París'));

      expect(ciudad, 'París');
      expect(estilo, 'gastronomico');
    });
  });

  group('Paso 1 del planificador', () {
    Future<void> irAlPaso1(WidgetTester tester) async {
      await tester.pumpWidget(const TravelPlannerApp(home: MainNavigationScreen()));
      await tester.tap(find.text('Planificar'));
      await tester.pumpAndSettle();
    }

    Future<void> conDias(WidgetTester tester, String dias) async {
      await tester.enterText(find.widgetWithText(TextField, 'Ej: Roma, Italia'), 'Roma');
      await tester.enterText(find.widgetWithText(TextField, 'Ciudad de partida (Origen)'), 'Buenos Aires');
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

    testWidgets('arranca vacío, con ejemplos en gris', (tester) async {
      await irAlPaso1(tester);

      expect(find.text('Ej: Roma, Italia'), findsOneWidget);
      expect(find.text('Ej: Buenos Aires'), findsOneWidget);
      expect(find.text('Ej: 10'), findsOneWidget);
    });

    testWidgets('pide el destino antes de avanzar', (tester) async {
      await irAlPaso1(tester);
      await tocar(tester, find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('Ingresá un destino.'), findsOneWidget);
    });

    testWidgets('pide la ciudad de partida antes de avanzar', (tester) async {
      await irAlPaso1(tester);
      await tester.enterText(find.widgetWithText(TextField, 'Ej: Roma, Italia'), 'Roma');
      await tocar(tester, find.text('Siguiente'));
      await tester.pumpAndSettle();

      expect(find.text('Ingresá tu ciudad de partida.'), findsOneWidget);
    });

    testWidgets('con datos válidos pasa al paso 2', (tester) async {
      await irAlPaso1(tester);
      await conDias(tester, '12');

      expect(find.text('¿Qué tipo de viaje querés?'), findsOneWidget);
    });

    testWidgets('pasos 2 y 3: no hay opción elegida y no deja seguir sin elegir', (tester) async {
      await irAlPaso1(tester);
      await conDias(tester, '12');

      ElevatedButton boton(String texto) =>
          tester.widget<ElevatedButton>(find.ancestor(of: find.text(texto), matching: find.byType(ElevatedButton)));

      expect(find.text('Elegí una opción para seguir'), findsOneWidget);
      expect(boton('Siguiente').onPressed, isNull);
      await tocar(tester, find.text('Cultura'));
      await tester.pumpAndSettle();
      expect(boton('Siguiente').onPressed, isNotNull);

      await tocar(tester, find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsNothing);
      expect(boton('Generar mi viaje').onPressed, isNull);
      await tocar(tester, find.text('Amigos'));
      await tester.pumpAndSettle();
      expect(boton('Generar mi viaje').onPressed, isNotNull);
      expect(find.text('Elegí una opción para seguir'), findsNothing);
    });

    testWidgets('las tarjetas del paso 2 ocupan toda su celda de la grilla', (tester) async {
      await irAlPaso1(tester);
      await conDias(tester, '12');

      // Antes se achicaban al contenido (ícono + texto) y quedaban desparejas.
      final tarjetas = find.ancestor(of: find.text('Cultura'), matching: find.byType(GridView));
      final ancho = tester.getSize(tarjetas).width;
      final tarjeta = tester.getSize(find.ancestor(of: find.text('Cultura'), matching: find.byType(Container)).first);
      expect(tarjeta.width, closeTo((ancho - 12) / 2, 1));
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
