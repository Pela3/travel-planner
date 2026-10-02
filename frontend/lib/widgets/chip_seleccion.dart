import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Chip para elegir una opción de un grupo (categorías del inicio, filtros de
/// Mis Viajes). Mide 48 de alto como pide Android para tocar cómodo, muestra
/// el efecto de toque y le dice al lector de pantalla si está seleccionado.
class ChipSeleccion extends StatelessWidget {
  final String label;
  final IconData? icono;
  final bool seleccionado;
  final VoidCallback onTap;

  const ChipSeleccion({
    super.key,
    required this.label,
    required this.seleccionado,
    required this.onTap,
    this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final color = seleccionado ? AppColors.fondo : AppColors.textoSecundario;
    return Semantics(
      button: true,
      selected: seleccionado,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: seleccionado ? AppColors.primario : AppColors.superficie,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: seleccionado ? AppColors.primario : AppColors.borde),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icono != null) ...[
                  Icon(icono, size: 18, color: color),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: seleccionado ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
