import 'actividad_dia.dart';
import 'atraccion_detallada.dart';
import 'info_clima.dart';
import 'info_traslado.dart';
import 'presupuesto_estimado.dart';

class ParadaConfirmada {
  final String ciudad;
  final String ciudadOrigen;
  final int dias;
  final DateTime fechaInicio;
  final String resumen;
  final InfoTraslado? traslado;
  final PresupuestoEstimado? presupuesto;
  final InfoClima? clima;
  final List<AtraccionDetallada> atracciones;
  final List<ActividadDia> cronograma;

  ParadaConfirmada({
    required this.ciudad,
    required this.ciudadOrigen,
    required this.dias,
    required this.fechaInicio,
    required this.resumen,
    this.traslado,
    this.presupuesto,
    this.clima,
    required this.atracciones,
    required this.cronograma,
  });

  int get costoTotalParada => (presupuesto?.totalDiario ?? 0) * dias;

  Map<String, dynamic> toJson() => {
        'ciudad': ciudad,
        'ciudad_origen': ciudadOrigen,
        'dias': dias,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'resumen': resumen,
        'traslado': traslado?.toJson(),
        'presupuesto': presupuesto?.toJson(),
        'clima': clima?.toJson(),
        'atracciones': atracciones.map((a) => a.toJson()).toList(),
        'cronograma': cronograma.map((c) => c.toJson()).toList(),
      };

  factory ParadaConfirmada.fromJson(Map<String, dynamic> json) => ParadaConfirmada(
        ciudad: json['ciudad'] as String? ?? '',
        ciudadOrigen: json['ciudad_origen'] as String? ?? '',
        dias: json['dias'] as int? ?? 1,
        fechaInicio: DateTime.tryParse(json['fecha_inicio'] as String? ?? '') ?? DateTime.now(),
        resumen: json['resumen'] as String? ?? '',
        traslado: json['traslado'] != null ? InfoTraslado.fromJson(json['traslado'] as Map<String, dynamic>) : null,
        presupuesto: json['presupuesto'] != null ? PresupuestoEstimado.fromJson(json['presupuesto'] as Map<String, dynamic>) : null,
        clima: json['clima'] != null ? InfoClima.fromJson(json['clima'] as Map<String, dynamic>) : null,
        atracciones: (json['atracciones'] as List<dynamic>?)
                ?.map((a) => AtraccionDetallada.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
        cronograma: (json['cronograma'] as List<dynamic>?)
                ?.map((c) => ActividadDia.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
