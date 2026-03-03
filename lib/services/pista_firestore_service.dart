import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/models/pista.dart';

class PistaFirestoreService {
  final CollectionReference<Map<String, dynamic>> _ref =
      FirebaseFirestore.instance.collection('pistas');

  Stream<List<Pista>> getPistas() {
    return _ref.snapshots().map(
          (snap) => snap.docs.map((d) => Pista.fromDoc(d)).toList(),
        );
  }

  Stream<List<Pista>> getPistasActivas() {
    return _ref.where('activa', isEqualTo: true).snapshots().map(
          (snap) => snap.docs.map((d) => Pista.fromDoc(d)).toList(),
        );
  }

  Stream<List<Pista>> getPistasByTipo(String tipo) {
    return _ref
        .where('activa', isEqualTo: true)
        .where('tipo', isEqualTo: tipo)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Pista.fromDoc(d)).toList());
  }

  Future<String> addPista(Pista pista) async {
    final doc = _ref.doc();
    await doc.set(pista.toMap());
    return doc.id;
  }

  Future<void> updatePista(String id, Pista pista) {
    return _ref.doc(id).update(pista.toMap());
  }

  Future<void> deletePista(String id) {
    return _ref.doc(id).delete();
  }

  Future<void> setActiva(String id, bool activa) {
    return _ref.doc(id).update({'activa': activa});
  }
}