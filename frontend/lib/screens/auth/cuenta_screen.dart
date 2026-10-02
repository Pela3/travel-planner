import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';

/// Datos de la cuenta, política de privacidad, cerrar sesión y eliminar cuenta
/// (Google Play exige que se pueda eliminar la cuenta desde la app).
class CuentaScreen extends StatefulWidget {
  const CuentaScreen({super.key});

  @override
  State<CuentaScreen> createState() => _CuentaScreenState();
}

class _CuentaScreenState extends State<CuentaScreen> {
  bool _eliminando = false;

  Future<void> _cerrarSesion() async {
    final navigator = Navigator.of(context);
    await AuthService.cerrarSesion();
    navigator.popUntil((r) => r.isFirst);
  }

  Future<void> _eliminarCuenta() async {
    final conGoogle = AuthService.entroConGoogle;
    final contrasena = TextEditingController();

    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.superficie,
        title: const Text('¿Eliminar tu cuenta?', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Se borran tu cuenta y todos tus viajes guardados. No se puede deshacer.'
              '${conGoogle ? '\n\nVamos a pedirte que elijas tu cuenta de Google para confirmar.' : ''}',
              style: const TextStyle(color: AppColors.textoClaro),
            ),
            if (!conGoogle) ...[
              const SizedBox(height: 16),
              TextField(
                controller: contrasena,
                obscureText: true,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Tu contraseña para confirmar'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    final clave = contrasena.text;
    contrasena.dispose();
    if (confirmado != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _eliminando = true);
    try {
      await AuthService.eliminarCuenta(contrasena: clave);
      messenger.showSnackBar(const SnackBar(content: Text('Tu cuenta y tus viajes fueron eliminados.')));
      navigator.popUntil((r) => r.isFirst);
    } on AuthException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.mensaje)));
    } finally {
      if (mounted) setState(() => _eliminando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = AuthService.usuario;
    final nombre = usuario?.displayName ?? '';

    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        foregroundColor: Colors.white,
        title: const Text('Mi cuenta'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          Center(child: AvatarUsuario(radio: 40, fotoUrl: usuario?.photoURL, nombre: nombre)),
          const SizedBox(height: 14),
          if (nombre.isNotEmpty)
            Text(nombre,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          const SizedBox(height: 4),
          Text(usuario?.email ?? '',
              textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textoSecundario, fontSize: 14)),
          const SizedBox(height: 30),
          _Opcion(
            icono: Icons.privacy_tip_outlined,
            texto: 'Política de privacidad',
            onTap: () => launchUrl(Uri.parse(AppConfig.urlPrivacidad), mode: LaunchMode.externalApplication),
          ),
          _Opcion(icono: Icons.logout, texto: 'Cerrar sesión', onTap: _eliminando ? null : _cerrarSesion),
          _Opcion(
            icono: Icons.delete_outline,
            texto: _eliminando ? 'Eliminando…' : 'Eliminar cuenta',
            color: Colors.redAccent,
            onTap: _eliminando ? null : _eliminarCuenta,
          ),
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color color;
  final VoidCallback? onTap;

  const _Opcion({required this.icono, required this.texto, this.color = Colors.white, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          leading: Icon(icono, color: color),
          title: Text(texto, style: TextStyle(color: color)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textoTenue),
          onTap: onTap,
        ),
      ),
    );
  }
}

/// Foto de la cuenta de Google o la inicial del nombre.
class AvatarUsuario extends StatelessWidget {
  final double radio;
  final String? fotoUrl;
  final String nombre;

  const AvatarUsuario({super.key, required this.radio, this.fotoUrl, this.nombre = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radio * 2,
      height: radio * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primario, width: 1.5),
        gradient: const LinearGradient(
          colors: [AppColors.primarioOscuro, AppColors.primario],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: fotoUrl != null ? DecorationImage(image: NetworkImage(fotoUrl!), fit: BoxFit.cover) : null,
      ),
      child: fotoUrl != null
          ? null
          : Center(
              child: nombre.isNotEmpty
                  ? Text(nombre.characters.first.toUpperCase(),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: radio * 0.9))
                  : Icon(Icons.person, color: Colors.white, size: radio),
            ),
    );
  }
}
