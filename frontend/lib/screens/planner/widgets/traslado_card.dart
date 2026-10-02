import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

// 🚆 TRASLADO SUGERIDO (OMIO)
class TrasladoCard extends StatelessWidget {
  final Map<String, dynamic> traslado;
  final VoidCallback onBuscarPasajes;

  const TrasladoCard({super.key, required this.traslado, required this.onBuscarPasajes});

  @override
  Widget build(BuildContext context) {
    final costo = traslado['costo_estimado'] as int? ?? 0;
    final duracion = 'Duración: ${traslado['duracion_estimada'] ?? 'N/A'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_subway_outlined, color: AppColors.primario, size: 20),
              const SizedBox(width: 8),
              Text(
                'Traslado: ${traslado['medio_sugerido'] ?? 'Tren / Bus'}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            costo > 0 ? '$duracion • Costo estimado: ~USD $costo' : duracion,
            style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFA6B38),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.confirmation_number_outlined, size: 16),
              label: const Text(
                'Buscar pasajes en Omio',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              onPressed: onBuscarPasajes,
            ),
          ),
        ],
      ),
    );
  }
}
