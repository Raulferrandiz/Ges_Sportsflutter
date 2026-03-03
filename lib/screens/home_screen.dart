import 'package:flutter/material.dart';

import 'home/tabs/home_tab.dart';
import 'home/tabs/profile_tab.dart';
import 'home/tabs/reservations_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.rol,
    required this.email,
  });

  final String rol;
  final String email;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      HomeTab(
        rol: widget.rol,
        email: widget.email,
        onGoToReservations: () => setState(() => _index = 1),
      ),
      const ReservationsTab(),
      ProfileTab(rol: widget.rol, email: widget.email),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        //logo
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Image.asset(
              'assets/images/gesports.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
        ),
        //titulo
        title: const Text(
          'GesSport',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFFF59E0B),
          ),
        ),
      ),
      body: SafeArea(child: tabs[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFFF59E0B),
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available_outlined),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
