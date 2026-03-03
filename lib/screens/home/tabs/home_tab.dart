import 'package:flutter/material.dart';

import '../widgets/home_header.dart';
import '../widgets/next_reservations_section.dart';
import '../widgets/quick_actions.dart';
import '../widgets/section_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.rol,
    required this.email,
    required this.onGoToReservations,
  });

  final String rol;
  final String email;
  final VoidCallback onGoToReservations;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HomeHeader(rol: rol, email: email),
        const SizedBox(height: 12),

        QuickActions(
          onReserveTap: onGoToReservations,
          onIncidentTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Incidencias: pendiente de implementar')),
            );
          },
        ),

        const SizedBox(height: 16),

        const SectionCard(
          title: 'Información general',
          subtitle: 'Estado del centro y avisos.',
          icon: Icons.info_outline,
          body: Text(
            'Consulta tus reservas, gestiona tu actividad y mantente al día de eventos del centro.',
            style: TextStyle(color: Colors.black87),
          ),
        ),

        const SizedBox(height: 12),

        const SectionCard(
          title: 'Próximas reservas (propias)',
          subtitle: 'Tus próximas 5 reservas activas.',
          icon: Icons.event_available_outlined,
          body: NextReservationsSection(),
        ),

        const SizedBox(height: 12),

        SectionCard(
          title: 'Equipos',
          subtitle: rol == 'entrenador'
              ? 'Tus equipos (placeholder por ahora).'
              : 'Equipos donde participas (placeholder por ahora).',
          icon: Icons.groups_outlined,
          body: Column(
            children: const [
              _TeamRow(
                title: 'Equipo Pádel A',
                subtitle: 'Próximo entrenamiento: miércoles 19:00',
                actionText: 'Ver',
              ),
              Divider(),
              _TeamRow(
                title: 'Equipo Tenis B',
                subtitle: 'Próximo entrenamiento: viernes 18:00',
                actionText: 'Ver',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TeamRow extends StatelessWidget {
  const _TeamRow({
    required this.title,
    required this.subtitle,
    required this.actionText,
  });

  final String title;
  final String subtitle;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(actionText),
        ),
      ],
    );
  }
}