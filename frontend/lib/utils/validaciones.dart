/// Mismas reglas que el backend (backend/internal/models/validacion.go): un
/// nombre de lugar admite letras de cualquier idioma, números, espacios y
/// . , ' ’ - ( ) / &. Así el usuario ve el problema antes de mandar el pedido.
final _caracteresLugar = RegExp(r"^[\p{L}\p{M}\p{N} .,'’\-()/&]*$", unicode: true);

const maxLargoLugar = 100;

/// Devuelve el error para mostrar, o null si [valor] es un nombre de lugar válido.
String? validarNombreLugar(String valor, {required String campo}) {
  final v = valor.trim();
  if (v.length > maxLargoLugar) return '$campo es demasiado largo.';
  if (!_caracteresLugar.hasMatch(v)) {
    return "$campo solo puede tener letras, números, espacios y . , ' - ( ).";
  }
  return null;
}
