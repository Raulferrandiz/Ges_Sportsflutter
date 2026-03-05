import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:login/models/pista.dart';
import 'package:login/models/reserva.dart';
import 'package:login/models/user.dart' as app;
import 'package:login/providers/pista_provider.dart';
import 'package:login/providers/reserva_provider.dart';
import 'package:login/providers/user_provider.dart';
import 'package:login/screens/reservas/reserva_form_screen.dart';

class ReservasStfulScreen extends StatefulWidget {
  const ReservasStfulScreen({super.key});

  @override
  State<ReservasStfulScreen> createState() => _ReservasStfulScreenState();
}

class _ReservasStfulScreenState extends State<ReservasStfulScreen> {
  static const Color appOrange = Color(0xFFF59E0B);

  DateTime _selectedDate = DateTime.now();
  bool _filterByDate = true;
  bool _onlyActive = true;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'Selecciona el día',
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
      _filterByDate = true;
    });
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _confirmCancel(BuildContext context, Reserva r) async {
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

    if (ok == true && context.mounted) {
      try {
        await context.read<ReservaProvider>().cancel(r.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva cancelada ✅')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cancelar: $e')),
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, Reserva r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar reserva'),
        content: const Text('¿Seguro que quieres eliminar esta reserva?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      try {
        await context.read<ReservaProvider>().delete(r.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva eliminada')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersStream = context.watch<UserProvider>().users;
    final pistasStream = context.watch<PistaProvider>().pistas;
    final reservasStream = context.watch<ReservaProvider>().reservas;

    final dateLabel = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: appOrange),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Volver',
            ),
            Image.asset(
              'assets/images/gesports.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Reservas',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: appOrange,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appOrange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReservaFormScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _filterByDate ? 'Día: $dateLabel' : 'Mostrando: todas las fechas',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: const Text('Cambiar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        FilterChip(
                          label: const Text('Filtrar por día'),
                          selected: _filterByDate,
                          onSelected: (v) => setState(() => _filterByDate = v),
                        ),
                        FilterChip(
                          label: const Text('Solo activas'),
                          selected: _onlyActive,
                          onSelected: (v) => setState(() => _onlyActive = v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<app.User>>(
              stream: usersStream,
              builder: (context, usersSnap) {
                if (usersSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final users = usersSnap.data ?? const <app.User>[];
                final userEmailById = <String, String>{for (final u in users) u.id: u.email};

                return StreamBuilder<List<Pista>>(
                  stream: pistasStream,
                  builder: (context, pistasSnap) {
                    if (pistasSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final pistas = pistasSnap.data ?? const <Pista>[];
                    final pistaById = <String, Pista>{for (final p in pistas) p.id: p};

                    return StreamBuilder<List<Reserva>>(
                      stream: reservasStream,
                      builder: (context, reservasSnap) {
                        if (reservasSnap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (reservasSnap.hasError) {
                          return const Center(child: Text('Error cargando reservas'));
                        }

                        var reservas = reservasSnap.data ?? const <Reserva>[];

                        if (_onlyActive) {
                          reservas = reservas.where((r) => r.activa).toList();
                        }
                        if (_filterByDate) {
                          reservas = reservas.where((r) => _sameDay(r.startAt, _selectedDate)).toList();
                        }

                        reservas.sort((a, b) => a.startAt.compareTo(b.startAt));

                        if (reservas.isEmpty) {
                          return const Center(child: Text('No hay reservas para mostrar'));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: reservas.length,
                          itemBuilder: (context, i) {
                            final r = reservas[i];

                            final pista = pistaById[r.pistaID];
                            final pistaNombre = pista?.nombre.isNotEmpty == true
                                ? pista!.nombre
                                : (r.pistaID.isEmpty ? 'Pista' : r.pistaID);
                            final pistaExtra = (pista == null || pista.direccion.isEmpty) ? '' : ' • ${pista.direccion}';

                            final userLabel = userEmailById[r.userID] ?? (r.userID.isEmpty ? 'Usuario' : r.userID);

                            final startStr = DateFormat('dd/MM/yyyy HH:mm').format(r.startAt);
                            final endStr = DateFormat('HH:mm').format(r.endAt);

                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  r.activa ? Icons.event_available_outlined : Icons.event_busy_outlined,
                                  color: r.activa ? Colors.green : Colors.red,
                                ),
                                title: Text(
                                  '$pistaNombre$pistaExtra • ${r.deporte}',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                subtitle: Text('$startStr - $endStr\n$userLabel'),
                                isThreeLine: true,
                                trailing: Wrap(
                                  spacing: 4,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ReservaFormScreen(reservaToEdit: r),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.cancel_outlined),
                                      onPressed: r.activa ? () => _confirmCancel(context, r) : null,
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => _confirmDelete(context, r),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}