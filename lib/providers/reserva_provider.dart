import 'package:flutter/material.dart';
import 'package:login/models/reserva.dart';
import 'package:login/services/reserva_firestore_service.dart';

class ReservaProvider extends ChangeNotifier {
  final ReservaFirestoreService _service;
  ReservaProvider(this._service);

  Stream<List<Reserva>> get reservas => _service.getReservas();
  Stream<List<Reserva>> reservasActivasDeUsuario(String userId) =>
      _service.getReservasActivasByUser(userId);

  Future<String> add(Reserva reserva) => _service.addReserva(reserva);
  Future<void> update(String id, Reserva reserva) => _service.updateReserva(id, reserva);
  Future<void> cancel(String reservaId) => _service.cancelReserva(reservaId);
  Future<void> delete(String id) => _service.deleteReserva(id);
}