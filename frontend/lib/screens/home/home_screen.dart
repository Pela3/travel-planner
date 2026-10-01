import 'package:flutter/material.dart';

import '../../data/destinos_populares.dart';
import 'widgets/categoria_chip.dart';
import 'widgets/destino_card.dart';

class HomeScreen extends StatefulWidget {
  /// Recibe la ciudad elegida y el estilo de viaje que corresponde a su categoría.
  final void Function(String ciudad, String estilo)? onSeleccionarDestino;
  const HomeScreen({super.key, this.onSeleccionarDestino});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _categoriaSeleccionada = 'todos';

  @override
  Widget build(BuildContext context) {
    final destinosFiltrados = _categoriaSeleccionada == 'todos'
        ? destinosPopulares
        : destinosPopulares.where((d) => d.categoria == _categoriaSeleccionada).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B111E),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER PREMIUM LIMPIO (Sin campanita)
              _buildHeader(),
              const SizedBox(height: 24),

              // BANNER CTA: Planificar nuevo viaje
              _buildBannerCta(),
              const SizedBox(height: 28),

              // 2. CATEGORÍAS INTERACTIVAS
              const Text(
                'Explorar por estilo',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCategoriaChip('todos', '🌟 Todos'),
                    // Solo las categorías que tienen destinos: antes "Naturaleza"
                    // aparecía y no mostraba nada.
                    for (final MapEntry(key: id, value: cat) in categoriasDestino.entries)
                      if (destinosPopulares.any((d) => d.categoria == id)) _buildCategoriaChip(id, cat.etiqueta),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 3. DESTINOS POPULARES CON DESCRIPCIÓN Y PRESELECCIÓN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _categoriaSeleccionada == 'todos'
                        ? 'Destinos destacados'
                        : 'Top para ${_categoriaSeleccionada.toUpperCase()}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    '${destinosFiltrados.length} sugeridos',
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: destinosFiltrados.length,
                itemBuilder: (context, index) {
                  final destino = destinosFiltrados[index];
                  return DestinoCard(
                    destino: destino,
                    onPlanificar: () => widget.onSeleccionarDestino?.call(
                      destino.ciudad,
                      categoriasDestino[destino.categoria]?.estilo ?? 'cultural',
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaChip(String id, String label) {
    return CategoriaChip(
      label: label,
      seleccionado: _categoriaSeleccionada == id,
      onTap: () => setState(() => _categoriaSeleccionada = id),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
            gradient: const LinearGradient(
              colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(Icons.person, color: Colors.white, size: 24),
          ),
        ),
        const SizedBox(width: 14),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¡Hola, viajero! 👋',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 2),
            Text(
              '¿Cuál será tu próxima aventura?',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBannerCta() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: Color(0xFF38BDF8), size: 14),
                SizedBox(width: 6),
                Text('IA Itinerary Builder', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Diseñá tu viaje perfecto en segundos',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Rutas inteligentes, cronogramas diarios y boletos oficiales.',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
