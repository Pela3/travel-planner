import 'package:flutter/material.dart';

import '../../../models/destino_popular.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/city_images.dart';

class DestinoCard extends StatelessWidget {
  final DestinoPopular destino;
  final VoidCallback onPlanificar;

  const DestinoCard({super.key, required this.destino, required this.onPlanificar});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borde),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image(
                  image: proveedorImagen(destino.imagenUrl),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    height: 150,
                    color: AppColors.borde,
                    child: const Center(child: Icon(Icons.photo, color: Colors.white38)),
                  ),
                ),
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, AppColors.superficie.withValues(alpha: 0.95)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.fondo.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primario.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '~USD ${destino.costoEstimado}',
                      style: const TextStyle(color: AppColors.primario, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 16,
                  right: 16,
                  child: Row(
                    children: [
                      Text(
                        destino.ciudad,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• ${destino.pais}',
                        style: const TextStyle(color: AppColors.textoSecundario, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destino.descripcion,
                    style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.borde,
                        foregroundColor: AppColors.primario,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.flight_takeoff, size: 16),
                      label: Text(
                        'Planificar viaje a ${destino.ciudad}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      onPressed: onPlanificar,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
