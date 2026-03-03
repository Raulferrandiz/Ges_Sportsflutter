import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/models/reserva.dart';

class ReservaFirestoreService {
  final CollectionReference<Map<String, dynamic>> _ref =
      FirebaseFirestore.instance.collection('reservas');

  Stream<List<Reserva>> getReservas() {
    return _ref.snapshots().map(
          (snap) => snap.docs.map((d) => Reserva.fromDoc(d)).toList(),
        );
  }

  Stream<List<Reserva>> getReservasActivasByUser(String userId) {
    return _ref
        .where('activa', isEqualTo: true)
        .where('userID', isEqualTo: userId)
        .orderBy('startAt')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Reserva.fromDoc(d)).toList());
  }

  Future<String> addReserva(Reserva reserva) async {
    final doc = _ref.doc();
    await doc.set(reserva.toMap());
    return doc.id;
  }

  Future<void> cancelReserva(String reservaId) {
    return _ref.doc(reservaId).update({'activa': false});
  }

  Future<void> deleteReserva(String id) {
    return _ref.doc(id).delete();
  }
}