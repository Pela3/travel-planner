import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/actividad_dia.dart';

/// Error HTTP del backend (status distinto de 200).
class ApiException implements Exception {
  final int statusCode;
  ApiException(this.statusCode);

  @override
  String toString() {
    if (statusCode == 429) return 'Demasiadas solicitudes. Esperá un minuto e intentá de nuevo.';
    if (statusCode == 401) return 'Tu sesión venció. Cerrá sesión y volvé a entrar.';
    if (statusCode == 400) return 'Revisá los datos del viaje (destino, origen y días) e intentá de nuevo.';
    return 'Error del servidor: $statusCode';
  }
}

// Generoso a propósito: en el plan gratuito de Render el primer pedido tras un
// rato sin uso "despierta" el servidor y puede tardar cerca de un minuto.
const _timeout = Duration(seconds: 90);

/// Encabezados de cada pedido: el backend solo atiende a usuarios con sesión
/// (ID token de Firebase, que el SDK renueva solo cuando vence).
Future<Map<String, String>> _encabezados() async {
  final token = await FirebaseAuth.instance.currentUser?.getIdToken();
  return {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };
}

class TravelApi {
  static Future<Map<String, dynamic>> planificar({
    required String origen,
    required String destino,
    required int diasTotales,
    required int diasRestantes,
    required String estilo,
    required String mes,
    required String compania,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/v1/planificar'),
      headers: await _encabezados(),
      body: jsonEncode({
        'ciudad_origen': origen,
        'destino': destino,
        'dias_totales': diasTotales,
        'dias_restantes': diasRestantes,
        'estilo_viaje': estilo,
        'mes_viaje': mes,
        'compania': compania,
      }),
    ).timeout(_timeout);

    if (response.statusCode != 200) throw ApiException(response.statusCode);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static Future<List<ActividadDia>> extenderCronograma({
    required String ciudad,
    required String estilo,
    required int diaInicio,
    required int diasAdicionales,
    required List<String> lugaresYaVistos,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConfig.baseUrl}/api/v1/extender-cronograma'),
      headers: await _encabezados(),
      body: jsonEncode({
        'ciudad': ciudad,
        'estilo': estilo,
        'dia_inicio': diaInicio,
        'dias_adicionales': diasAdicionales,
        'lugares_ya_vistos': lugaresYaVistos,
      }),
    ).timeout(_timeout);

    if (response.statusCode != 200) throw ApiException(response.statusCode);
    final data = jsonDecode(response.body);
    return (data['dias_extendidos'] as List<dynamic>)
        .map((d) => ActividadDia.fromJson(d as Map<String, dynamic>))
        .toList();
  }
}
