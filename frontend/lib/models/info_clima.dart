class InfoClima {
  final String climaEsperado;
  final String temperaturaProm;
  final List<String> ropaRecomendada;

  InfoClima({
    required this.climaEsperado,
    required this.temperaturaProm,
    required this.ropaRecomendada,
  });

  Map<String, dynamic> toJson() => {
        'clima_esperado': climaEsperado,
        'temperatura_prom': temperaturaProm,
        'ropa_recomendada': ropaRecomendada,
      };

  factory InfoClima.fromJson(Map<String, dynamic> json) => InfoClima(
        climaEsperado: json['clima_esperado'] as String? ?? 'Templado',
        temperaturaProm: json['temperatura_prom'] as String? ?? 'N/A',
        ropaRecomendada: (json['ropa_recomendada'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}
