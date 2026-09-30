class ActividadDia {
  final int dia;
  final String? horarioManana;
  final String manana;
  final String? horarioTarde;
  final String tarde;
  final String? horarioNoche;
  final String noche;

  ActividadDia({
    required this.dia,
    this.horarioManana,
    required this.manana,
    this.horarioTarde,
    required this.tarde,
    this.horarioNoche,
    required this.noche,
  });

  factory ActividadDia.fromJson(Map<String, dynamic> json) {
    return ActividadDia(
      dia: json['dia'] ?? 1,
      horarioManana: json['horario_manana'],
      manana: json['manana'] ?? '',
      horarioTarde: json['horario_tarde'],
      tarde: json['tarde'] ?? '',
      horarioNoche: json['horario_noche'],
      noche: json['noche'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dia': dia,
      'horario_manana': horarioManana,
      'manana': manana,
      'horario_tarde': horarioTarde,
      'tarde': tarde,
      'horario_noche': horarioNoche,
      'noche': noche,
    };
  }
}
