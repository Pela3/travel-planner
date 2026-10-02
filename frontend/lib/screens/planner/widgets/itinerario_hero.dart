import 'package:flutter/material.dart';

import '../../../utils/city_images.dart';
import '../../../theme/app_colors.dart';

/// Header con foto de la ciudad, progreso de días y botón de PDF al terminar.
class ItinerarioHero extends StatelessWidget {
  final String ciudad;
  final int diasUsados;
  final int diasTotales;
  final int costoAcumulado;
  final VoidCallback? onExportarPdf;

  const ItinerarioHero({
    super.key,
    required this.ciudad,
    required this.diasUsados,
    required this.diasTotales,
    required this.costoAcumulado,
    this.onExportarPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image(
          image: proveedorImagen(obtenerImagenCiudad(ciudad)),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 220,
            color: AppColors.borde,
            child: const Center(
              child: Icon(Icons.location_city, color: AppColors.primario, size: 48),
            ),
          ),
        ),
        Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, AppColors.fondo.withValues(alpha: 0.95)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ciudad,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$diasUsados de $diasTotales días usados • ~USD $costoAcumulado',
                      style: const TextStyle(color: AppColors.primario, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (onExportarPdf != null)
                IconButton(
                  tooltip: 'Exportar PDF',
                  style: IconButton.styleFrom(backgroundColor: AppColors.primario),
                  icon: const Icon(Icons.picture_as_pdf, color: AppColors.fondo),
                  onPressed: onExportarPdf,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
