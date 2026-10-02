import 'package:flutter/material.dart';

/// Paleta de la app. Todas las pantallas usan estos nombres en vez de escribir
/// el color a mano, así un cambio de diseño se hace en un solo lugar.
///
/// Contraste de texto (WCAG, mínimo 4.5:1) medido sobre [fondo] y [superficie]:
/// [texto] 18:1, [textoClaro] 12.7:1, [textoSecundario] 7.4:1, [textoTenue] 5.8:1,
/// [primario] 8.8:1.
abstract final class AppColors {
  /// Fondo de las pantallas.
  static const fondo = Color(0xFF0B111E);

  /// Tarjetas, campos y paneles.
  static const superficie = Color(0xFF131D31);

  /// Bordes y separadores de tarjetas.
  static const borde = Color(0xFF1E293B);

  /// Celeste de la marca: acciones principales, selección y acentos.
  static const primario = Color(0xFF38BDF8);

  /// Celeste oscuro para degradados.
  static const primarioOscuro = Color(0xFF0284C7);

  static const texto = Colors.white;
  static const textoClaro = Color(0xFFCBD5E1);
  static const textoSecundario = Color(0xFF94A3B8);

  /// Etiquetas, ayudas y texto de menor jerarquía. Antes era #64748B, que no
  /// llegaba al contraste mínimo (3.5:1 sobre las tarjetas).
  static const textoTenue = Color(0xFF8090A6);

  static const exito = Color(0xFF10B981);
  static const advertencia = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
}
