import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/models/models.dart';
import 'package:frontend/screens/mis_viajes/mis_viajes_screen.dart';
import 'package:frontend/screens/mis_viajes/viaje_detalle_screen.dart';
import 'package:frontend/services/pdf_generator.dart';
import 'package:frontend/services/viajes_storage.dart';

ViajeGuardado _viaje() => ViajeGuardado(
      id: 'v1',
      titulo: 'Buenos Aires ➔ Roma ➔ Florencia',
      origenInicial: 'Buenos Aires',
      estilo: 'CULTURAL',
      mes: 'Noviembre',
      fechaInicio: DateTime(2030, 11, 1),
      diasTotales: 4,
      costoTotalEstimado: 480,
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
          // Viaje viejo: la IA repitió "dia": 1.
          cronograma: [
            ActividadDia(dia: 1, manana: 'Coliseo', tarde: 'Foro Romano', noche: 'Trastevere'),
            ActividadDia(dia: 1, manana: 'Vaticano', tarde: 'Castel Sant Angelo', noche: 'Prati'),
          ],
        ),
        ParadaConfirmada(
          ciudad: 'Florencia',
          ciudadOrigen: 'Roma',
          dias: 2,
          fechaInicio: DateTime(2030, 11, 3),
          resumen: '',
          atracciones: [],
          cronograma: [ActividadDia(dia: 1, manana: 'Duomo', tarde: 'Uffizi', noche: 'Oltrarno')],
        ),
      ],
    );

void main() {
  testWidgets('el detalle muestra las paradas y numera los días por posición', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ViajeDetalleScreen(viaje: _viaje())));
    await tester.pumpAndSettle();

    expect(find.text('Roma'), findsOneWidget);
    expect(find.text('~USD 480'), findsOneWidget);

    // La primera parada arranca desplegada con su cronograma.
    expect(find.text('Coliseo'), findsWidgets);
    expect(find.text('Día 1 • 01/11'), findsOneWidget);
    expect(find.text('Día 2 • 02/11'), findsOneWidget);

    // La segunda está plegada hasta tocarla.
    expect(find.text('Duomo'), findsNothing);
    await tester.scrollUntilVisible(find.text('Florencia'), 300);
    await tester.tap(find.text('Florencia'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Duomo'), 300);
    expect(find.text('Duomo'), findsOneWidget);
  });

  testWidgets('tocar un viaje en Mis Viajes abre el detalle', (tester) async {
    SharedPreferences.setMockInitialValues({
      'mis_viajes': [jsonEncode(_viaje().toJson())],
    });
    await tester.pumpWidget(const MaterialApp(home: MisViajesScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver itinerario completo'));
    await tester.pumpAndSettle();

    expect(find.byType(ViajeDetalleScreen), findsOneWidget);
    expect(find.text('Paradas'), findsOneWidget);
  });

  testWidgets('Mis Viajes muestra un viaje recién guardado sin recargar a mano', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const MaterialApp(home: MisViajesScreen()));
    await tester.pumpAndSettle();
    expect(find.text('No tenés viajes guardados todavía'), findsOneWidget);

    // Lo que hace el planificador al finalizar un viaje.
    await tester.runAsync(() => ViajesStorage.guardar(_viaje()));
    await tester.pumpAndSettle();

    expect(find.text('Ver itinerario completo'), findsOneWidget);
  });

  test('el PDF se genera sin internet con las fuentes incluidas', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // En los tests no hay red: si se intentara bajar fuentes de Google fallaría.
    final bytes = await generarPdfItinerario(_viaje());

    expect(bytes.length, greaterThan(1000));
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
  });
}
