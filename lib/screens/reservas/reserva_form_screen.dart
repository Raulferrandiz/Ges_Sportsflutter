import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:login/models/equipo.dart';
import 'package:login/models/pista.dart';
import 'package:login/models/reserva.dart';
import 'package:login/models/user.dart' as app;
import 'package:login/providers/equipo_provider.dart';
import 'package:login/providers/pista_provider.dart';
import 'package:login/providers/reserva_provider.dart';
import 'package:login/providers/user_provider.dart';

class ReservaFormScreen extends StatefulWidget {
  const ReservaFormScreen({super.key, this.reservaToEdit});

  final Reserva? reservaToEdit;

  @override
  State<ReservaFormScreen> createState() => _ReservaFormScreenState();
}

class _ReservaFormScreenState extends State<ReservaFormScreen> {
  static const Color appOrange = Color(0xFFF59E0B);
  static const int slotMinutes = 60;

  final _formKey = GlobalKey<FormState>();

  late DateTime _selectedDate;
  late TimeOfDay _selectedSlot;
  String? _selectedSport;
  String? _selectedPistaId;
  String? _selectedUserId;

  String? _selectedEquipoId;

  late bool _activa;

  bool _saving = false;

  bool get isEdit => widget.reservaToEdit != null;

  List<TimeOfDay> get _slots {
    final slots = <TimeOfDay>[];
    for (int hour = 8; hour <= 21; hour++) {
      slots.add(TimeOfDay(hour: hour, minute: 0));
    }
    return slots;
  }

  @override
  void initState() {
    super.initState();

    final r = widget.reservaToEdit;

    if (r == null) {
      final now = DateTime.now();
      _selectedDate = DateTime(now.year, now.month, now.day);
      _selectedSlot = const TimeOfDay(hour: 8, minute: 0);
      _selectedSport = null;
      _selectedPistaId = null;
      _selectedUserId = null;
      _selectedEquipoId = null;
      _activa = true;
    } else {
      _selectedDate = DateTime(r.startAt.year, r.startAt.month, r.startAt.day);
      _selectedSlot = TimeOfDay(hour: r.startAt.hour, minute: r.startAt.minute);
      _selectedSport = r.deporte;
      _selectedPistaId = r.pistaID;
      _selectedUserId = r.userID;
      _selectedEquipoId = r.equipoID.trim().isEmpty ? null : r.equipoID;
      _activa = r.activa;
    }
  }

  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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

