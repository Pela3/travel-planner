import 'package:flutter/material.dart';

import '../widgets/paso_encabezado.dart';

// PASO 2: Tipo de Viaje
class PasoEstilo extends StatelessWidget {
  final String estiloSeleccionado;
  final ValueChanged<String> onEstiloChanged;
  final VoidCallback onSiguiente;

  const PasoEstilo({
    super.key,
    required this.estiloSeleccionado,
    required this.onEstiloChanged,
    required this.onSiguiente,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PasoEncabezado(
            paso: 2,
            etiqueta: 'Estilo',
            titulo: '¿Qué tipo de viaje querés?',
            subtitulo: 'Seleccioná el ritmo que mejor se adapta a vos.',
          ),

          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildCardEstilo('cultural', 'Cultura', Icons.museum_outlined),
                _buildCardEstilo('gastronomico', 'Gastronomía', Icons.restaurant_outlined),
                _buildCardEstilo('playa', 'Playa', Icons.beach_access_outlined),
                _buildCardEstilo('aventura', 'Aventura', Icons.terrain_outlined),
                _buildCardEstilo('economico', 'Económico', Icons.savings_outlined),
                _buildCardEstilo('relax', 'Relax', Icons.spa_outlined),
              ],
            ),
          ),

          BotonSiguiente(onPressed: onSiguiente),
        ],
      ),
    );
  }

  Widget _buildCardEstilo(String id, String label, IconData icon) {
    final bool sel = estiloSeleccionado == id;
    return GestureDetector(
      onTap: () => onEstiloChanged(id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF1E293B) : const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: sel ? const Color(0xFF38BDF8) : const Color(0xFF1E293B),
            width: sel ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: sel ? const Color(0xFF38BDF8) : const Color(0xFF64748B), size: 24),
            Text(
              label,
              style: TextStyle(
                color: sel ? Colors.white : Colors.white70,
                fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
