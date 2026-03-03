import 'package:flutter/material.dart';

import 'users/users_stful_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.adminEmail,
  });

  final String adminEmail;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 56,
        //logo
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
          'Panel de Admin',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFFF59E0B),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.05,
          children: [
            _DashCard(
              title: 'Usuarios',
              subtitle: 'Gestión de perfiles',
              icon: Icons.people_outline,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UsersStfulScreen()),
                );
              },
            ),
            _DashCard(
              title: 'Equipos',
              subtitle: 'Altas y bajas',
              icon: Icons.groups_outlined,
              onTap: () => _openPlaceholder(context, 'Gestión de equipos'),
            ),
            _DashCard(
              title: 'Reservas',
              subtitle: 'Por franja horaria',
              icon: Icons.event_note_outlined,
              onTap: () => _openPlaceholder(context, 'Gestión de reservas'),
            ),
            _DashCard(
              title: 'Pistas',
              subtitle: 'Instalaciones',
              icon: Icons.sports_tennis_outlined,
              onTap: () => _openPlaceholder(context, 'Gestión de instalaciones'),
            ),
          ],
        ),
      ),
    );
  }

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _PlaceholderScreen(title: title)),
    );
  }
}

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(title),
      ),
      body: const Center(
        child: Text('Pantalla pendiente (solo UI).'),
      ),
    );
  }
}
