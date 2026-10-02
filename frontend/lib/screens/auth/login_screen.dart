import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config.dart';
import '../../services/auth_service.dart';
import 'widgets/campo_auth.dart';
import '../../theme/app_colors.dart';

/// Pantalla de ingreso: Google o email y contraseña (entrar o crear cuenta).
/// Al entrar, AuthGate muestra la app sola.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _contrasena = TextEditingController();

  bool _creandoCuenta = false;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _ejecutar(Future<void> Function() accion) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      await accion();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _conEmail() {
    if (!_formKey.currentState!.validate()) return;
    _ejecutar(() => _creandoCuenta
        ? AuthService.registrar(_nombre.text, _email.text, _contrasena.text)
        : AuthService.entrarConEmail(_email.text, _contrasena.text));
  }

  Future<void> _recuperar() async {
    if (!esEmailValido(_email.text)) {
      setState(() => _error = 'Escribí tu email arriba y tocá de nuevo "¿Olvidaste tu contraseña?".');
      return;
    }
    await _ejecutar(() => AuthService.recuperarContrasena(_email.text));
    if (mounted && _error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Te enviamos un email a ${_email.text.trim()} para cambiar la contraseña.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: Image.asset('assets/images/logo.png', width: 96, height: 96)),
                  const SizedBox(height: 18),
                  const Text(
                    'Travel Planner',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _creandoCuenta ? 'Creá tu cuenta y guardá tus viajes.' : 'Entrá para ver y guardar tus viajes.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textoSecundario, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                  _botonGoogle(),
                  const SizedBox(height: 22),
                  const _Separador(),
                  const SizedBox(height: 22),
                  _formulario(),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primario,
                        foregroundColor: AppColors.fondo,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _cargando ? null : _conEmail,
                      child: _cargando
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                          : Text(
                              _creandoCuenta ? 'Crear cuenta' : 'Iniciar sesión',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                  if (!_creandoCuenta)
                    TextButton(
                      onPressed: _cargando ? null : _recuperar,
                      child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppColors.textoSecundario)),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _creandoCuenta ? '¿Ya tenés cuenta?' : '¿No tenés cuenta?',
                        style: const TextStyle(color: AppColors.textoSecundario),
                      ),
                      TextButton(
                        onPressed: _cargando
                            ? null
                            : () => setState(() {
                                  _creandoCuenta = !_creandoCuenta;
                                  _error = null;
                                }),
                        child: Text(
                          _creandoCuenta ? 'Iniciá sesión' : 'Creá una',
                          style: const TextStyle(color: AppColors.primario, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => launchUrl(Uri.parse(AppConfig.urlPrivacidad), mode: LaunchMode.externalApplication),
                    child: const Text(
                      'Al continuar aceptás la Política de privacidad',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textoTenue, fontSize: 12, decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _botonGoogle() {
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1F2937),
          disabledBackgroundColor: Colors.white70,
          disabledForegroundColor: const Color(0xFF475569),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: _cargando ? null : () => _ejecutar(AuthService.entrarConGoogle),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('G', style: TextStyle(color: Color(0xFF4285F4), fontWeight: FontWeight.w900, fontSize: 22)),
            SizedBox(width: 12),
            Text('Continuar con Google', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _formulario() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_creandoCuenta) ...[
            CampoAuth(
              controller: _nombre,
              etiqueta: 'Nombre',
              textInputAction: TextInputAction.next,
              icono: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              validator: (v) => (v ?? '').trim().isEmpty ? 'Contanos cómo te llamás.' : null,
            ),
            const SizedBox(height: 12),
          ],
          CampoAuth(
            controller: _email,
            etiqueta: 'Email',
            textInputAction: TextInputAction.next,
            icono: Icons.mail_outline,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            validator: (v) => esEmailValido(v ?? '') ? null : 'Escribí un email válido.',
          ),
          const SizedBox(height: 12),
          CampoAuth(
            controller: _contrasena,
            etiqueta: 'Contraseña',
            icono: Icons.lock_outline,
            esContrasena: true,
            autofillHints: [_creandoCuenta ? AutofillHints.newPassword : AutofillHints.password],
            onSubmitted: (_) => _conEmail(),
            validator: (v) {
              if ((v ?? '').isEmpty) return 'Escribí tu contraseña.';
              if (_creandoCuenta && v!.length < 6) return 'Usá al menos 6 caracteres.';
              return null;
            },
          ),
        ],
      ),
    );
  }
}

bool esEmailValido(String email) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());

class _Separador extends StatelessWidget {
  const _Separador();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.borde)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('o con tu email', style: TextStyle(color: AppColors.textoTenue, fontSize: 12)),
        ),
        Expanded(child: Divider(color: AppColors.borde)),
      ],
    );
  }
}
