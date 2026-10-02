import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app.dart';
import 'package:frontend/models/models.dart';
import 'package:frontend/screens/mis_viajes/viaje_detalle_screen.dart';
import 'package:frontend/services/borrador_storage.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/main_navigation_screen.dart';

/// Verificaciones de accesibilidad de Flutter en cada pantalla: botones de al
/// menos 48x48 (Android), todo lo tocable con nombre para el lector de
/// pantalla y texto con contraste mínimo de 4.5:1.
Future<void> cumplePautas(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

// Con la fuente de los tests (letras sólidas) el contraste se mide bien; los
// desbordes en pantallas chicas se prueban en desbordes_test.dart.
Future<void> abrirApp(WidgetTester tester) async {
  await tester.pumpWidget(const TravelPlannerApp(home: MainNavigationScreen()));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Inicio', (tester) async {
    final semantics = tester.ensureSemantics();
    await abrirApp(tester);
    await cumplePautas(tester);
    semantics.dispose();
  });

  testWidgets('Planificador: los tres pasos', (tester) async {
    final semantics = tester.ensureSemantics();
    await abrirApp(tester);
    await tester.tap(find.text('Planificar'));
    await tester.pumpAndSettle();
    await cumplePautas(tester);

    await tester.enterText(find.widgetWithText(TextField, 'Ej: Roma, Italia'), 'Roma');
    await tester.enterText(find.widgetWithText(TextField, 'Ciudad de partida (Origen)'), 'Buenos Aires');
    await tester.enterText(find.widgetWithText(TextField, 'Días totales'), '10');
    await tester.ensureVisible(find.text('Siguiente'));
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await cumplePautas(tester); // paso 2 sin elegir (botón desactivado)

    await tester.tap(find.text('Cultura'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await cumplePautas(tester);
    semantics.dispose();
  });

  testWidgets('Mis Viajes vacío', (tester) async {
    final semantics = tester.ensureSemantics();
    await abrirApp(tester);
    await tester.tap(find.text('Mis Viajes'));
    await tester.pumpAndSettle();
    await cumplePautas(tester);
    semantics.dispose();
  });

  testWidgets('Login', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(const TravelPlannerApp(home: LoginScreen()));
    await tester.pumpAndSettle();
    await cumplePautas(tester);
    semantics.dispose();
  });

  testWidgets('Itinerario con una parada en revisión', (tester) async {
    final semantics = tester.ensureSemantics();
    final parada = _viaje().paradas.first;
    final borrador = BorradorViaje(
      origen: 'Buenos Aires',
      destino: 'Roma',
      fechaSalida: DateTime(2030, 11, 1),
      estilo: 'cultural',
      compania: 'pareja',
      diasTotales: 10,
      diasRestantes: 10,
      diasSeleccionados: 2,
      itinerario: const [],
      paradaActual: {
        'ciudad_actual': 'Roma',
        'resumen': parada.resumen,
        'dias_recomendados': 2,
        'presupuesto': parada.presupuesto!.toJson(),
        'clima': parada.clima!.toJson(),
        'traslado': parada.traslado!.toJson(),
        'atracciones': parada.atracciones.map((a) => a.toJson()).toList(),
        'cronograma_dias': parada.cronograma.map((c) => c.toJson()).toList(),
      },
    );
    SharedPreferences.setMockInitialValues({'borrador_viaje': jsonEncode(borrador.toJson())});
    BorradorStorage.usuario = null;
    await abrirApp(tester);
    await tester.tap(find.text('Sí, retomar'));
    await tester.pumpAndSettle();

    expect(find.text('Tu Itinerario'), findsOneWidget);
    await cumplePautas(tester);
    semantics.dispose();
  });

  testWidgets('Mis Viajes con un viaje y su detalle', (tester) async {
    final semantics = tester.ensureSemantics();
    SharedPreferences.setMockInitialValues({
      'mis_viajes': [jsonEncode(_viaje().toJson())],
    });
    await abrirApp(tester);
    await tester.tap(find.text('Mis Viajes'));
    await tester.pumpAndSettle();
    await cumplePautas(tester);

    await tester.pumpWidget(MaterialApp(home: ViajeDetalleScreen(viaje: _viaje())));
    await tester.pumpAndSettle();
    await cumplePautas(tester);
    semantics.dispose();
  });
}

ViajeGuardado _viaje() => ViajeGuardado(
      id: 'v1',
      titulo: 'Buenos Aires ➔ Roma',
      origenInicial: 'Buenos Aires',
      estilo: 'CULTURAL',
      mes: 'Noviembre',
      fechaInicio: DateTime(2030, 11, 1),
      diasTotales: 2,
      costoTotalEstimado: 240,
      fechaCreacion: DateTime(2026, 10, 1),
      paradas: [
        ParadaConfirmada(
          ciudad: 'Roma',
          ciudadOrigen: 'Buenos Aires',
          dias: 2,
          fechaInicio: DateTime(2030, 11, 1),
          resumen: 'La ciudad eterna.',
          traslado: InfoTraslado(medioSugerido: 'Vuelo', duracionEstimada: '13h', consejoLogistica: '', costoEstimado: 900),
          presupuesto: PresupuestoEstimado(moneda: 'USD', alojamientoDia: 80, comidaDia: 30, actividadesDia: 10, totalDiario: 120),
          clima: InfoClima(climaEsperado: 'Templado', temperaturaProm: '16°C', ropaRecomendada: ['Abrigo']),
          atracciones: [AtraccionDetallada(nombre: 'Coliseo', requiereTicket: true, consejoReserva: 'Reservar online')],
          cronograma: [
            ActividadDia(dia: 1, manana: 'Coliseo', tarde: 'Foro Romano', noche: 'Trastevere'),
            ActividadDia(dia: 2, manana: 'Vaticano', tarde: 'Castel Sant Angelo', noche: 'Prati'),
          ],
        ),
      ],
    );
