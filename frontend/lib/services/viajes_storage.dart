import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/viaje_guardado.dart';

/// Dónde se guardan los viajes. Devuelve siempre del más nuevo al más viejo.
abstract class RepositorioViajes {
  Future<List<ViajeGuardado>> cargar();
  Future<void> guardar(ViajeGuardado viaje);
  Future<void> eliminar(String id);
}

/// Viajes en el teléfono (SharedPreferences). Es lo que había antes del login:
/// se usa en los tests y como origen de la migración a la nube.
class RepositorioLocal implements RepositorioViajes {
  static const _key = 'mis_viajes';

  @override
  Future<List<ViajeGuardado>> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    return rawList.map((str) => ViajeGuardado.fromJson(jsonDecode(str))).toList().reversed.toList();
  }

  @override
  Future<void> guardar(ViajeGuardado viaje) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    data.add(jsonEncode(viaje.toJson()));
    await prefs.setStringList(_key, data);
  }

  @override
  Future<void> eliminar(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_key) ?? [];
    final updated = rawList.where((str) {
      final map = jsonDecode(str);
      return map['id'] != id;
    }).toList();
    await prefs.setStringList(_key, updated);
  }

  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

/// Viajes del usuario en Firestore: usuarios/{uid}/viajes/{id}.
///
/// El viaje se guarda como JSON en un string porque Firestore no admite listas
/// dentro de listas. Firestore cachea en el teléfono, así que Mis Viajes, el
/// detalle y el PDF siguen funcionando sin internet.
class RepositorioFirestore implements RepositorioViajes {
  final CollectionReference<Map<String, dynamic>> _coleccion;

  RepositorioFirestore(String uid)
      : _coleccion = FirebaseFirestore.instance.collection('usuarios').doc(uid).collection('viajes');

  @override
  Future<List<ViajeGuardado>> cargar() async {
    final consulta = _coleccion.orderBy('creado', descending: true);
    QuerySnapshot<Map<String, dynamic>> snap;
    try {
      snap = await consulta.get();
    } on FirebaseException {
      // Si el servidor falla, lo que haya en el teléfono.
      snap = await consulta.get(const GetOptions(source: Source.cache));
    }
    return snap.docs.map((d) => ViajeGuardado.fromJson(jsonDecode(d.data()['json'] as String))).toList();
  }

  /// Se completa cuando el servidor confirma. Sin conexión la escritura queda
  /// en cola (y ya se ve en [cargar]), por eso [guardar] no la espera.
  Future<void> subir(ViajeGuardado viaje) => _coleccion.doc(viaje.id).set({
        'json': jsonEncode(viaje.toJson()),
        'creado': Timestamp.fromDate(viaje.fechaCreacion),
      });

  @override
  Future<void> guardar(ViajeGuardado viaje) async {
    subir(viaje).catchError((Object e) => debugPrint('No se pudo guardar el viaje ${viaje.id}: $e'));
  }

  @override
  Future<void> eliminar(String id) async {
    _coleccion.doc(id).delete().catchError((Object e) => debugPrint('No se pudo eliminar el viaje $id: $e'));
  }

  /// Para "Eliminar cuenta": borra todos los viajes del usuario.
  Future<void> borrarTodo() async {
    final snap = await _coleccion.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in snap.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }
}

/// Punto de acceso a los viajes guardados que usan las pantallas.
class ViajesStorage {
  static RepositorioViajes repositorio = RepositorioLocal();

  /// Cambia cada vez que se guarda o elimina un viaje. Mis Viajes vive en un
  /// IndexedStack (no se reconstruye al cambiar de pestaña) y lo escucha para
  /// recargar la lista.
  static final cambios = ValueNotifier<int>(0);

  static Future<List<ViajeGuardado>> cargar() => repositorio.cargar();

  static Future<void> guardar(ViajeGuardado viaje) async {
    await repositorio.guardar(viaje);
    cambios.value++;
  }

  static Future<void> eliminar(String id) async {
    await repositorio.eliminar(id);
    cambios.value++;
  }

  /// Pasa a guardar en la cuenta del usuario y sube los viajes que había en
  /// el teléfono de antes del login. Los locales se borran recién cuando el
  /// servidor confirma; si falla, se reintenta en el próximo inicio de sesión
  /// (el id del viaje es el id del documento, no se duplican).
  static Future<void> usarCuenta(String uid) async {
    final nube = RepositorioFirestore(uid);
    final local = RepositorioLocal();
    final pendientes = await local.cargar();
    repositorio = nube;
    if (pendientes.isNotEmpty) {
      Future.wait(pendientes.map(nube.subir))
          .then((_) => local.borrarTodo())
          .catchError((Object e) => debugPrint('Migración de viajes pendiente: $e'));
    }
    cambios.value++;
  }
}
