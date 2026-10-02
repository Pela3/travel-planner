import 'package:flutter/material.dart';

import '../widgets/paso_encabezado.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/tocable.dart';

// PASO 3: ¿Con quién viajás?
class PasoCompania extends StatelessWidget {
  /// null hasta que el usuario elige.
  final String? companiaSeleccionada;
  final ValueChanged<String> onCompaniaChanged;
  final VoidCallback onGenerar;

  const PasoCompania({
    super.key,
    required this.companiaSeleccionada,
    required this.onCompaniaChanged,
    required this.onGenerar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Con scroll: en pantallas bajas o con letra grande no entraba.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PasoEncabezado(
                    paso: 3,
                    etiqueta: 'Compañía',
                    titulo: '¿Con quién viajás?',
                    subtitulo: 'Personalizaremos los alojamientos y ritmos.',
                  ),
                  _buildTileCompania('solo', 'Solo', 'Viví la experiencia a tu manera', Icons.person_outline),
                  _buildTileCompania('pareja', 'Pareja', 'Compartí momentos únicos', Icons.favorite_border),
                  _buildTileCompania('familia', 'Familia', 'Creá recuerdos para siempre', Icons.family_restroom_outlined),
                  _buildTileCompania('amigos', 'Amigos', 'La mejor compañía siempre', Icons.group_outlined),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (companiaSeleccionada == null) const AvisoElegirOpcion(),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primario,
                foregroundColor: AppColors.fondo,
                disabledBackgroundColor: AppColors.borde,
                disabledForegroundColor: AppColors.textoTenue,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: companiaSeleccionada == null ? null : onGenerar,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, size: 18),
                  SizedBox(width: 8),
                  Text('Generar mi viaje', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTileCompania(String id, String titulo, String subtitulo, IconData icon) {
    final bool sel = companiaSeleccionada == id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Tocable(
        onTap: () => onCompaniaChanged(id),
        seleccionado: sel,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: sel ? AppColors.borde : AppColors.superficie,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: sel ? AppColors.primario : AppColors.borde,
              width: sel ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: sel ? AppColors.primario : AppColors.textoTenue, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: TextStyle(color: Colors.white, fontWeight: sel ? FontWeight.bold : FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(subtitulo, style: const TextStyle(color: AppColors.textoSecundario, fontSize: 12)),
                  ],
                ),
              ),
              if (sel) const Icon(Icons.check_circle, color: AppColors.primario, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
