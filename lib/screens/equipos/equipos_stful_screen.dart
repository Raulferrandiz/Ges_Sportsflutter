import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login/models/equipo.dart';
import 'package:login/models/user.dart' as app;
import 'package:login/providers/equipo_provider.dart';
import 'package:login/providers/user_provider.dart';
import 'package:login/screens/equipos/equipo_form_screen.dart';

class EquiposStfulScreen extends StatefulWidget {
  const EquiposStfulScreen({super.key});

  @override
  State<EquiposStfulScreen> createState() => _EquiposStfulScreenState();
}

class _EquiposStfulScreenState extends State<EquiposStfulScreen> {
  static const Color appOrange = Color(0xFFF59E0B);

  bool _onlyActive = true;
  String? _filterDeporte;

  Future<void> _confirmDelete(BuildContext context, Equipo e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar equipo'),
        content: Text('¿Seguro que quieres eliminar:\n\n${e.nombre}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      await context.read<EquipoProvider>().delete(e.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Equipo eliminado')));
    }
  }

  Future<void> _toggleActivo(BuildContext context, Equipo e) async {
    final next = !e.activo;
    await context.read<EquipoProvider>().setActivo(e.id, next);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(next ? 'Equipo activado' : 'Equipo desactivado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final equiposStream = context.watch<EquipoProvider>().equipos;
    final usersStream = context.watch<UserProvider>().users;

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
                'Equipos',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, color: appOrange),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appOrange,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const EquipoFormScreen()));
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: StreamBuilder<List<app.User>>(
        stream: usersStream,
        builder: (context, usersSnap) {
          final users = usersSnap.data ?? const <app.User>[];
          final userById = <String, app.User>{for (final u in users) u.id: u};

          return StreamBuilder<List<Equipo>>(
            stream: equiposStream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) return const Center(child: Text('Error cargando equipos'));

              final all = snap.data ?? const <Equipo>[];

              final deportes = all.map((e) => e.deporte.trim()).where((d) => d.isNotEmpty).toSet().toList()..sort();
              if (_filterDeporte != null && !deportes.contains(_filterDeporte)) _filterDeporte = null;

              var equipos = all;
              if (_onlyActive) equipos = equipos.where((e) => e.activo).toList();
              if (_filterDeporte != null) equipos = equipos.where((e) => e.deporte.trim() == _filterDeporte).toList();

              equipos.sort((a, b) => a.nombre.compareTo(b.nombre));

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Card(
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            FilterChip(
                              label: const Text('Solo activos'),
                              selected: _onlyActive,
                              onSelected: (v) => setState(() => _onlyActive = v),
                            ),
                            if (deportes.isNotEmpty)
                              ChoiceChip(
                                label: Text(_filterDeporte == null ? 'Deporte: todos' : 'Deporte: $_filterDeporte'),
                                selected: _filterDeporte != null,
                                onSelected: (_) async {
                                  final selected = await showModalBottomSheet<String?>(
                                    context: context,
                                    builder: (_) => _DeportePicker(deportes: deportes, selected: _filterDeporte),
                                  );
                                  if (!mounted) return;
                                  setState(() => _filterDeporte = selected);
                                },
                              ),
                            if (_filterDeporte != null)
                              TextButton(
                                onPressed: () => setState(() => _filterDeporte = null),
                                child: const Text('Quitar filtro'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: equipos.isEmpty
                        ? const Center(child: Text('No hay equipos para mostrar'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: equipos.length,
                            itemBuilder: (context, i) {
                              final e = equipos[i];

                              final entrenador = userById[e.entrenadorID];
                              final entrenadorLabel = entrenador == null
                                  ? (e.entrenadorID.isEmpty ? '(sin entrenador)' : e.entrenadorID)
                                  : (entrenador.nombre.trim().isEmpty
                                      ? entrenador.email
                                      : '${entrenador.nombre} • ${entrenador.email}');

                              final subtitle = [
                                if (e.deporte.trim().isNotEmpty) 'deporte: ${e.deporte.trim()}',
                                'entrenador: $entrenadorLabel',
                                'miembros: ${e.miembros.length}',
                                'activo: ${e.activo ? "sí" : "no"}',
                              ].join('\n');

                              return Card(
                                child: ListTile(
                                  title: Text(
                                    e.nombre.isEmpty ? '(Sin nombre)' : e.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  subtitle: Text(subtitle),
                                  isThreeLine: true,
                                  trailing: Wrap(
                                    spacing: 4,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => EquipoFormScreen(equipoToEdit: e)),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          e.activo ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
                                          color: e.activo ? Colors.green : Colors.grey,
                                        ),
                                        onPressed: () => _toggleActivo(context, e),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _confirmDelete(context, e),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DeportePicker extends StatelessWidget {
  const _DeportePicker({required this.deportes, required this.selected});

  final List<String> deportes;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const ListTile(
            title: Text('Filtrar por deporte', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          ListTile(
            title: const Text('Todos'),
            trailing: selected == null ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop<String?>(context, null),
          ),
          for (final d in deportes)
            ListTile(
              title: Text(d),
              trailing: selected == d ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop<String?>(context, d),
            ),
        ],
      ),
    );
  }
}