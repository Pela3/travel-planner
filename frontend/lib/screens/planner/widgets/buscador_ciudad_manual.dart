import 'package:flutter/material.dart';

/// Campo para elegir cualquier ciudad como próxima parada.
class BuscadorCiudadManual extends StatefulWidget {
  final ValueChanged<String> onBuscar;

  const BuscadorCiudadManual({super.key, required this.onBuscar});

  @override
  State<BuscadorCiudadManual> createState() => _BuscadorCiudadManualState();
}

class _BuscadorCiudadManualState extends State<BuscadorCiudadManual> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enviar(String value) {
    final ciudad = value.trim();
    if (ciudad.isNotEmpty) {
      _controller.clear();
      FocusScope.of(context).unfocus();
      widget.onBuscar(ciudad);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131D31),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_location_alt_outlined, color: Color(0xFF38BDF8), size: 18),
              SizedBox(width: 8),
              Text(
                '¿Querés ir a otro destino?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Escribí cualquier ciudad y la IA armará la parada allí.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B111E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: TextField(
                    controller: _controller,
                    textAlignVertical: TextAlignVertical.center,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Ej: Salzburgo, Viena, Múnich...',
                      hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF64748B), size: 18),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    onSubmitted: _enviar,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: const Color(0xFF0B111E),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _enviar(_controller.text),
                child: const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF0B111E)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
