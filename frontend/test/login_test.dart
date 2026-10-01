import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/screens/auth/login_screen.dart';
import 'package:frontend/screens/home/home_screen.dart';
import 'package:frontend/services/auth_service.dart';

/// Scrollea hasta el widget (la pantalla de test es de 800x600) y lo toca.
Future<void> tocar(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  group('Pantalla de login', () {
    // Las validaciones fallan antes de llamar a Firebase.
    testWidgets('pide email y contraseña válidos', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'no-es-un-email');
      await tocar(tester, find.text('Iniciar sesión'));

      expect(find.text('Escribí un email válido.'), findsOneWidget);
      expect(find.text('Escribí tu contraseña.'), findsOneWidget);
    });

    testWidgets('pasa a crear cuenta y pide nombre y 6 caracteres', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tocar(tester, find.text('Creá una'));
      expect(find.widgetWithText(TextFormField, 'Nombre'), findsOneWidget);
      expect(find.text('¿Olvidaste tu contraseña?'), findsNothing);

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'ana@mail.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Contraseña'), '123');
      await tocar(tester, find.text('Crear cuenta'));

      expect(find.text('Contanos cómo te llamás.'), findsOneWidget);
      expect(find.text('Usá al menos 6 caracteres.'), findsOneWidget);
    });

    testWidgets('olvidé mi contraseña sin email avisa qué hacer', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      await tocar(tester, find.text('¿Olvidaste tu contraseña?'));

      expect(find.textContaining('Escribí tu email arriba'), findsOneWidget);
    });

    testWidgets('la contraseña se puede mostrar', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

      EditableText campo() => tester.widget<EditableText>(
          find.descendant(of: find.widgetWithText(TextFormField, 'Contraseña'), matching: find.byType(EditableText)));

      expect(campo().obscureText, isTrue);
      await tocar(tester, find.byTooltip('Mostrar contraseña'));
      expect(campo().obscureText, isFalse);
    });
  });

  test('valida emails', () {
    expect(esEmailValido('ana@mail.com'), isTrue);
    expect(esEmailValido('  ana@mail.com '), isTrue);
    expect(esEmailValido('ana@mail'), isFalse);
    expect(esEmailValido('ana mail.com'), isFalse);
  });

  test('traduce los errores de Firebase', () {
    expect(AuthService.mensajeDeError('invalid-credential'), 'Email o contraseña incorrectos.');
    expect(AuthService.mensajeDeError('email-already-in-use'), contains('Ya hay una cuenta'));
    expect(AuthService.mensajeDeError('codigo-raro'), 'Algo salió mal. Probá de nuevo.');
  });

  testWidgets('el inicio saluda con el primer nombre y abre la cuenta', (tester) async {
    var abierta = false;
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(nombreUsuario: 'Ana María López', onAbrirCuenta: () => abierta = true),
    ));

    expect(find.text('¡Hola, Ana! 👋'), findsOneWidget);
    await tester.tap(find.byTooltip('Mi cuenta'));
    expect(abierta, isTrue);
  });
}
