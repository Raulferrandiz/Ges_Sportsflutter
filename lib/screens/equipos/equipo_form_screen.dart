import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:login/models/equipo.dart';
import 'package:login/models/user.dart' as app;
import 'package:login/providers/equipo_provider.dart';
import 'package:login/providers/user_provider.dart';

enum _BackAction { cancel, discard, save }

class EquipoFormScreen extends StatefulWidget {
  const EquipoFormScreen({super.key, this.equipoToEdit});

  final Equipo? equipoToEdit;

  @override
  State<EquipoFormScreen> createState() => _EquipoFormScreenState();
}

class _EquipoFormScreenState extends State<EquipoFormScreen> {
  static const Color appOrange = Color(0xFFF59E0B);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nombreCtrl;
  late final TextEditingController deporteCtrl;

  String? _entrenadorId;
  Set<String> _miembrosIds = <String>{};
  late bool _activo;

  late final String _initialNombre;
  late final String _initialDeporte;
  late final String? _initialEntrenador;
  late final Set<String> _initialMiembros;
  late final bool _initialActivo;

  bool get isEdit => widget.equipoToEdit != null;

  @override
  void initState() {
    super.initState();
    final e = widget.equipoToEdit;

    nombreCtrl = TextEditingController(text: e?.nombre ?? '');
    deporteCtrl = TextEditingController(text: e?.deporte ?? '');

    _entrenadorId = e?.entrenadorID.isNotEmpty == true ? e!.entrenadorID : null;
    _miembrosIds = {...(e?.miembros ?? const <String>[])};
    _activo = e?.activo ?? true;

    _initialNombre = nombreCtrl.text;
    _initialDeporte = deporteCtrl.text;
    _initialEntrenador = _entrenadorId;
    _initialMiembros = {..._miembrosIds};
    _initialActivo = _activo;
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    deporteCtrl.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges {
    return nombreCtrl.text != _initialNombre ||
        deporteCtrl.text != _initialDeporte ||
        _entrenadorId != _initialEntrenador ||
        _activo != _initialActivo ||
        _miembrosIds.length != _initialMiembros.length ||
        !_miembrosIds.containsAll(_initialMiembros);
  }

  Future<void> _handleBack() async {
    if (!_hasUnsavedChanges) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final action = await showDialog<_BackAction>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Guardar cambios?'),
        content: const Text('Tienes cambios sin guardar. ¿Qué quieres hacer?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, _BackAction.cancel), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, _BackAction.discard), child: const Text('Salir sin guardar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: appOrange),
            onPressed: () => Navigator.pop(context, _BackAction.save),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (action == _BackAction.discard) {
      Navigator.pop(context);
      return;
    }

    if (action == _BackAction.save) {
      final ok = await _guardar(popAfterSave: false);
      if (ok && mounted) Navigator.pop(context);
    }
  }

  Future<void> _pickMiembros(List<app.User> candidates) async {
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _MiembrosPicker(
        users: candidates,
        initialSelected: _miembrosIds,
      ),
    );

    if (selected == null) return;
    setState(() => _miembrosIds = selected);
  }

  Future<bool> _guardar({required bool popAfterSave}) async {
    if (!_formKey.currentState!.validate()) return false;

    if (_entrenadorId == null || _entrenadorId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un entrenador.')));
      return false;
    }

    final nombre = nombreCtrl.text.trim();
    final deporte = deporteCtrl.text.trim().toLowerCase();

    final equipo = Equipo(
      id: isEdit ? widget.equipoToEdit!.id : '',
      activo: _activo,
      deporte: deporte,
      entrenadorID: _entrenadorId!,
      miembros: _miembrosIds.toList()..sort(),
      nombre: nombre,
    );

    final provider = context.read<EquipoProvider>();

    if (isEdit) {
      await provider.update(equipo.id, equipo);
    } else {
      await provider.add(equipo);
    }

    if (popAfterSave && mounted) Navigator.pop(context);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final titleText = isEdit ? 'Editar equipo' : 'Nuevo equipo';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          backgroundColor: Colors.black,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: appOrange),
                onPressed: _handleBack,
                tooltip: 'Volver',
              ),
              Image.asset(
                'assets/images/gesports.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  titleText,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, color: appOrange),
                ),
              ),
            ],
          ),
        ),
        body: StreamBuilder<List<app.User>>(
          stream: context.watch<UserProvider>().users,
          builder: (context, snap) {
            final allUsers = snap.data ?? const <app.User>[];
            final entrenadores = allUsers.where((u) => u.rol.trim().toLowerCase() == 'entrenador').toList()
              ..sort((a, b) => a.email.compareTo(b.email));
            final jugadores = allUsers.where((u) => u.rol.trim().toLowerCase() == 'jugador').toList()
              ..sort((a, b) => a.email.compareTo(b.email));

            // Si el entrenador seleccionado ya no existe, lo limpiamos
            if (_entrenadorId != null && !entrenadores.any((u) => u.id == _entrenadorId)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _entrenadorId = null);
              });
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _input(
                      controller: nombreCtrl,
                      label: 'Nombre del equipo',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce un nombre' : null,
                    ),
                    const SizedBox(height: 16),
                    _input(
                      controller: deporteCtrl,
                      label: 'Deporte (ej: padel, tenis)',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Introduce un deporte' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _entrenadorId,
                      decoration: _decoration('Entrenador'),
                      items: entrenadores.map((u) {
                        final label = u.nombre.trim().isEmpty ? u.email : '${u.nombre} • ${u.email}';
                        return DropdownMenuItem(value: u.id, child: Text(label));
                      }).toList(),
                      onChanged: (v) => setState(() => _entrenadorId = v),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Selecciona un entrenador' : null,
                    ),
                    const SizedBox(height: 16),
                    _card(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Miembros seleccionados: ${_miembrosIds.length}',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _pickMiembros(jugadores),
                            icon: const Icon(Icons.group_add_outlined),
                            label: const Text('Elegir'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_miembrosIds.isNotEmpty)
                      _card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('IDs miembros', style: TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(_miembrosIds.join(', ')),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    _card(
                      child: SwitchListTile(
                        title: const Text('Equipo activo', style: TextStyle(fontWeight: FontWeight.w600)),
                        value: _activo,
                        activeColor: appOrange,
                        onChanged: (v) => setState(() => _activo = v),
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
                        onPressed: () => _guardar(popAfterSave: true),
                        child: Text(
                          isEdit ? 'GUARDAR CAMBIOS' : 'GUARDAR EQUIPO',
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
            );
          },
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

  Widget _input({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: _decoration(label),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: child,
    );
  }
}

class _MiembrosPicker extends StatefulWidget {
  const _MiembrosPicker({required this.users, required this.initialSelected});

  final List<app.User> users;
  final Set<String> initialSelected;

  @override
  State<_MiembrosPicker> createState() => _MiembrosPickerState();
}

class _MiembrosPickerState extends State<_MiembrosPicker> {
  late Set<String> selected;

  @override
  void initState() {
    super.initState();
    selected = {...widget.initialSelected};
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Seleccionar miembros', style: TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text('Marca jugadores para añadir al equipo.'),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.users.length,
                itemBuilder: (context, i) {
                  final u = widget.users[i];
                  final label = u.nombre.trim().isEmpty ? u.email : '${u.nombre} • ${u.email}';
                  final checked = selected.contains(u.id);

                  return CheckboxListTile(
                    value: checked,
                    title: Text(label),
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          selected.add(u.id);
                        } else {
                          selected.remove(u.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, selected),
                      child: const Text('Aplicar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}