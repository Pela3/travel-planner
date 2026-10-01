import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/screens/planner/widgets/selector_dias_card.dart';

Future<int?> _tocarQuedarseTodo(WidgetTester tester, {required int seleccionados, required int restantes}) async {
  int? elegido;
  await tester.pumpWidget(MaterialApp(
    home: Scaffold(
      body: SelectorDiasCard(
        diasRecomendados: 3,
        diasSeleccionados: seleccionados,
        diasRestantes: restantes,
        onChanged: (d) => elegido = d,
      ),
    ),
  ));
  final boton = find.textContaining('restantes acá');
  if (boton.evaluate().isEmpty) return null;
  await tester.tap(boton);
  return elegido;
}

void main() {
  testWidgets('"Quedarme todo" asigna todos los días restantes', (tester) async {
    expect(await _tocarQuedarseTodo(tester, seleccionados: 3, restantes: 12), 12);
    expect(find.text('Quedarme los 12 días restantes acá'), findsOneWidget);
  });

  testWidgets('no aparece si ya están todos los días asignados', (tester) async {
    expect(await _tocarQuedarseTodo(tester, seleccionados: 5, restantes: 5), isNull);
  });

  testWidgets('no aparece si queda un solo día', (tester) async {
    expect(await _tocarQuedarseTodo(tester, seleccionados: 1, restantes: 1), isNull);
  });
}
