import 'package:flutter/material.dart';

import '../../models/viaje_guardado.dart';
import '../../services/viajes_storage.dart';
import 'widgets/filtro_chip.dart';
import 'widgets/proximo_viaje_card.dart';
import 'widgets/viaje_card.dart';

class MisViajesScreen extends StatefulWidget {
  const MisViajesScreen({super.key});

  @override
  State<MisViajesScreen> createState() => _MisViajesScreenState();
}

class _MisViajesScreenState extends State<MisViajesScreen> {
  List<ViajeGuardado> _viajes = [];
  bool _cargando = true;
  String _filtroSeleccionado = 'todos'; // todos, pasados, favoritos

  @override
  void initState() {
    super.initState();
    _cargarViajes();
  }

  Future<void> _cargarViajes() async {
    setState(() => _cargando = true);
    final viajes = await ViajesStorage.cargar();
    if (!mounted) return;
    setState(() {
      _viajes = viajes;
      _cargando = false;
    });
  }

  Future<void> _eliminarViaje(String id) async {
    await ViajesStorage.eliminar(id);
    _cargarViajes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B111E),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 4),

            // Contenido expandido
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8), strokeWidth: 3))
                  : _viajes.isEmpty
                      ? _buildVacio()
                      : _buildLista(),
            ),
          ],
        ),
      ),
    );
  }

  // Header unificado para Mis Viajes
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mis Aventuras',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Historial e itinerarios guardados',
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF131D31),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E293B)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bookmark_added_outlined, color: Color(0xFF38BDF8), size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '${_viajes.length} ${_viajes.length == 1 ? "viaje" : "viajes"}',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _cargarViajes,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131D31),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: const Icon(Icons.refresh, color: Colors.white70, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVacio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.luggage_outlined, size: 64, color: Color(0xFF475569)),
          SizedBox(height: 14),
          Text('No tenés viajes guardados todavía', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('Planificá tu primera aventura con IA.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLista() {
    final proximoViaje = _viajes.first;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta Destacada: Próximo Viaje
          const Text('Tu próximo viaje', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          ProximoViajeCard(viaje: proximoViaje),
          const SizedBox(height: 24),

          // Filtros (Todos, Pasados, Favoritos)
          Row(
            children: [
              _buildFilterChip('todos', 'Todos'),
              const SizedBox(width: 10),
              _buildFilterChip('pasados', 'Pasados'),
              const SizedBox(width: 10),
              _buildFilterChip('favoritos', 'Favoritos'),
            ],
          ),
          const SizedBox(height: 20),

          // Lista de viajes
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _viajes.length,
            itemBuilder: (context, index) {
              final viaje = _viajes[index];
              return ViajeCard(
                viaje: viaje,
                onEliminar: () => _eliminarViaje(viaje.id),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label) {
    return FiltroChip(
      label: label,
      seleccionado: _filtroSeleccionado == id,
      onTap: () => setState(() => _filtroSeleccionado = id),
    );
  }
}
