import 'package:flutter/material.dart';

/// Clima y vestimenta sugerida para la parada.
class ClimaCard extends StatelessWidget {
  final Map<String, dynamic> clima;

  const ClimaCard({super.key, required this.clima});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: Color(0xFF38BDF8), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Clima: ${clima['clima_esperado'] ?? 'Templado'} (${clima['temperatura_prom'] ?? ''})',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ropa: ${(clima['ropa_recomendada'] as List<dynamic>?)?.join(", ") ?? "Cómoda"}',
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
