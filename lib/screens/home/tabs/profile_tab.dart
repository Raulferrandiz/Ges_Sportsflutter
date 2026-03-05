import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../incidencias/mis_incidencias_screen.dart';
import '../widgets/section_card.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({
    super.key,
    required this.rol,
    required this.email,
  });

  final String rol;
  final String email;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Tu perfil',
          subtitle: 'Datos de sesión',
          icon: Icons.person_outline,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Rol: $rol'),
              const SizedBox(height: 6),
              Text('Email: ${email.isEmpty ? '(sin email)' : email}'),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Incidencias',
          subtitle: 'Reporta un problema o avisa de una ausencia',
          icon: Icons.report_gmailerrorred_outlined,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crea y revisa tus incidencias enviadas.',
                style: TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MisIncidenciasScreen()),
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('Mis incidencias'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}