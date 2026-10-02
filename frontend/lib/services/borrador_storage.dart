import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

/// Viaje a medio planificar, para retomarlo si se cerró la app.
class BorradorViaje {
  final String origen;
  final String destino;
  final DateTime fechaSalida;
  final String estilo;
  final String compania;
  final int diasTotales;
  final int diasRestantes;
  final int diasSeleccionados;
  final List<ParadaConfirmada> itinerario;

  /// Respuesta de la IA para la parada que se estaba revisando (puede faltar
  /// si se cerró la app mientras cargaba la siguiente).
  final Map<String, dynamic>? paradaActual;

  const BorradorViaje({
    required this.origen,
    required this.destino,
    required this.fechaSalida,
    required this.estilo,
    required this.compania,
    required this.diasTotales,
    required this.diasRestantes,
    required this.diasSeleccionados,
    required this.itinerario,
    required this.paradaActual,
  });

  /// "Buenos Aires ➔ Roma ➔ Florencia", con la parada en revisión incluida.
  String get recorrido {
    final ciudades = [
      origen,
      ...itinerario.map((p) => p.ciudad),
      if (paradaActual?['ciudad_actual'] case final String ciudad) ciudad,
    ];
    return ciudades.join(' ➔ ');
  }

  int get diasPlanificados => diasTotales - diasRestantes;

  Map<String, dynamic> toJson() => {
        'origen': origen,
        'destino': destino,
        'fecha_salida': fechaSalida.toIso8601String(),
        'estilo': estilo,
        'compania': compania,
        'dias_totales': diasTotales,
        'dias_restantes': diasRestantes,
        'dias_seleccionados': diasSeleccionados,
        'itinerario': itinerario.map((p) => p.toJson()).toList(),
        'parada_actual': paradaActual,
      };

  factory BorradorViaje.fromJson(Map<String, dynamic> json) => BorradorViaje(
        origen: json['origen'] as String,
        destino: json['destino'] as String,
        fechaSalida: DateTime.parse(json['fecha_salida'] as String),
        estilo: json['estilo'] as String,
        compania: json['compania'] as String,
        diasTotales: json['dias_totales'] as int,
        diasRestantes: json['dias_restantes'] as int,
        diasSeleccionados: json['dias_seleccionados'] as int,
        itinerario: (json['itinerario'] as List<dynamic>)
            .map((p) => ParadaConfirmada.fromJson(p as Map<String, dynamic>))
            .toList(),
        paradaActual: json['parada_actual'] as Map<String, dynamic>?,
      );
}

/// Guarda el borrador en el teléfono, uno por cuenta.
class BorradorStorage {
  /// Usuario con sesión (lo define AuthGate). Sin login (tests) se usa una
  /// clave común.
  static String? usuario;

  static String get _key => usuario == null ? 'borrador_viaje' : 'borrador_viaje_$usuario';

  static Future<BorradorViaje?> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return BorradorViaje.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Borrador de una versión vieja o corrupto: no vale la pena trabar la app.
      await prefs.remove(_key);
      return null;
    }
  }

  static Future<void> guardar(BorradorViaje borrador) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(borrador.toJson()));
  }

  static Future<void> borrar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
