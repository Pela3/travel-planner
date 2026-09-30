import 'package:flutter/material.dart';

class FiltroChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const FiltroChip({
    super.key,
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool sel = seleccionado;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF38BDF8) : const Color(0xFF131D31),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? const Color(0xFF38BDF8) : const Color(0xFF1E293B)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel ? const Color(0xFF0B111E) : const Color(0xFF94A3B8),
            fontWeight: sel ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
