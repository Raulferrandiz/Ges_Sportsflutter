import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedUsersToFirestore() async {
  final firestore = FirebaseFirestore.instance;

  // Leer JSON local
  final jsonString = await rootBundle.loadString('assets/data/users.json');

  final List<dynamic> users = json.decode(jsonString);

  // Subir usuarios
  for (final user in users) {
    final String id = user['id'];

    await firestore.collection('users').doc(id).set({
      'nombre': user['nombre'],
      'rol': user['rol'],
      'imagen': user['imagen'],
      'colorfondo': user['colorfondo'],
      'activo': user['activo'],
    });
  }

  print('Usuarios cargados correctamente en Firestore');
}
