import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/models/models.dart';
import 'package:frontend/screens/planner/steps/paso_itinerario.dart';

Widget _envolver({
  Map<String, dynamic>? parada,
  List<ParadaConfirmada> itinerario = const [],
  int diasRestantes = 5,
  String? error,
  ValueChanged<String>? onReintentar,
}) {
  return MaterialApp(
    home: Scaffold(
      body: PasoItinerario(
        paradaActual: parada,
        itinerario: itinerario,
        diasTotales: 10,
        diasRestantes: diasRestantes,
        costoAcumulado: 0,
        diasSeleccionados: 2,
        diaCronogramaSeleccionado: 1,
        fechaInicioParada: DateTime(2026, 11, 1),
        ciudadOrigenTraslado: 'Buenos Aires',
        onDiasSeleccionadosChanged: (_) {},
        onDiaCronogramaChanged: (_) {},
        onConfirmar: (_) {},
        onExportarPdf: () {},
        error: error,
        onReintentar: onReintentar ?? (_) {},
      ),
    ),
  );
}

ParadaConfirmada _parada(String ciudad) => ParadaConfirmada(
      ciudad: ciudad,
      ciudadOrigen: 'Buenos Aires',
      dias: 5,
      fechaInicio: DateTime(2026, 11, 1),
      resumen: '',
      atracciones: [],
      cronograma: [],
    );

void main() {
  testWidgets('muestra aviso cuando el plan es genérico (fallback)', (tester) async {
    await tester.pumpWidget(_envolver(parada: {'ciudad_actual': 'Roma', 'es_fallback': true}));
    expect(find.textContaining('La IA no está disponible'), findsOneWidget);
  });

  testWidgets('no muestra aviso con un plan normal', (tester) async {
    await tester.pumpWidget(_envolver(parada: {'ciudad_actual': 'Roma'}));
    expect(find.textContaining('La IA no está disponible'), findsNothing);
  });

  testWidgets('si falla la siguiente parada permite reintentar sin perder el viaje', (tester) async {
    String? reintentoCon;
    await tester.pumpWidget(_envolver(
      itinerario: [_parada('Roma')],
      error: 'Error del servidor: 500',
      onReintentar: (ciudad) => reintentoCon = ciudad,
    ));

    expect(find.textContaining('No pudimos armar la siguiente parada'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Florencia');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pump();

    expect(reintentoCon, 'Florencia');
  });
}
