import 'package:flutter/material.dart';

import '../../../models/viaje_guardado.dart';
import '../../../services/export_helper.dart';
import '../../../services/pdf_generator.dart';
import '../../../utils/city_images.dart';

class ViajeCard extends StatelessWidget {
  final ViajeGuardado viaje;
  final VoidCallback onEliminar;

  const ViajeCard({super.key, required this.viaje, required this.onEliminar});

  @override
  Widget build(BuildContext context) {
    final ciudadPrincipal = viaje.paradas.isNotEmpty ? viaje.paradas.first.ciudad : 'Destino';
    final totalActividades = viaje.paradas.fold(0, (acc, p) => acc + p.atracciones.length + p.cronograma.length);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de portada con gradiente
            Stack(
              children: [
                Image.network(
                  obtenerImagenCiudad(ciudadPrincipal, ancho: 600),
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 130,
                    color: const Color(0xFF1E293B),
                    child: const Center(child: Icon(Icons.location_city, color: Color(0xFF38BDF8), size: 36)),
                  ),
                ),
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, const Color(0xFF131D31).withValues(alpha: 0.95)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: _buildMenu(),
                ),
                Positioned(
                  bottom: 12,
                  left: 16,
                  right: 16,
                  child: Text(
                    viaje.titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            // Datos del viaje
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${viaje.diasTotales} días • ${viaje.fechaInicio.day}/${viaje.fechaInicio.month}',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalActividades actividades sugeridas',
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: const Color(0xFF38BDF8),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: () => exportarItinerarioPdf(viaje),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF0B111E).withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
      ),
      color: const Color(0xFF1E293B),
      onSelected: (value) {
        if (value == 'pdf') exportarItinerarioPdf(viaje);
        if (value == 'txt') compartirItinerarioTexto(viaje);
        if (value == 'delete') onEliminar();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'pdf',
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Color(0xFF38BDF8), size: 20),
            title: Text('Exportar PDF', style: TextStyle(color: Colors.white, fontSize: 13)),
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: 'txt',
          child: ListTile(
            leading: Icon(Icons.share, color: Colors.white70, size: 20),
            title: Text('Compartir TXT', style: TextStyle(color: Colors.white, fontSize: 13)),
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
            title: Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13)),
            dense: true,
          ),
        ),
      ],
    );
  }
}
