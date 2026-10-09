import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/screens/auth/verificar_email_screen.dart';

void main() {
  late int comprobaciones;
  late int reenvios;
  late bool cerroSesion;
  late bool verificado;

  Widget pantalla() => MaterialApp(
        home: VerificarEmailScreen(
          email: 'ana@mail.com',
          onComprobar: () async {
            comprobaciones++;
            return verificado;
          },
          onReenviar: () async => reenvios++,
          onUsarOtraCuenta: () async => cerroSesion = true,
        ),
      );

  setUp(() {
    comprobaciones = 0;
    reenvios = 0;
    cerroSesion = false;
    verificado = false;
  });

  testWidgets('explica qué hacer y a qué email se mandó el correo', (tester) async {
    await tester.pumpWidget(pantalla());

    expect(find.text('Verificá tu email'), findsOneWidget);
    expect(find.textContaining('ana@mail.com'), findsOneWidget);
    expect(find.textContaining('spam'), findsOneWidget);
  });

  testWidgets('si todavía no verificó, lo avisa', (tester) async {
    await tester.pumpWidget(pantalla());

    await tester.tap(find.text('Ya lo verifiqué'));
    await tester.pumpAndSettle();

    expect(comprobaciones, 1);
    expect(find.textContaining('Todavía no está verificado'), findsOneWidget);
  });

  testWidgets('reenviar espera 30 segundos entre correos', (tester) async {
    await tester.pumpWidget(pantalla());

    expect(find.text('Reenviar el correo (30 s)'), findsOneWidget);
    await tester.tap(find.textContaining('Reenviar el correo'));
    await tester.pump();
    expect(reenvios, 0);

    await tester.pump(const Duration(seconds: 30));
    await tester.tap(find.text('Reenviar el correo'));
    await tester.pump();
    expect(reenvios, 1);
    expect(find.textContaining('Te mandamos otro correo'), findsOneWidget);
    expect(find.text('Reenviar el correo (30 s)'), findsOneWidget);
  });

  testWidgets('al volver a la app comprueba solo', (tester) async {
    await tester.pumpWidget(pantalla());

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(comprobaciones, 1);
    // Silencioso: no muestra "todavía no está verificado" sin que lo pida.
    expect(find.textContaining('Todavía no está verificado'), findsNothing);
  });

  testWidgets('puede salir y usar otra cuenta', (tester) async {
    await tester.pumpWidget(pantalla());

    await tester.tap(find.text('Usar otra cuenta'));
    await tester.pump();

    expect(cerroSesion, isTrue);
  });
}
