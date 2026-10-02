import 'package:flutter/material.dart';

import '../../../models/viaje_guardado.dart';
import '../../../services/export_helper.dart';
import '../../../services/pdf_generator.dart';
import '../../../utils/city_images.dart';
import '../../../theme/app_colors.dart';

class ViajeCard extends StatelessWidget {
  final ViajeGuardado viaje;
  final VoidCallback onEliminar;
  final VoidCallback onAbrir;

  const ViajeCard({super.key, required this.viaje, required this.onEliminar, required this.onAbrir});

  @override
  Widget build(BuildContext context) {
    final ciudadPrincipal = viaje.paradas.isNotEmpty ? viaje.paradas.first.ciudad : 'Destino';
    final totalActividades = viaje.paradas.fold(0, (acc, p) => acc + p.atracciones.length + p.cronograma.length);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borde),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onAbrir,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de portada con gradiente
              Stack(
                children: [
                  Image(
                    image: proveedorImagen(obtenerImagenCiudad(ciudadPrincipal, ancho: 600)),
                    height: 130,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 130,
                      color: AppColors.borde,
                      child: const Center(child: Icon(Icons.location_city, color: AppColors.primario, size: 36)),
                    ),
                  ),
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, AppColors.superficie.withValues(alpha: 0.95)],
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
                          style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$totalActividades actividades sugeridas',
                          style: const TextStyle(color: AppColors.primario, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.borde,
                        foregroundColor: AppColors.primario,
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
      ),
    );
  }

  Widget _buildMenu() {
    return PopupMenuButton<String>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.fondo.withValues(alpha: 0.7),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 18),
      ),
      color: AppColors.borde,
      onSelected: (value) {
        if (value == 'pdf') exportarItinerarioPdf(viaje);
        if (value == 'txt') compartirItinerarioTexto(viaje);
        if (value == 'delete') onEliminar();
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'pdf',
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf, color: AppColors.primario, size: 20),
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
            leading: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            title: Text('Eliminar', style: TextStyle(color: AppColors.error, fontSize: 13)),
            dense: true,
          ),
        ),
      ],
    );
  }
}
