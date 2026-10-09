import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/borrador_storage.dart';
import '../../services/viajes_storage.dart';
import '../main_navigation_screen.dart';
import 'cuenta_screen.dart';
import 'login_screen.dart';
import 'verificar_email_screen.dart';
import '../../theme/app_colors.dart';

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
  String? _uidConViajes;

  @override
  void initState() {
    super.initState();
    _sub = AuthService.cambiosDeUsuario.listen(_alCambiarUsuario);
  }

  Future<void> _alCambiarUsuario(User? usuario) async {
    // Los viajes pasan a la cuenta antes de mostrar la app, así Mis Viajes
    // ya carga los del usuario (y los que había en el teléfono).
    // Recién con el email verificado: antes Firestore rechaza las escrituras
    // y los viajes del teléfono quedarían sin subir.
    if (usuario != null && !AuthService.necesitaVerificarEmail(usuario) && usuario.uid != _uidConViajes) {
      _uidConViajes = usuario.uid;
      await ViajesStorage.usarCuenta(usuario.uid);
    }
    BorradorStorage.usuario = usuario?.uid;
    if (!mounted) return;
    // Se cerró la sesión (o venció, o se borró la cuenta en otro lado): se
    // cierran los carteles y pantallas abiertos, que si no quedan encima del
    // login (pasaba con "¿Retomar tu viaje?").
    if (usuario == null) _uidConViajes = null;
    if (usuario == null && _usuario != null) {
      Navigator.of(context).popUntil((ruta) => ruta.isFirst);
    }
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
        backgroundColor: AppColors.fondo,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final usuario = _usuario;
    if (usuario == null) return const LoginScreen();
    if (AuthService.necesitaVerificarEmail(usuario)) {
      return VerificarEmailScreen(
        email: usuario.email ?? '',
        onComprobar: AuthService.comprobarVerificacion,
        onReenviar: AuthService.reenviarVerificacion,
        onUsarOtraCuenta: AuthService.cerrarSesion,
      );
    }
    // La key reinicia el planificador y las pestañas si cambia la cuenta.
    return MainNavigationScreen(
      key: ValueKey(usuario.uid),
      nombreUsuario: usuario.displayName,
      fotoUsuario: usuario.photoURL,
      onAbrirCuenta: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CuentaScreen())),
    );
  }
}
