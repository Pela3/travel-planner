import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  /// Política de privacidad (GitHub Pages, carpeta /docs del repo).
  static const String urlPrivacidad = 'https://pela3.github.io/travel-planner/privacidad/';

  /// URL del backend definida al compilar, p. ej.:
  ///   flutter build appbundle --dart-define=API_BASE_URL=https://api.tu-dominio.com
  static const String _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_apiBaseUrl.isNotEmpty) return _apiBaseUrl;

    // Valores por defecto para desarrollo local.
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (Platform.isAndroid) {
      // IP de la PC en la red local (para probar en un celular físico).
      return 'http://192.168.1.37:8080';
    }
    return 'http://localhost:8080';
  }
}
