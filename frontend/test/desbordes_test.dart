import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:frontend/app.dart';
import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/main_navigation_screen.dart';

/// La fuente de los tests dibuja cada letra como un cuadrado (mucho más ancha
/// que la real) y marca desbordes que en el teléfono no existen. Se carga Open
/// Sans, un poco más ancha que Roboto: si entra con ella, entra en Android.
Future<void> cargarFuenteReal() async {
  final loader = FontLoader('Roboto');
  for (final archivo in ['OpenSans-Regular.ttf', 'OpenSans-Bold.ttf']) {
    final bytes = File('assets/fonts/$archivo').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

/// Teléfono chico (360 de ancho) con la letra del sistema al [escala].
void telefonoChico(WidgetTester tester, double escala) {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

Future<void> tocar(WidgetTester tester, String texto) async {
  await tester.tap(find.text(texto));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(cargarFuenteReal);
  setUp(() => SharedPreferences.setMockInitialValues({}));

  // Un desborde ("RenderFlex overflowed") hace fallar el test solo.
  for (final escala in [1.0, 1.3]) {
    testWidgets('las pantallas entran en 360 de ancho con letra al ${(escala * 100).round()}%', (tester) async {
      telefonoChico(tester, escala);
      await tester.pumpWidget(const TravelPlannerApp(home: MainNavigationScreen()));
      await tester.pumpAndSettle();

      await tocar(tester, 'Mis Viajes');
      await tocar(tester, 'Planificar');
      await tocar(tester, 'Siguiente');
      await tocar(tester, 'Siguiente');
    });

    testWidgets('el login entra en 360 de ancho con letra al ${(escala * 100).round()}%', (tester) async {
      telefonoChico(tester, escala);
      await tester.pumpWidget(const TravelPlannerApp(home: LoginScreen()));
      await tester.pumpAndSettle();
      await tocar(tester, 'Creá una');
    });
  }
}
