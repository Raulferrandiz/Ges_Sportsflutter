import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:login/screens/users/users_stful_screen.dart';
import 'package:login/screens/equipos/equipos_stful_screen.dart';
import 'package:login/screens/reservas/reservas_stful_screen.dart';
import 'package:login/screens/pistas/pistas_stful_screen.dart';
import 'package:login/screens/incidencias/incidencias_stful_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.adminEmail,
  });

  final String adminEmail;

  static const Color appOrange = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
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
        title: const Text(
          'Panel de Admin',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: appOrange,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.05,
                children: [
                  _DashCard(
                    title: 'Usuarios',
                    icon: Icons.people_outline,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const UsersStfulScreen()),
                      );
                    },
                  ),
                  _DashCard(
                    title: 'Equipos',
                    icon: Icons.groups_outlined,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const EquiposStfulScreen()),
                      );
                    },
                  ),
                  _DashCard(
                    title: 'Reservas',
                    icon: Icons.event_note_outlined,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ReservasStfulScreen()),
                      );
                    },
                  ),
                  _DashCard(
                    title: 'Pistas',
                    icon: Icons.sports_tennis_outlined,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const PistasStfulScreen()),
                      );
                    },
                  ),
                  _DashCard(
                    title: 'Incidencias',
                    icon: Icons.report_gmailerrorred_outlined,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const IncidenciasStfulScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: appOrange,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashCard extends StatelessWidget {
  const _DashCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  static const Color appOrange = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle != null && subtitle!.trim().isNotEmpty;

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
                color: appOrange,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (hasSubtitle) ...[
              const SizedBox(height: 4),
              Text(subtitle!, style: const TextStyle(color: Colors.black54)),
            ],
          ],
        ),
      ),
    );
  }
}