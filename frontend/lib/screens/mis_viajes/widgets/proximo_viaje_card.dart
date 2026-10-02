import 'package:flutter/material.dart';

import '../../../models/viaje_guardado.dart';
import '../../../utils/city_images.dart';
import '../../../theme/app_colors.dart';

class ProximoViajeCard extends StatelessWidget {
  final ViajeGuardado viaje;
  final VoidCallback onAbrir;

  const ProximoViajeCard({super.key, required this.viaje, required this.onAbrir});

  @override
  Widget build(BuildContext context) {
    final ciudadPrincipal = viaje.paradas.isNotEmpty ? viaje.paradas.first.ciudad : 'Destino';
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: Image.network(
              obtenerImagenCiudad(ciudadPrincipal, ancho: 600),
              height: 140,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppColors.exito, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        viaje.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Salida: ${viaje.fechaInicio.day}/${viaje.fechaInicio.month} • ${viaje.diasTotales} días • ~USD ${viaje.costoTotalEstimado}',
                  style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primario,
                      foregroundColor: AppColors.fondo,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('Ver itinerario completo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    onPressed: onAbrir,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
