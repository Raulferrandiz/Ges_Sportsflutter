import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/models/incidencia.dart';

class IncidenciaFirestoreService {
  final CollectionReference<Map<String, dynamic>> _ref =
      FirebaseFirestore.instance.collection('incidencias');

  Stream<List<Incidencia>> getIncidencias() {
    return _ref
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Incidencia.fromDoc(d)).toList());
  }

  Stream<List<Incidencia>> getIncidenciasByCreador(String creadorId) {
    return _ref
        .where('creadorID', isEqualTo: creadorId)
        .orderBy('fecha', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Incidencia.fromDoc(d)).toList());
  }

  Future<String> addIncidencia(Incidencia incidencia) async {
    final doc = _ref.doc();
    await doc.set(incidencia.toMap());
    return doc.id;
  }

  Future<void> deleteIncidencia(String id) {
    return _ref.doc(id).delete();
  }
}