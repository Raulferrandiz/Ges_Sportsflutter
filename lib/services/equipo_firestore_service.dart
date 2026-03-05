import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/models/equipo.dart';

class EquipoFirestoreService {
  final CollectionReference<Map<String, dynamic>> _ref =
      FirebaseFirestore.instance.collection('equipos');

  Stream<List<Equipo>> getEquipos() {
    return _ref.snapshots().map(
          (snap) => snap.docs.map((d) => Equipo.fromDoc(d)).toList(),
        );
  }

  Stream<List<Equipo>> getEquiposActivos() {
    return _ref.where('activo', isEqualTo: true).snapshots().map(
          (snap) => snap.docs.map((d) => Equipo.fromDoc(d)).toList(),
        );
  }

  Future<String> addEquipo(Equipo equipo) async {
    final doc = _ref.doc();
    await doc.set(equipo.toMap());
    return doc.id;
  }

  Future<void> updateEquipo(String id, Equipo equipo) {
    return _ref.doc(id).update(equipo.toMap());
  }

  Future<void> deleteEquipo(String id) {
    return _ref.doc(id).delete();
  }

  Future<void> setActivo(String id, bool activo) {
    return _ref.doc(id).update({'activo': activo});
  }

  Future<void> removeMiembro(String equipoId, String userId) {
  return _ref.doc(equipoId).update({
    'miembros': FieldValue.arrayRemove([userId]),
  });
}
}