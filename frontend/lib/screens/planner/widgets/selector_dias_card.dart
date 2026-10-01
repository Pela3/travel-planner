import 'package:flutter/material.dart';

/// Días en esta ciudad + recomendación de la IA, con botones +/-.
class SelectorDiasCard extends StatelessWidget {
  final int diasRecomendados;
  final int diasSeleccionados;
  final int diasRestantes;
  final ValueChanged<int> onChanged;

  const SelectorDiasCard({
    super.key,
    required this.diasRecomendados,
    required this.diasSeleccionados,
    required this.diasRestantes,
    required this.onChanged,
  });

  bool get _puedeQuedarseTodo => diasRestantes > 1 && diasSeleccionados < diasRestantes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1E293B)),
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
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                ),
                child: Text(
                  'Recomendado: $diasRecomendados d',
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 11,
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
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF38BDF8)),
                    onPressed: diasSeleccionados > 1 ? () => onChanged(diasSeleccionados - 1) : null,
                  ),
                  Text('$diasSeleccionados d', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Color(0xFF38BDF8)),
                    onPressed: diasSeleccionados < diasRestantes ? () => onChanged(diasSeleccionados + 1) : null,
                  ),
                ],
              ),
            ],
          ),
          // Estadía completa: asigna todos los días que quedan a esta ciudad.
          if (_puedeQuedarseTodo)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF38BDF8),
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
