import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/reserva_provider.dart';

class NextReservationsSection extends StatelessWidget {
  const NextReservationsSection({super.key});

  Future<void> _cancelReservation(BuildContext context, String reservaId) async {
    try {
      await context.read<ReservaProvider>().cancel(reservaId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva cancelada ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cancelar: $e')),
      );
    }
  }

  Future<void> _confirmCancel(BuildContext context, String reservaId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: const Text('¿Seguro que quieres cancelar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await _cancelReservation(context, reservaId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text('Inicia sesión para ver tus reservas.');
    }

    final now = DateTime.now();

    final stream = FirebaseFirestore.instance
        .collection('reservas')
        .where('activa', isEqualTo: true)
        .where('userID', isEqualTo: user.uid)
        .where('startAt', isGreaterThanOrEqualTo: Timestamp.fromDate(now))
        .orderBy('startAt')
        .limit(5)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snap) {
        if (snap.hasError) return const Text('Error cargando reservas.');
        if (!snap.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          );
        }

        final docs = snap.data!.docs;
        if (docs.isEmpty) return const Text('No tienes reservas próximas.');

        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final pistaId = (data['pistaID'] as String?) ?? '';
            final deporte = (data['deporte'] as String?) ?? 'deporte';
            final startAtTs = data['startAt'] as Timestamp?;
            final endAtTs = data['endAt'] as Timestamp?;
            final startAt = startAtTs?.toDate();
            final endAt = endAtTs?.toDate();

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
                    leading: const Icon(Icons.sports_tennis),
                    title: Text(
                      '$pistaNombre • $deporte',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(endStr.isEmpty ? dateStr : '$dateStr - $endStr'),
                    trailing: TextButton.icon(
                      onPressed: () => _confirmCancel(context, doc.id),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar'),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}