import 'package:flutter/material.dart';
import 'package:login/models/incidencia.dart';
import 'package:login/services/incidencia_firestore_service.dart';

class IncidenciaProvider extends ChangeNotifier {
  final IncidenciaFirestoreService _service;
  IncidenciaProvider(this._service);

  Stream<List<Incidencia>> get incidencias => _service.getIncidencias();
  Stream<List<Incidencia>> incidenciasDeCreador(String creadorId) =>
      _service.getIncidenciasByCreador(creadorId);

  Future<String> add(Incidencia incidencia) => _service.addIncidencia(incidencia);
  Future<void> delete(String id) => _service.deleteIncidencia(id);
}