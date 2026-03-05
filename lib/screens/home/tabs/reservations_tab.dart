import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../models/pista.dart';
import '../../../models/reserva.dart';
import '../../../providers/pista_provider.dart';
import '../../../providers/reserva_provider.dart';
import '../widgets/section_card.dart';

class ReservationsTab extends StatefulWidget {
  const ReservationsTab({super.key, required this.userDocId});

  final String userDocId;

  @override
  State<ReservationsTab> createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<ReservationsTab> {
  static const int slotMinutes = 60;

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  DateTime _selectedDate = DateTime.now();
  String? _selectedSport;
  String? _selectedPistaId;

  bool _saving = false;

  List<TimeOfDay> get _slots {
    final slots = <TimeOfDay>[];
    for (int hour = 8; hour <= 21; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
    }
    return slots;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 1),
      helpText: 'Selecciona el día',
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<bool> _isSlotFree(String pistaId, DateTime date, TimeOfDay slot) async {
    final startAt = _combine(date, slot);
    final q = await _firestore
        .collection('reservas')
        .where('activa', isEqualTo: true)
        .where('pistaID', isEqualTo: pistaId)
        .where('startAt', isEqualTo: Timestamp.fromDate(startAt))
        .limit(1)
        .get();
    return q.docs.isEmpty;
  }

  Future<void> _createReservation(TimeOfDay slot) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para reservar.')),
      );
      return;
    }
    if (_selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un deporte.')),
      );
      return;
    }
    if (_selectedPistaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una pista.')),
      );
      return;
    }

    final startAt = _combine(_selectedDate, slot);
    final endAt = startAt.add(const Duration(minutes: slotMinutes));

    if (startAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes reservar en una franja pasada.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final existing = await _firestore
          .collection('reservas')
          .where('activa', isEqualTo: true)
          .where('pistaID', isEqualTo: _selectedPistaId)
          .where('startAt', isEqualTo: Timestamp.fromDate(startAt))
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esa franja ya está reservada.')),
        );
        return;
      }

      final reserva = Reserva(
        id: '',
        activa: true,
        deporte: _selectedSport!,
        startAt: startAt,
        endAt: endAt,
        pistaID: _selectedPistaId!,
        userID: widget.userDocId,
      );

      await context.read<ReservaProvider>().add(reserva);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva creada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creando reserva: $e')),
      );
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Reservas',
          subtitle: 'Crea una reserva por franja horaria.',
          icon: Icons.event_available_outlined,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Día seleccionado: $dateLabel',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _saving ? null : _pickDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Cambiar'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Pista>>(
                stream: context.watch<PistaProvider>().pistasActivas,
                builder: (context, snap) {
                  if (snap.hasError) return const Text('Error cargando pistas.');
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    );
                  }

                  final pistas = snap.data!;
                  final sports = pistas
                      .map((p) => p.tipo.trim())
                      .where((t) => t.isNotEmpty)
                      .toSet()
                      .toList()
                    ..sort();

                  if (sports.isEmpty) {
                    return const Text('No hay pistas activas disponibles.');
                  }

                  if (_selectedSport != null && !sports.contains(_selectedSport)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedSport = null;
                        _selectedPistaId = null;
                      });
                    });
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedSport,
                    decoration: const InputDecoration(
                      labelText: 'Deporte',
                      border: OutlineInputBorder(),
                    ),
                    items: sports
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: _saving
                        ? null
                        : (v) {
                            setState(() {
                              _selectedSport = v;
                              _selectedPistaId = null;
                            });
                          },
                  );
                },
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Pista>>(
                stream: (_selectedSport == null)
                    ? const Stream.empty()
                    : context.watch<PistaProvider>().pistasPorTipo(_selectedSport!),
                builder: (context, snap) {
                  if (_selectedSport == null) {
                    return const Text('Selecciona un deporte para ver pistas.');
                  }
                  if (snap.hasError) return const Text('Error cargando pistas del deporte.');
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    );
                  }

                  final pistas = snap.data!;
                  if (pistas.isEmpty) {
                    return const Text('No hay pistas activas para este deporte.');
                  }

                  if (_selectedPistaId != null && !pistas.any((p) => p.id == _selectedPistaId)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() => _selectedPistaId = null);
                    });
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedPistaId,
                    decoration: const InputDecoration(
                      labelText: 'Pista',
                      border: OutlineInputBorder(),
                    ),
                    items: pistas.map((p) {
                      final label = p.direccion.isEmpty ? p.nombre : '${p.nombre} • ${p.direccion}';
                      return DropdownMenuItem(value: p.id, child: Text(label));
                    }).toList(),
                    onChanged: _saving ? null : (v) => setState(() => _selectedPistaId = v),
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Franjas horarias', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (_selectedPistaId == null)
                const Text('Selecciona una pista para ver franjas disponibles.')
              else
                Column(
                  children: _slots.map((slot) {
                    final label = slot.format(context);
                    return FutureBuilder<bool>(
                      future: _isSlotFree(_selectedPistaId!, _selectedDate, slot),
                      builder: (context, snap) {
                        final free = snap.data ?? false;
                        final loading = snap.connectionState == ConnectionState.waiting;

                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: Icon(
                              free ? Icons.lock_open_outlined : Icons.lock_outline,
                              color: free ? Colors.green : Colors.red,
                            ),
                            title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('Duración: $slotMinutes min'),
                            trailing: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : ElevatedButton(
                                    onPressed: (!_saving && free) ? () => _createReservation(slot) : null,
                                    child: _saving ? const Text('Guardando...') : const Text('Reservar'),
                                  ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}