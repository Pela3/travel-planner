import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/validaciones.dart';

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
    final error = validarNombreLugar(ciudad, campo: 'La ciudad');
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
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
        color: AppColors.superficie,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borde),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.edit_location_alt_outlined, color: AppColors.primario, size: 18),
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
            style: TextStyle(color: AppColors.textoSecundario, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.fondo,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borde),
                  ),
                  child: TextField(
                    controller: _controller,
                    textAlignVertical: TextAlignVertical.center,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Ej: Salzburgo, Viena, Múnich...',
                      hintStyle: TextStyle(color: AppColors.textoTenue, fontSize: 13),
                      prefixIcon: Icon(Icons.search, color: AppColors.textoTenue, size: 18),
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
                  backgroundColor: AppColors.primario,
                  foregroundColor: AppColors.fondo,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _enviar(_controller.text),
                child: const Icon(Icons.arrow_forward, size: 18, color: AppColors.fondo),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
