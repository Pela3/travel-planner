import 'parada_confirmada.dart';

class ViajeGuardado {
  final String id;
  final String titulo;
  final String origenInicial;
  final String estilo;
  final String mes;
  final DateTime fechaInicio;
  final int diasTotales;
  final int costoTotalEstimado;
  final DateTime fechaCreacion;
  final List<ParadaConfirmada> paradas;

  ViajeGuardado({
    required this.id,
    required this.titulo,
    required this.origenInicial,
    required this.estilo,
    required this.mes,
    required this.fechaInicio,
    required this.diasTotales,
    required this.costoTotalEstimado,
    required this.fechaCreacion,
    required this.paradas,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'origen_inicial': origenInicial,
        'estilo': estilo,
        'mes': mes,
        'fecha_inicio': fechaInicio.toIso8601String(),
        'diasTotales': diasTotales,
        'costoTotalEstimado': costoTotalEstimado,
        'fechaCreacion': fechaCreacion.toIso8601String(),
        'paradas': paradas.map((p) => p.toJson()).toList(),
      };

  factory ViajeGuardado.fromJson(Map<String, dynamic> json) => ViajeGuardado(
        id: json['id'] as String? ?? '',
        titulo: json['titulo'] as String? ?? 'Mi Viaje',
        origenInicial: json['origen_inicial'] as String? ?? 'Origen',
        estilo: json['estilo'] as String? ?? 'Cultural',
        mes: json['mes'] as String? ?? 'Mayo',
        fechaInicio: DateTime.tryParse(json['fecha_inicio'] as String? ?? '') ?? DateTime.now(),
        diasTotales: json['diasTotales'] as int? ?? 0,
        costoTotalEstimado: json['costoTotalEstimado'] as int? ?? 0,
        fechaCreacion: DateTime.tryParse(json['fechaCreacion'] as String? ?? '') ?? DateTime.now(),
        paradas: (json['paradas'] as List<dynamic>?)
                ?.map((p) => ParadaConfirmada.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
