import 'package:flutter/material.dart';
import 'package:login/models/pista.dart';
import 'package:login/services/pista_firestore_service.dart';

class PistaProvider extends ChangeNotifier {
  final PistaFirestoreService _service;
  PistaProvider(this._service);

  Stream<List<Pista>> get pistas => _service.getPistas();
  Stream<List<Pista>> get pistasActivas => _service.getPistasActivas();

  Stream<List<Pista>> pistasPorTipo(String tipo) => _service.getPistasByTipo(tipo);

  Future<String> add(Pista pista) => _service.addPista(pista);
  Future<void> update(String id, Pista pista) => _service.updatePista(id, pista);
  Future<void> delete(String id) => _service.deletePista(id);

  Future<void> setActiva(String id, bool activa) => _service.setActiva(id, activa);
}