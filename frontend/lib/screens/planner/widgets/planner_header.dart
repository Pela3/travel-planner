import 'package:flutter/material.dart';

/// Barra superior del planificador: volver, título del paso e indicador de IA.
class PlannerHeader extends StatelessWidget {
  final int pasoActual;
  final VoidCallback onVolver;
  final VoidCallback onReiniciar;

  const PlannerHeader({
    super.key,
    required this.pasoActual,
    required this.onVolver,
    required this.onReiniciar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (pasoActual > 1 && pasoActual < 4) ...[
                GestureDetector(
                  onTap: onVolver,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131D31),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF1E293B)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                  ),
                ),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pasoActual == 5 ? 'Tu Itinerario' : 'Diseñador de Viajes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pasoActual == 5 ? 'Plan generado por IA' : 'Paso $pasoActual de 4',
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          if (pasoActual == 5)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: onReiniciar,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF131D31),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1E293B)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 13),
                  SizedBox(width: 5),
                  Text(
                    'IA Activa',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
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
