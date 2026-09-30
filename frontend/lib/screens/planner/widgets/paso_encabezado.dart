import 'package:flutter/material.dart';

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
            Text('Paso $paso de 3', style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
            Text(etiqueta, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 12),
        Text(titulo, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 6),
        Text(subtitulo, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Botón principal "Siguiente →" de los pasos 1 y 2.
class BotonSiguiente extends StatelessWidget {
  final VoidCallback onPressed;

  const BotonSiguiente({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF38BDF8),
          foregroundColor: const Color(0xFF0B111E),
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
