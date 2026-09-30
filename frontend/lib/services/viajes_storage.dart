import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/viaje_guardado.dart';

/// Persistencia local de los viajes guardados (SharedPreferences).
class ViajesStorage {
  static const _key = 'mis_viajes';

  /// Devuelve los viajes del más nuevo al más viejo.
  static Future<List<ViajeGuardado>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList.map((str) => ViajeGuardado.fromJson(jsonDecode(str))).toList().reversed.toList();
  }

  static Future<void> guardar(ViajeGuardado viaje) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(jsonEncode(viaje.toJson()));
    await prefs.setStringList(_key, data);
  }

  static Future<void> eliminar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    final updated = rawList.where((str) {
      final map = jsonDecode(str);
      return map['id'] != id;
    }).toList();
    await prefs.setStringList(_key, updated);
  }
}
