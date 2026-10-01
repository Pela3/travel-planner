import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'viajes_storage.dart';

/// Error de login con un mensaje listo para mostrar.
class AuthException implements Exception {
  final String mensaje;
  const AuthException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Login con Firebase: cuenta de Google o email y contraseña.
class AuthService {
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static bool _googleIniciado = false;

  /// Incluye los cambios de perfil (el nombre se carga después de registrarse).
  static Stream<User?> get cambiosDeUsuario => _auth.userChanges();
  static User? get usuario => _auth.currentUser;

  static bool get entroConGoogle =>
      usuario?.providerData.any((p) => p.providerId == GoogleAuthProvider.PROVIDER_ID) ?? false;

  /// Devuelve false si el usuario cerró la ventana de Google sin elegir cuenta.
  static Future<bool> entrarConGoogle() async {
    final credencial = await _credencialGoogle();
    if (credencial == null) return false;
    await _intentar(() => _auth.signInWithCredential(credencial));
    return true;
  }

  static Future<void> entrarConEmail(String email, String contrasena) =>
      _intentar(() => _auth.signInWithEmailAndPassword(email: email.trim(), password: contrasena));

  static Future<void> registrar(String nombre, String email, String contrasena) => _intentar(() async {
        final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: contrasena);
        await cred.user?.updateDisplayName(nombre.trim());
        await cred.user?.reload();
      });

  static Future<void> recuperarContrasena(String email) =>
      _intentar(() => _auth.sendPasswordResetEmail(email: email.trim()));

  static Future<void> cerrarSesion() async {
    if (entroConGoogle) {
      await _iniciarGoogle();
      await GoogleSignIn.instance.signOut();
    }
    await _auth.signOut();
    ViajesStorage.repositorio = RepositorioLocal();
  }

  /// Borra los viajes del usuario y su cuenta. Firebase exige un login
  /// reciente: se vuelve a pedir Google o la [contrasena].
  static Future<void> eliminarCuenta({String? contrasena}) async {
    final user = usuario;
    if (user == null) return;

    final AuthCredential? credencial = entroConGoogle
        ? await _credencialGoogle()
        : EmailAuthProvider.credential(email: user.email ?? '', password: contrasena ?? '');
    if (credencial == null) throw const AuthException('Se canceló la confirmación con Google.');

    await _intentar(() async {
      await user.reauthenticateWithCredential(credencial);
      await RepositorioFirestore(user.uid).borrarTodo();
      await user.delete();
    });
    await cerrarSesion();
  }

  static Future<void> _iniciarGoogle() async {
    if (_googleIniciado) return;
    // En Android toma el client id web de google-services.json.
    await GoogleSignIn.instance.initialize();
    _googleIniciado = true;
  }

  static Future<AuthCredential?> _credencialGoogle() async {
    try {
      await _iniciarGoogle();
      final cuenta = await GoogleSignIn.instance.authenticate();
      return GoogleAuthProvider.credential(idToken: cuenta.authentication.idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw const AuthException('No se pudo entrar con Google. Probá de nuevo.');
    }
  }

  static Future<void> _intentar(Future<void> Function() accion) async {
    try {
      await accion();
    } on FirebaseAuthException catch (e) {
      throw AuthException(mensajeDeError(e.code));
    }
  }

  static String mensajeDeError(String codigo) {
    switch (codigo) {
      case 'invalid-email':
        return 'El email no es válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya hay una cuenta con ese email. Probá iniciar sesión.';
      case 'weak-password':
        return 'La contraseña tiene que tener al menos 6 caracteres.';
      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';
      case 'too-many-requests':
        return 'Demasiados intentos. Esperá unos minutos y probá de nuevo.';
      case 'network-request-failed':
        return 'Sin conexión. Revisá tu internet.';
      case 'account-exists-with-different-credential':
        return 'Ese email ya está registrado con otro método de ingreso.';
      default:
        return 'Algo salió mal. Probá de nuevo.';
    }
  }
}
