import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:login/models/equipo.dart';
import 'package:login/providers/equipo_provider.dart';

class NextTeamReservationsSection extends StatelessWidget {
  const NextTeamReservationsSection({super.key, required this.rol, required this.userDocId});

  final String rol;
  final String userDocId;

  bool get _isCoach => rol.trim().toLowerCase() == 'entrenador';

  Future<void> _confirmLeaveTeam(
    BuildContext context, {
    required Equipo equipo,
    required String memberId,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Darse de baja'),
        content: Text('¿Quieres salir de "${equipo.nombre}"?'),
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
      await context.read<EquipoProvider>().removeMiembro(equipo.id, memberId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te has dado de baja del equipo.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo salir del equipo: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Text('Inicia sesión para ver reservas de equipo.');
    }

    final uid = user.uid;
    final now = DateTime.now();

    return StreamBuilder<List<Equipo>>(
      stream: context.watch<EquipoProvider>().equiposActivos,
      builder: (context, equiposSnap) {
        if (equiposSnap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          );
        }
        if (equiposSnap.hasError) return const Text('Error cargando equipos.');

        final equipos = equiposSnap.data ?? const <Equipo>[];

        final misEquipos = _isCoach
            ? equipos.where((e) => e.entrenadorID == userDocId || e.entrenadorID == uid).toList()
            : equipos.where((e) => e.miembros.contains(userDocId) || e.miembros.contains(uid)).toList();

        if (misEquipos.isEmpty) {
          return Text(
            _isCoach ? 'No tienes equipos asignados.' : 'No perteneces a ningún equipo.',
            style: const TextStyle(color: Colors.black54),
          );
        }

        final equipoById = <String, Equipo>{for (final e in misEquipos) e.id: e};
        final teamIds = misEquipos.map((e) => e.id).toSet();

        final stream = FirebaseFirestore.instance
            .collection('reservas')
            .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
            .orderBy('startAt')
            .limit(120)
            .snapshots();

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (context, snap) {
            if (snap.hasError) return Text('Error cargando reservas de equipo: ${snap.error}');
            if (!snap.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: LinearProgressIndicator(),
              );
            }

            final docsAll = snap.data!.docs;

            final filtered = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
            for (final d in docsAll) {
              final data = d.data();
              final activa = (data['activa'] is bool) ? (data['activa'] as bool) : false;
              if (!activa) continue;
              final equipoId = (data['equipoID'] as String?) ?? '';
              if (equipoId.isEmpty) continue;
              if (!teamIds.contains(equipoId)) continue;
              filtered.add(d);
              if (filtered.length >= 5) break;
            }

            if (filtered.isEmpty) return const Text('No hay reservas de equipo próximas.');

            return Column(
              children: [
                ...filtered.map((doc) {
                  final data = doc.data();
                  final equipoId = (data['equipoID'] as String?) ?? '';
                  final equipo = equipoById[equipoId];
                  final equipoNombre = equipo?.nombre.isNotEmpty == true
                      ? equipo!.nombre
                      : (equipoId.isEmpty ? 'Equipo' : equipoId);

                  final pistaId = (data['pistaID'] as String?) ?? '';
                  final deporte = (data['deporte'] as String?) ?? 'deporte';
                  final startAt = (data['startAt'] as Timestamp?)?.toDate();
                  final endAt = (data['endAt'] as Timestamp?)?.toDate();

                  final dateStr = startAt == null
                      ? 'Fecha desconocida'
                      : DateFormat('dd/MM/yyyy HH:mm').format(startAt);
                  final endStr = endAt == null ? '' : DateFormat('HH:mm').format(endAt);

                  final Future<Map<String, dynamic>?> pistaFuture = pistaId.isEmpty
                      ? Future.value(null)
                      : FirebaseFirestore.instance
                          .collection('pistas')
                          .doc(pistaId)
                          .get()
                          .then((p) => p.data() as Map<String, dynamic>?);

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: pistaFuture,
                    builder: (context, pistaSnap) {
                      final pistaNombre =
                          pistaSnap.data?['nombre'] ?? (pistaId.isEmpty ? 'Pista' : pistaId);

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.groups_outlined),
                          title: Text(
                            '$equipoNombre • $pistaNombre',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: Text(
                            endStr.isEmpty
                                ? '$deporte • $dateStr'
                                : '$deporte • $dateStr - $endStr',
                          ),
                          trailing: (_isCoach || equipo == null)
                              ? null
                              : TextButton(
                                  onPressed: () => _confirmLeaveTeam(
                                    context,
                                    equipo: equipo,
                                    memberId: userDocId,
                                  ),
                                  child: const Text('Darse de baja'),
                                ),
                        ),
                      );
                    },
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
}