import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/borrador_storage.dart';
import '../../services/viajes_storage.dart';
import '../main_navigation_screen.dart';
import 'cuenta_screen.dart';
import 'login_screen.dart';

/// Muestra el login o la app según haya sesión iniciada.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final StreamSubscription<User?> _sub;
  bool _iniciando = true;
  User? _usuario;

  @override
  void initState() {
    super.initState();
    _sub = AuthService.cambiosDeUsuario.listen(_alCambiarUsuario);
  }

  Future<void> _alCambiarUsuario(User? usuario) async {
    // Los viajes pasan a la cuenta antes de mostrar la app, así Mis Viajes
    // ya carga los del usuario (y los que había en el teléfono).
    if (usuario != null && usuario.uid != _usuario?.uid) await ViajesStorage.usarCuenta(usuario.uid);
    BorradorStorage.usuario = usuario?.uid;
    if (!mounted) return;
    setState(() {
      _usuario = usuario;
      _iniciando = false;
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_iniciando) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B111E),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final usuario = _usuario;
    if (usuario == null) return const LoginScreen();
    // La key reinicia el planificador y las pestañas si cambia la cuenta.
    return MainNavigationScreen(
      key: ValueKey(usuario.uid),
      nombreUsuario: usuario.displayName,
      fotoUsuario: usuario.photoURL,
      onAbrirCuenta: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CuentaScreen())),
    );
  }
}
