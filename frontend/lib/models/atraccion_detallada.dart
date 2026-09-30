class AtraccionDetallada {
  final String nombre;
  final bool requiereTicket;
  final String consejoReserva;

  AtraccionDetallada({
    required this.nombre,
    required this.requiereTicket,
    required this.consejoReserva,
  });

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'requiere_ticket': requiereTicket,
        'consejo_reserva': consejoReserva,
      };

  factory AtraccionDetallada.fromJson(Map<String, dynamic> json) => AtraccionDetallada(
        nombre: json['nombre'] as String? ?? '',
        requiereTicket: json['requiere_ticket'] as bool? ?? false,
        consejoReserva: json['consejo_reserva'] as String? ?? '',
      );
}
