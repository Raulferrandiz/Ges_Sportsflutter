import 'package:flutter/material.dart';
import 'package:login/widgets/perfil_card.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});
  static const Color azul = Color(0xFF93d2e7);
  static const Color turquesa = Color(0xFFa5e8cb);

  final List<Map<String, dynamic>> users = const [
    {
      "nombre": "Ana",
      "rol": "Desarrolladora",
      "imagen": "imagen",
      "color": Colors.amber,
    },
    {"nombre": "Luis", "rol": "Diseñador", "imagen": "imagen", "color": azul},
    {"nombre": "Marta", "rol": "QA", "imagen": "imagen", "color": turquesa},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final myuser = users[index];
          return PerfilCard(
            nombre: myuser["nombre"],
            rol: myuser["rol"],
            imagen: myuser["imagen"],
            colorfondo: myuser["color"],
            activo: myuser["activo"] as bool,
            onToggleActivo: () {},
          );
        },
      ),
    );
  }

  /*@override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        PerfilCard(
          nombre: "Jorge",
          rol: "Desarrollador",
          imagen: "imagen",
          colorfondo: Colors.amber,
        ),
        PerfilCard(
          nombre: "Lolo",
          rol: "Desarrollador",
          imagen: "imagen",
          colorfondo: azul,
        ),
        PerfilCard(
          nombre: "Pepa",
          rol: "Desarrollador",
          imagen: "imagen",
          colorfondo: turquesa,
        ),
      ],
    );
  }*/
}
/**
 * 
 * 
 * import 'package:flutter/material.dart';
import 'package:ejemplobasic2526/widgets/perfil_card.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  static const Color azul = Color(0xFF93d2e7);
  static const Color turquesa = Color(0xFFa5e8cb);

  final List<Map<String, dynamic>> users = [
    {
      "nombre": "Ana",
      "rol": "Desarrolladora",
      "imagen": "assets/images/jugador.png",
      "color": Colors.amber,
      "activo": true,
    },
    {
      "nombre": "Luis",
      "rol": "Diseñador",
      "imagen": "assets/images/jugador.png",
      "color": azul,
      "activo": true,
    },
    {
      "nombre": "Marta",
      "rol": "QA",
      "imagen": "assets/images/jugador.png",
      "color": turquesa,
      "activo": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final myuser = users[index];

        return PerfilCard(
          nombre: myuser["nombre"],
          rol: myuser["rol"],
          imagen: myuser["imagen"],
          colorfondo: myuser["color"],
          activo: myuser["activo"] as bool,
          onToggleActivo: () {
            setState(() {
              myuser["activo"] = !(myuser["activo"] as bool);
            });
          },
        );
      },
    );
  }
}

 * 
 */