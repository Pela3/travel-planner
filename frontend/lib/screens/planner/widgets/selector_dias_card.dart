import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Días en esta ciudad + recomendación de la IA, con botones +/-.
class SelectorDiasCard extends StatelessWidget {
  final int diasRecomendados;
  final int diasSeleccionados;
  final int diasRestantes;
  final ValueChanged<int> onChanged;

  /// Costo estimado de esta parada con los días elegidos (0 = desconocido).
  final int costoParada;

  const SelectorDiasCard({
    super.key,
    required this.diasRecomendados,
    required this.diasSeleccionados,
    required this.diasRestantes,
    required this.onChanged,
    this.costoParada = 0,
  });

  bool get _puedeQuedarseTodo => diasRestantes > 1 && diasSeleccionados < diasRestantes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              const Text(
                'Días en esta ciudad:',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 8),
              // Badge con la recomendación de la IA
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primario.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primario.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'Recomendado: $diasRecomendados d',
                  style: const TextStyle(
                    color: AppColors.primario,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seleccionados: $diasSeleccionados de $diasRestantes restantes',
                style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Un día menos',
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.primario),
                    onPressed: diasSeleccionados > 1 ? () => onChanged(diasSeleccionados - 1) : null,
                  ),
                  Text('$diasSeleccionados d', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    tooltip: 'Un día más',
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.primario),
                    onPressed: diasSeleccionados < diasRestantes ? () => onChanged(diasSeleccionados + 1) : null,
                  ),
                ],
              ),
            ],
          ),
          if (costoParada > 0)
            Text(
              'Costo estimado de esta parada: ~USD $costoParada',
              style: const TextStyle(color: AppColors.primario, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          // Estadía completa: asigna todos los días que quedan a esta ciudad.
          if (_puedeQuedarseTodo)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primario,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.home_work_outlined, size: 16),
                label: Text(
                  'Quedarme los $diasRestantes días restantes acá',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                onPressed: () => onChanged(diasRestantes),
              ),
            ),
        ],
      ),
    );
  }
}
