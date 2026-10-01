import 'package:flutter/material.dart';

// PASO 4: Checklist animado de IA
class PasoGenerando extends StatelessWidget {
  final int loadingStep;

  /// Si se indica, reemplaza el checklist (p. ej. al generar días extra).
  final String? mensaje;

  const PasoGenerando({super.key, required this.loadingStep, this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.flight_takeoff, color: Color(0xFF38BDF8), size: 52),
            const SizedBox(height: 20),
            const Text(
              'La IA está armando tu viaje...',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text('Esto puede tardar unos segundos', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
            const SizedBox(height: 36),

            if (mensaje != null)
              Text(
                mensaje!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
              )
            else ...[
              _buildCheckItem(1, 'Analizando tu destino'),
              _buildCheckItem(2, 'Buscando lugares imperdibles'),
              _buildCheckItem(3, 'Calculando rutas y traslados'),
              _buildCheckItem(4, 'Personalizando itinerario y presupuesto'),
            ],

            const SizedBox(height: 30),
            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF38BDF8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(int stepNumber, String label) {
    final bool completed = loadingStep >= stepNumber;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFF131D31) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? const Color(0xFF38BDF8) : const Color(0xFF475569),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: completed ? Colors.white : const Color(0xFF64748B),
              fontWeight: completed ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
