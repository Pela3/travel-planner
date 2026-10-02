import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

/// Encabezado común de los pasos del asistente ("Paso N de 3" + título).
class PasoEncabezado extends StatelessWidget {
  final int paso;
  final String etiqueta;
  final String titulo;
  final String subtitulo;

  const PasoEncabezado({
    super.key,
    required this.paso,
    required this.etiqueta,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Paso $paso de 3', style: const TextStyle(color: AppColors.primario, fontWeight: FontWeight.bold, fontSize: 12)),
            Text(etiqueta, style: const TextStyle(color: AppColors.textoTenue, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Text(titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        Text(subtitulo, style: const TextStyle(color: AppColors.textoSecundario, fontSize: 13)),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Botón principal "Siguiente →" de los pasos 1 y 2.
class BotonSiguiente extends StatelessWidget {
  /// null = desactivado (falta elegir algo).
  final VoidCallback? onPressed;

  const BotonSiguiente({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primario,
          foregroundColor: AppColors.fondo,
          disabledBackgroundColor: AppColors.borde,
          disabledForegroundColor: AppColors.textoTenue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onPressed,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Siguiente', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Aviso de por qué el botón está desactivado.
class AvisoElegirOpcion extends StatelessWidget {
  const AvisoElegirOpcion({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Center(
        child: Text(
          'Elegí una opción para seguir',
          style: TextStyle(color: AppColors.textoTenue, fontSize: 13),
        ),
      ),
    );
  }
}
