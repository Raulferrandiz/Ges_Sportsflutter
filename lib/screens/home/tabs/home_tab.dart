import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:login/models/equipo.dart';
import 'package:login/providers/equipo_provider.dart';
import '../../incidencias/mis_incidencias_screen.dart';
import '../widgets/home_header.dart';
import '../widgets/next_reservations_section.dart';
import '../widgets/next_team_reservations_section.dart';
import '../widgets/quick_actions.dart';
import '../widgets/section_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    required this.rol,
    required this.email,
    required this.userDocId,
    required this.onGoToReservations,
  });

  final String rol;
  final String email;
  final String userDocId;
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MisIncidenciasScreen()),
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
        SectionCard(
          title: 'Próximas reservas',
          subtitle: 'Tus próximas 5 reservas activas.',
          icon: Icons.event_available_outlined,
          body: NextReservationsSection(userDocId: userDocId),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Próximas reservas con equipo',
          subtitle: rol.trim().toLowerCase() == 'entrenador'
              ? 'Reservas de tus equipos.'
              : 'Entrenamientos / reservas de tus equipos.',
          icon: Icons.groups_outlined,
          body: NextTeamReservationsSection(rol: rol, userDocId: userDocId),
        ),
        const SizedBox(height: 12),
        SectionCard(
          title: 'Equipos',
          subtitle: rol.trim().toLowerCase() == 'entrenador'
              ? 'Tus equipos.'
              : 'Equipos donde participas.',
          icon: Icons.groups_outlined,
          body: _TeamsSection(rol: rol, userDocId: userDocId),
        ),
      ],
    );
  }
}

class _TeamsSection extends StatelessWidget {
  const _TeamsSection({required this.rol, required this.userDocId});

  final String rol;
  final String userDocId;

  Future<void> _showTeamDetails(BuildContext context, Equipo e) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(e.nombre.isEmpty ? 'Equipo' : e.nombre),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (e.deporte.trim().isNotEmpty) Text('Deporte: ${e.deporte}'),
            const SizedBox(height: 6),
            Text('Miembros: ${e.miembros.length}'),
            const SizedBox(height: 6),
            Text('Activo: ${e.activo ? 'Sí' : 'No'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLeaveTeam(BuildContext context, Equipo e, String memberId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Darse de baja'),
        content: Text('¿Quieres salir de "${e.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salir'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await context.read<EquipoProvider>().removeMiembro(e.id, memberId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has dado de baja del equipo.')),
      );
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo salir del equipo: $err')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (authUid.isEmpty) return const Text('No hay sesión activa.');

    final isCoach = rol.trim().toLowerCase() == 'entrenador';

    return StreamBuilder<List<Equipo>>(
      stream: context.watch<EquipoProvider>().equiposActivos,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final equipos = snap.data ?? const <Equipo>[];

        final myTeams = isCoach
            ? equipos.where((e) => e.entrenadorID == userDocId || e.entrenadorID == authUid).toList()
            : equipos.where((e) => e.miembros.contains(userDocId) || e.miembros.contains(authUid)).toList();

        myTeams.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

        if (myTeams.isEmpty) {
          return Text(
            isCoach ? 'No tienes equipos asignados.' : 'No perteneces a ningún equipo todavía.',
            style: const TextStyle(color: Colors.black54),
          );
        }

        return Column(
          children: [
            for (int i = 0; i < myTeams.length; i++) ...[
              _TeamRowReal(
                equipo: myTeams[i],
                isCoach: isCoach,
                onDetails: () => _showTeamDetails(context, myTeams[i]),
                onLeave: () => _confirmLeaveTeam(context, myTeams[i], userDocId),
              ),
              if (i != myTeams.length - 1) const Divider(),
            ]
          ],
        );
      },
    );
  }
}

class _TeamRowReal extends StatelessWidget {
  const _TeamRowReal({
    required this.equipo,
    required this.isCoach,
    required this.onDetails,
    required this.onLeave,
  });

  final Equipo equipo;
  final bool isCoach;
  final VoidCallback onDetails;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final title = equipo.nombre.trim().isEmpty ? 'Equipo' : equipo.nombre.trim();
    final subtitle = <String>[
      if (equipo.deporte.trim().isNotEmpty) 'Deporte: ${equipo.deporte}',
      'Miembros: ${equipo.miembros.length}',
    ].join(' • ');

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
        if (isCoach)
          TextButton(onPressed: onDetails, child: const Text('Ver'))
        else
          TextButton(onPressed: onLeave, child: const Text('Darse de baja')),
      ],
    );
  }
}