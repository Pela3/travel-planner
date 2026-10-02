import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/tocable.dart';

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

  // El asistente tiene 3 pasos; el 4 es la pantalla de carga y el 5 el itinerario.
  String get _subtitulo => switch (pasoActual) {
        5 => 'Plan generado por IA',
        4 => 'Generando tu viaje...',
        _ => 'Paso $pasoActual de 3',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (pasoActual > 1 && pasoActual < 4) ...[
                  Tocable(
                    onTap: onVolver,
                    etiqueta: 'Volver al paso anterior',
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.superficie,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borde),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pasoActual == 5 ? 'Tu Itinerario' : 'Diseñador de Viajes',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _subtitulo,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (pasoActual == 5)
            IconButton(
              // "Refrescar" sugería recargar la parada; en realidad empieza otro viaje.
              tooltip: 'Empezar un viaje nuevo',
              icon: const Icon(Icons.restart_alt, color: Colors.white70),
              onPressed: onReiniciar,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.superficie,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borde),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.primario, size: 13),
                  SizedBox(width: 5),
                  Text(
                    'IA Activa',
                    style: TextStyle(
                      color: AppColors.primario,
                      fontSize: 12,
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
