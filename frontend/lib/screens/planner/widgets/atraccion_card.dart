import 'package:flutter/material.dart';

/// Atracción sugerida, con botón de reserva si requiere entrada.
class AtraccionCard extends StatelessWidget {
  final String nombre;
  final bool requiereTicket;
  final String consejo;
  final VoidCallback onReservar;

  const AtraccionCard({
    super.key,
    required this.nombre,
    required this.requiereTicket,
    required this.consejo,
    required this.onReservar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: requiereTicket ? const Color(0xFFF59E0B).withValues(alpha: 0.3) : const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: requiereTicket ? const Color(0xFFFEF3C7).withValues(alpha: 0.15) : const Color(0xFFD1FAE5).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: requiereTicket ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      requiereTicket ? Icons.confirmation_number_outlined : Icons.check_circle_outline,
                      size: 13,
                      color: requiereTicket ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      requiereTicket ? 'Entrada Paga' : 'Acceso Gratis',
                      style: TextStyle(
                        color: requiereTicket ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (consejo.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              consejo,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
            ),
          ],
          if (requiereTicket) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: const Color(0xFF0B111E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                icon: const Icon(Icons.shopping_bag_outlined, size: 16),
                label: const Text(
                  'Reservar entrada oficial',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: onReservar,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
