class PresupuestoEstimado {
  final String moneda;
  final int alojamientoDia;
  final int comidaDia;
  final int actividadesDia;
  final int totalDiario;

  PresupuestoEstimado({
    required this.moneda,
    required this.alojamientoDia,
    required this.comidaDia,
    required this.actividadesDia,
    required this.totalDiario,
  });

  Map<String, dynamic> toJson() => {
        'moneda': moneda,
        'alojamiento_dia': alojamientoDia,
        'comida_dia': comidaDia,
        'actividades_dia': actividadesDia,
        'total_diario': totalDiario,
      };

  factory PresupuestoEstimado.fromJson(Map<String, dynamic> json) => PresupuestoEstimado(
        moneda: json['moneda'] as String? ?? 'USD',
        alojamientoDia: json['alojamiento_dia'] as int? ?? 0,
        comidaDia: json['comida_dia'] as int? ?? 0,
        actividadesDia: json['actividades_dia'] as int? ?? 0,
        totalDiario: json['total_diario'] as int? ?? 0,
      );
}
