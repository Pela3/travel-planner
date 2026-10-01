import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/actividad_dia.dart';

/// Error HTTP del backend (status distinto de 200).
class ApiException implements Exception {
  final int statusCode;
  ApiException(this.statusCode);

  @override
  String toString() => 'Error del servidor: $statusCode';
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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ciudad_origen': origen,
        'destino': destino,
        'dias_totales': diasTotales,
        'dias_restantes': diasRestantes,
        'estilo_viaje': estilo,
        'mes_viaje': mes,
        'compania': compania,
      }),
    );

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
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ciudad': ciudad,
        'estilo': estilo,
        'dia_inicio': diaInicio,
        'dias_adicionales': diasAdicionales,
        'lugares_ya_vistos': lugaresYaVistos,
      }),
    );

    if (response.statusCode != 200) throw ApiException(response.statusCode);
    final data = jsonDecode(response.body);
    return (data['dias_extendidos'] as List<dynamic>)
        .map((d) => ActividadDia.fromJson(d as Map<String, dynamic>))
        .toList();
  }
}
