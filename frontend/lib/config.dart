import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    if (Platform.isAndroid) {
      // Debe incluir 'http://' y ':8080' al final:
      return 'http://192.168.1.37:8080';
    }
    return 'http://localhost:8080';
  }
}