import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/models/user.dart';

class UserFirestoreService {
  final _ref = FirebaseFirestore.instance.collection("users");

  Future<String> addUser(User user) async {
    final doc = _ref.doc();
    await doc.set(user.toMap());
    return doc.id;
  }

  /*Future<void> addUser(User user) async {
    //Genera el id al documento
    final doc = _ref.doc();

    //Añadimos ese id al modelo
    final userWithId = user.copyWith(id: doc.id);

    final id = FirebaseFirestore.instance.collection('users').doc().id;

    await doc.set(userWithId.toMap());
  }*/

  Stream<List<User>> getUsers() {
    return _ref.snapshots().map(
      (snap) =>
          snap.docs.map((doc) => User.fromDoc(doc.id, doc.data())).toList(),
    );
  }

  Future<void> updateUser(String id, User user) {
    return _ref.doc(id).update(user.toMap());
  }

  Future<void> deleteUser(String id) {
    return _ref.doc(id).delete();
  }

  Stream<List<User>> getUsersByRol(String rol) {
  return _ref
      .where('rol', isEqualTo: rol)
      .snapshots()
      .map(
        (snap) => snap.docs.map((doc) => User.fromDoc(doc.id, doc.data())).toList(),
      );
}
}
