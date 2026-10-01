import 'package:flutter/material.dart';

import '../../models/viaje_guardado.dart';

/// Pide confirmación antes de borrar un viaje. Devuelve true si se confirmó.
Future<bool> confirmarEliminarViaje(BuildContext context, ViajeGuardado viaje) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color(0xFF131D31),
      title: const Text('¿Eliminar viaje?', style: TextStyle(color: Colors.white)),
      content: Text(
        'Se va a borrar "${viaje.titulo}". Esta acción no se puede deshacer.',
        style: const TextStyle(color: Color(0xFF94A3B8)),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Eliminar', style: TextStyle(color: Color(0xFFEF4444))),
        ),
      ],
    ),
  );
  return confirmado == true;
}
