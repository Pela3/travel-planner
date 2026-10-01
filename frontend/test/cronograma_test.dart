import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/models/actividad_dia.dart';
import 'package:frontend/screens/planner/widgets/cronograma_diario.dart';
import 'package:frontend/services/cronograma.dart';

ActividadDia _dia(int n, [String lugar = '']) =>
    ActividadDia(dia: n, manana: 'M$lugar$n', tarde: 'T$lugar$n', noche: 'N$lugar$n');

/// Simula /extender-cronograma registrando cada tanda pedida.
class _ApiFalsa {
  final pedidos = <({int diaInicio, int dias, int vistos})>[];
  int fallarEnPedido = -1;
  bool numerarSiempreDesdeUno = false;
  int sobrantes = 0;

  Future<List<ActividadDia>> call({
    required int diaInicio,
    required int diasAdicionales,
    required List<String> lugaresYaVistos,
  }) async {
    pedidos.add((diaInicio: diaInicio, dias: diasAdicionales, vistos: lugaresYaVistos.length));
    if (pedidos.length - 1 == fallarEnPedido) throw Exception('red caída');
    return [
      for (var i = 0; i < diasAdicionales + sobrantes; i++)
        _dia(numerarSiempreDesdeUno ? i + 1 : diaInicio + i, 'x'),
    ];
  }
}

void main() {
  group('completarCronograma', () {
    final base = [for (var i = 1; i <= 5; i++) _dia(i)];

    test('recorta sin llamar a la API si sobran días', () async {
      final api = _ApiFalsa();
      final r = await completarCronograma(base: base, diasObjetivo: 3, pedirDiasExtra: api.call);

      expect(r.dias.length, 3);
      expect(r.completo, isTrue);
      expect(api.pedidos, isEmpty);
    });

    test('pide los días faltantes en tandas de $diasPorTanda', () async {
      final api = _ApiFalsa();
      final r = await completarCronograma(base: base, diasObjetivo: 28, pedirDiasExtra: api.call);

      expect(r.completo, isTrue);
      expect(r.dias.length, 28);
      expect(api.pedidos.map((p) => (p.diaInicio, p.dias)), [(6, 10), (16, 10), (26, 3)]);
      // Cada tanda recibe todos los lugares ya planificados (3 por día).
      expect(api.pedidos.map((p) => p.vistos), [15, 45, 75]);
    });

    test('renumera 1..N aunque la IA repita números de día', () async {
      final api = _ApiFalsa()..numerarSiempreDesdeUno = true;
      final r = await completarCronograma(base: base, diasObjetivo: 8, pedirDiasExtra: api.call);

      expect(r.dias.map((d) => d.dia), [1, 2, 3, 4, 5, 6, 7, 8]);
    });

    test('descarta días de más que mande la IA', () async {
      final api = _ApiFalsa()..sobrantes = 4;
      final r = await completarCronograma(base: base, diasObjetivo: 7, pedirDiasExtra: api.call);

      expect(r.dias.length, 7);
    });

    test('si falla una tanda devuelve lo generado y marca incompleto', () async {
      final api = _ApiFalsa()..fallarEnPedido = 1;
      final r = await completarCronograma(base: base, diasObjetivo: 25, pedirDiasExtra: api.call);

      expect(r.completo, isFalse);
      expect(r.dias.length, 15); // 5 base + primera tanda de 10
    });
  });

  group('CronogramaDiario', () {
    Future<void> mostrarDia(WidgetTester tester, int dia) {
      return tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: CronogramaDiario(
              cronograma: [
                {'dia': 1, 'manana': 'Coliseo', 'tarde': 'Foro', 'noche': 'Trastevere'},
                // La IA numeró mal este día: igual es el segundo.
                {'dia': 1, 'manana': 'Vaticano', 'tarde': 'Castel', 'noche': 'Prati'},
              ],
              diasSeleccionados: 4,
              diaSeleccionado: dia,
              fechaInicio: DateTime(2026, 11, 1),
              onDiaSeleccionado: (_) {},
            ),
          ),
        ),
      ));
    }

    testWidgets('muestra cada día por su posición', (tester) async {
      await mostrarDia(tester, 2);
      expect(find.text('Vaticano'), findsOneWidget);
      expect(find.text('Coliseo'), findsNothing);
    });

    testWidgets('un día sin generar no repite el día 1', (tester) async {
      await mostrarDia(tester, 4);
      expect(find.text('Coliseo'), findsNothing);
      expect(find.textContaining('se generan con IA al confirmar'), findsOneWidget);
    });
  });
}
