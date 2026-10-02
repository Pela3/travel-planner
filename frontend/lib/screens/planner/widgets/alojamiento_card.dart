import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

// 🏨 ALOJAMIENTO SUGERIDO (BOOKING)
class AlojamientoCard extends StatelessWidget {
  final String ciudad;
  final VoidCallback onVerBooking;

  const AlojamientoCard({super.key, required this.ciudad, required this.onVerBooking});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF003580).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF003580).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF003580),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hotel_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alojamiento sugerido',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hoteles y deptos en $ciudad',
                    style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF003580),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onVerBooking,
            child: const Text('Ver Booking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
