import 'package:flutter/material.dart';

import '../../../utils/city_images.dart';

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
        Image.network(
          obtenerImagenCiudad(ciudad),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            height: 220,
            color: const Color(0xFF1E293B),
            child: const Center(
              child: Icon(Icons.location_city, color: Color(0xFF38BDF8), size: 48),
            ),
          ),
        ),
        Container(
          height: 220,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, const Color(0xFF0B111E).withValues(alpha: 0.95)],
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
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (onExportarPdf != null)
                IconButton(
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
                  icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF0B111E)),
                  onPressed: onExportarPdf,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