  String _slotLabel(TimeOfDay t) {
    final dt = DateTime(2000, 1, 1, t.hour, t.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<bool> _isSlotFree({
    required String pistaId,
    required DateTime startAt,
    String? ignoreId,
  }) async {
    final q = await FirebaseFirestore.instance
        .collection('reservas')
        .where('activa', isEqualTo: true)
        .where('pistaID', isEqualTo: pistaId)
        .where('startAt', isEqualTo: Timestamp.fromDate(startAt))
        .limit(3)
        .get();

    if (ignoreId == null) return q.docs.isEmpty;
    return q.docs.where((d) => d.id != ignoreId).isEmpty;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedSport == null || _selectedSport!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un deporte.')),
      );
      return;
    }
    if (_selectedPistaId == null || _selectedPistaId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una pista.')),
      );
      return;
    }
    if (_selectedUserId == null || _selectedUserId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un usuario.')),
      );
      return;
    }

    final startAt = _combine(_selectedDate, _selectedSlot);
    final endAt = startAt.add(const Duration(minutes: slotMinutes));

    if (startAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No puedes reservar en una franja pasada.')),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final free = await _isSlotFree(
        pistaId: _selectedPistaId!,
        startAt: startAt,
        ignoreId: isEdit ? widget.reservaToEdit!.id : null,
      );

      if (!free) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Esa franja ya está reservada.')),
        );
        return;
      }

      final reserva = Reserva(
        id: isEdit ? widget.reservaToEdit!.id : '',
        activa: _activa,
        deporte: _selectedSport!.trim(),
        startAt: startAt,
        endAt: endAt,
        pistaID: _selectedPistaId!,
        userID: _selectedUserId!,
        equipoID: _selectedEquipoId ?? '',
      );

      final provider = context.read<ReservaProvider>();

      if (isEdit) {
        await provider.update(reserva.id, reserva);
      } else {
        await provider.add(reserva);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEdit ? 'Reserva actualizada' : 'Reserva creada')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error guardando reserva: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pistasStream = context.watch<PistaProvider>().pistasActivas;
    final usersStream = context.watch<UserProvider>().users;

    final equiposStream = context.watch<EquipoProvider>().equiposActivos;

    final title = isEdit ? 'Editar reserva' : 'Nueva reserva';
    final dateLabel = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: appOrange),
          onPressed: _saving ? null : () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: appOrange,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _card(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Día: $dateLabel',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _saving ? null : _pickDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: const Text('Cambiar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TimeOfDay>(
                value: _selectedSlot,
                decoration: _decoration('Franja horaria'),
                items: _slots
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          '${_slotLabel(t)} - ${_slotLabel(TimeOfDay(hour: (t.hour + 1) % 24, minute: t.minute))}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: _saving ? null : (v) => setState(() => _selectedSlot = v ?? _selectedSlot),
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Pista>>(
                stream: pistasStream,
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

                  if (isEdit &&
                      _selectedSport != null &&
                      _selectedSport!.trim().isNotEmpty &&
                      !sports.contains(_selectedSport)) {
                    sports.insert(0, _selectedSport!.trim());
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedSport,
                    decoration: _decoration('Deporte'),
                    items: sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: _saving
                        ? null
                        : (v) {
                            setState(() {
                              _selectedSport = v;
                              _selectedPistaId = null;

                              // Si cambias deporte, y el equipo seleccionado ya no encaja, lo limpiamos.
                              _selectedEquipoId = null;
                            });
                          },
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Selecciona un deporte' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<Pista>>(
                stream: pistasStream,
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();

                  if (_selectedSport == null || _selectedSport!.trim().isEmpty) {
                    return const Text('Selecciona un deporte para ver pistas.');
                  }

                  final pistas = snap.data!;
                  final filtered =
                      pistas.where((p) => p.tipo.trim() == _selectedSport!.trim()).toList();

                  if (filtered.isEmpty) return const Text('No hay pistas activas para este deporte.');

                  if (_selectedPistaId != null && !filtered.any((p) => p.id == _selectedPistaId)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedPistaId = null);
                    });
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedPistaId,
                    decoration: _decoration('Pista'),
                    items: filtered.map((p) {
                      final label = p.direccion.isEmpty ? p.nombre : '${p.nombre} • ${p.direccion}';
                      return DropdownMenuItem(value: p.id, child: Text(label));
                    }).toList(),
                    onChanged: _saving ? null : (v) => setState(() => _selectedPistaId = v),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Selecciona una pista' : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              StreamBuilder<List<app.User>>(
                stream: usersStream,
                builder: (context, snap) {
                  if (snap.hasError) return const Text('Error cargando usuarios.');
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    );
                  }

                  final users = snap.data!..sort((a, b) => a.email.compareTo(b.email));

                  if (_selectedUserId != null && !users.any((u) => u.id == _selectedUserId)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedUserId = null);
                    });
                  }

                  return DropdownButtonFormField<String>(
                    value: _selectedUserId,
                    decoration: _decoration('Usuario'),
                    items: users.map((u) {
                      final label = u.nombre.trim().isEmpty ? u.email : '${u.nombre} • ${u.email}';
                      return DropdownMenuItem(value: u.id, child: Text(label));
                    }).toList(),
                    onChanged: _saving ? null : (v) => setState(() => _selectedUserId = v),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Selecciona un usuario' : null,
                  );
                },
              ),

              const SizedBox(height: 16),
              StreamBuilder<List<Equipo>>(
                stream: equiposStream,
                builder: (context, snap) {
                  if (snap.hasError) return const Text('Error cargando equipos.');
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: LinearProgressIndicator(),
                    );
                  }

                  var equipos = snap.data ?? const <Equipo>[];

                  if (_selectedSport != null && _selectedSport!.trim().isNotEmpty) {
                    equipos = equipos.where((e) => e.deporte.trim() == _selectedSport!.trim()).toList();
                  }

                  equipos.sort((a, b) => a.nombre.toLowerCase().compareTo(b.nombre.toLowerCase()));

                  if (isEdit &&
                      _selectedEquipoId != null &&
                      _selectedEquipoId!.trim().isNotEmpty &&
                      !equipos.any((e) => e.id == _selectedEquipoId)) {
                  }

                  if (_selectedEquipoId != null &&
                      _selectedEquipoId!.trim().isNotEmpty &&
                      !equipos.any((e) => e.id == _selectedEquipoId)) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _selectedEquipoId = null);
                    });
                  }

                  final items = <DropdownMenuItem<String?>>[
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Sin equipo (reserva individual)'),
                    ),
                    ...equipos.map((e) {
                      final label = e.nombre.trim().isEmpty ? e.id : e.nombre.trim();
                      return DropdownMenuItem<String?>(
                        value: e.id,
                        child: Text(label),
                      );
                    }),
                  ];

                  return DropdownButtonFormField<String?>(
                    value: _selectedEquipoId,
                    decoration: _decoration('Equipo (opcional)'),
                    items: items,
                    onChanged: _saving ? null : (v) => setState(() => _selectedEquipoId = v),
                  );
                },
              ),

              const SizedBox(height: 20),
              _card(
                child: SwitchListTile(
                  title: const Text('Reserva activa', style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _activa,
                  activeColor: appOrange,
                  onChanged: _saving ? null : (v) => setState(() => _activa = v),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  onPressed: _saving ? null : _save,
                  child: Text(
                    _saving ? 'GUARDANDO...' : (isEdit ? 'GUARDAR CAMBIOS' : 'GUARDAR RESERVA'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: child,
    );
  }
}