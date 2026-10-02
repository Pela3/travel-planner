import 'package:flutter/material.dart';

/// Hace tocable a una tarjeta o caja con fondo propio: dibuja el efecto de
/// toque por encima (un InkWell común queda tapado por el color de la caja) y
/// la anuncia como botón al lector de pantalla.
class Tocable extends StatelessWidget {
  final VoidCallback? onTap;
  final BorderRadius borderRadius;
  final Widget child;

  /// Para opciones de un grupo (estilo, compañía): el lector dice "seleccionado".
  final bool? seleccionado;

  /// Nombre para el lector de pantalla cuando el contenido es solo un ícono.
  final String? etiqueta;

  const Tocable({
    super.key,
    required this.onTap,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.seleccionado,
    this.etiqueta,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: seleccionado,
      label: etiqueta,
      excludeSemantics: etiqueta != null,
      child: Stack(
        children: [
          child,
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, borderRadius: borderRadius),
            ),
          ),
        ],
      ),
    );
  }
}
