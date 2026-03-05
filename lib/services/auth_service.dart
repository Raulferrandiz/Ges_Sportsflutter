import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = cred.user!.uid;
    final normalizedEmail = email.trim().toLowerCase();

    await _db.collection('users').doc(uid).set(
      {
        'email': normalizedEmail,
        'rol': 'jugador',
        'activo': true,
      },
      SetOptions(merge: true),
    );

    return cred;
  }

  Future<void> signOut() => _auth.signOut();
}
