import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// Se muestra a las cuentas de email y contraseña hasta que tocan el link del
/// correo de verificación. Las acciones llegan por parámetro (AuthGate las
/// conecta con Firebase), así la pantalla se puede probar sin Firebase.
class VerificarEmailScreen extends StatefulWidget {
  final String email;

  /// Devuelve true si el email ya está verificado.
  final Future<bool> Function() onComprobar;
  final Future<void> Function() onReenviar;
  final Future<void> Function() onUsarOtraCuenta;

  const VerificarEmailScreen({
    super.key,
    required this.email,
    required this.onComprobar,
    required this.onReenviar,
    required this.onUsarOtraCuenta,
  });

  @override
  State<VerificarEmailScreen> createState() => _VerificarEmailScreenState();
}

class _VerificarEmailScreenState extends State<VerificarEmailScreen> with WidgetsBindingObserver {
  /// Firebase limita los reenvíos; además evita mandar varios por ansiedad.
  static const _esperaReenvio = 30;

  bool _comprobando = false;
  int _segundosParaReenviar = _esperaReenvio;
  Timer? _timer;
  String? _mensaje;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _arrancarEspera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // Vuelve del correo a la app: se comprueba solo, sin tocar nada.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _comprobar(silencioso: true);
  }

  void _arrancarEspera() {
    _timer?.cancel();
    setState(() => _segundosParaReenviar = _esperaReenvio);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _segundosParaReenviar--);
      if (_segundosParaReenviar <= 0) t.cancel();
    });
  }

  Future<void> _comprobar({bool silencioso = false}) async {
    if (_comprobando) return;
    setState(() {
      _comprobando = true;
      if (!silencioso) _mensaje = null;
    });
    var verificado = false;
    String? error;
    try {
      verificado = await widget.onComprobar();
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() {
      _comprobando = false;
      // Si se verificó, AuthGate cambia de pantalla solo.
      if (!verificado && !silencioso) {
        _mensaje = error ?? 'Todavía no está verificado. Tocá el link del correo y probá de nuevo.';
      }
    });
  }

  Future<void> _reenviar() async {
    String? error;
    try {
      await widget.onReenviar();
    } catch (e) {
      error = e.toString();
    }
    if (!mounted) return;
    setState(() => _mensaje = error ?? 'Te mandamos otro correo a ${widget.email}.');
    if (error == null) _arrancarEspera();
  }

  @override
  Widget build(BuildContext context) {
    final puedeReenviar = _segundosParaReenviar <= 0;
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.mark_email_unread_outlined, size: 64, color: AppColors.primario),
                  const SizedBox(height: 20),
                  const Text(
                    'Verificá tu email',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.texto, fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Te mandamos un correo a ${widget.email}. Tocá el link que trae y volvé a la app.\n\n'
                    'Si no lo ves, revisá la carpeta de spam.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textoSecundario, fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primario,
                        foregroundColor: AppColors.fondo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _comprobando ? null : _comprobar,
                      child: _comprobando
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                          : const Text('Ya lo verifiqué', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: puedeReenviar ? _reenviar : null,
                    child: Text(
                      puedeReenviar ? 'Reenviar el correo' : 'Reenviar el correo ($_segundosParaReenviar s)',
                      style: TextStyle(color: puedeReenviar ? AppColors.primario : AppColors.textoTenue),
                    ),
                  ),
                  if (_mensaje != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _mensaje!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textoClaro, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: widget.onUsarOtraCuenta,
                    child: const Text('Usar otra cuenta', style: TextStyle(color: AppColors.textoSecundario)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
