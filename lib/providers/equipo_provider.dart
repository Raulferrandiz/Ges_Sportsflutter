import 'package:flutter/material.dart';
import 'package:login/models/equipo.dart';
import 'package:login/services/equipo_firestore_service.dart';

class EquipoProvider extends ChangeNotifier {
  final EquipoFirestoreService _service;
  EquipoProvider(this._service);

  Stream<List<Equipo>> get equipos => _service.getEquipos();
  Stream<List<Equipo>> get equiposActivos => _service.getEquiposActivos();

  Future<String> add(Equipo equipo) => _service.addEquipo(equipo);
  Future<void> update(String id, Equipo equipo) => _service.updateEquipo(id, equipo);
  Future<void> delete(String id) => _service.deleteEquipo(id);
  Future<void> setActivo(String id, bool activo) => _service.setActivo(id, activo);
  Future<void> removeMiembro(String equipoId, String userId) => _service.removeMiembro(equipoId, userId);
}