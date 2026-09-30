import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('La app arranca en Inicio y navega a Planificar', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelPlannerApp());
    await tester.pump();

    expect(find.text('¡Hola, viajero! 👋'), findsOneWidget);

    await tester.tap(find.text('Planificar'));
    await tester.pumpAndSettle();

    expect(find.text('¿A dónde querés viajar?'), findsOneWidget);
  });

  testWidgets('Mis Viajes muestra estado vacío sin viajes guardados', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelPlannerApp());
    await tester.tap(find.text('Mis Viajes'));
    await tester.pumpAndSettle();

    expect(find.text('No tenés viajes guardados todavía'), findsOneWidget);
  });
}
