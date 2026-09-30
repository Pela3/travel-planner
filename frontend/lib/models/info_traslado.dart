class InfoTraslado {
  final String medioSugerido;
  final String duracionEstimada;
  final String consejoLogistica;

  InfoTraslado({
    required this.medioSugerido,
    required this.duracionEstimada,
    required this.consejoLogistica,
  });

  Map<String, dynamic> toJson() => {
        'medio_sugerido': medioSugerido,
        'duracion_estimada': duracionEstimada,
        'consejo_logistica': consejoLogistica,
      };

  factory InfoTraslado.fromJson(Map<String, dynamic> json) => InfoTraslado(
        medioSugerido: json['medio_sugerido'] as String? ?? 'Transporte',
        duracionEstimada: json['duracion_estimada'] as String? ?? 'N/A',
        consejoLogistica: json['consejo_logistica'] as String? ?? '',
      );
}
