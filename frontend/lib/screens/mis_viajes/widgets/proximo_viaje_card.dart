import 'package:flutter/material.dart';

import '../../../models/viaje_guardado.dart';
import '../../../utils/city_images.dart';

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
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1E293B)),
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
                      decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
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
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: const Color(0xFF0B111E),
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
