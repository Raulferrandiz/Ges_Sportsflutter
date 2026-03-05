import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedUsersToFirestore() async {
  final firestore = FirebaseFirestore.instance;

  final jsonString = await rootBundle.loadString('assets/data/users.json');
  final List<dynamic> users = json.decode(jsonString);

  for (final user in users) {
    final String id = user['id'];

    await firestore.collection('users').doc(id).set({
      'nombre': user['nombre'],
      'rol': user['rol'],
      'email': user['email'],
      'activo': user['activo'],
    });
  }

  print('Usuarios cargados correctamente en Firestore');
}