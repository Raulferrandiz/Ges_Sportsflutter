import 'package:flutter/material.dart';
import 'package:login/widgets/perfil_card.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  final List<Map<String, dynamic>> users = const [
    {"nombre": "Ana", "rol": "Desarrolladora", "activo": true},
    {"nombre": "Luis", "rol": "Diseñador", "activo": true},
    {"nombre": "Marta", "rol": "QA", "activo": false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final myuser = users[index];

          return PerfilCard(
            nombre: myuser["nombre"] as String,
            rol: myuser["rol"] as String,
            activo: myuser["activo"] as bool,
            onToggleActivo: () {},
          );
        },
      ),
    );
  }
}