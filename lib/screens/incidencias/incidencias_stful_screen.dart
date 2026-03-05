import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:login/models/incidencia.dart';
import 'package:login/models/user.dart' as app;
import 'package:login/providers/incidencia_provider.dart';
import 'package:login/providers/user_provider.dart';
import 'package:login/screens/incidencias/incidencia_form_screen.dart';

class IncidenciasStfulScreen extends StatefulWidget {
  const IncidenciasStfulScreen({super.key});

  @override
  State<IncidenciasStfulScreen> createState() => _IncidenciasStfulScreenState();
}

class _IncidenciasStfulScreenState extends State<IncidenciasStfulScreen> {
  static const Color appOrange = Color(0xFFF59E0B);

  String? _selectedTipo;

  Future<void> _confirmDelete(BuildContext context, Incidencia i) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar incidencia'),
        content: const Text('¿Seguro que quieres eliminar esta incidencia?'),
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
        await context.read<IncidenciaProvider>().delete(i.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incidencia eliminada')),
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
    final incidenciasStream = context.watch<IncidenciaProvider>().incidencias;
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
                'Incidencias',
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const IncidenciaFormScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: StreamBuilder<List<app.User>>(
        stream: usersStream,
        builder: (context, usersSnap) {
          final users = usersSnap.data ?? const <app.User>[];
          final userById = <String, app.User>{for (final u in users) u.id: u};

          return StreamBuilder<List<Incidencia>>(
            stream: incidenciasStream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return const Center(child: Text('Error cargando incidencias'));
              }

              final all = snap.data ?? const <Incidencia>[];

              final tipos = all
                  .map((i) => i.tipo.trim())
                  .where((t) => t.isNotEmpty)
                  .toSet()
                  .toList()
                ..sort();

              if (_selectedTipo != null && !tipos.contains(_selectedTipo)) {
                _selectedTipo = null;
              }

              var incidencias = all;
              if (_selectedTipo != null) {
                incidencias = incidencias.where((i) => i.tipo.trim() == _selectedTipo).toList();
              }

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
                            if (tipos.isNotEmpty)
                              ChoiceChip(
                                label: Text(
                                  _selectedTipo == null ? 'Tipo: todos' : 'Tipo: $_selectedTipo',
                                ),
                                selected: _selectedTipo != null,
                                onSelected: (_) async {
                                  final selected = await showModalBottomSheet<String?>(
                                    context: context,
                                    builder: (_) => _TipoPicker(
                                      tipos: tipos,
                                      selected: _selectedTipo,
                                    ),
                                  );
                                  if (!mounted) return;
                                  setState(() => _selectedTipo = selected);
                                },
                              ),
                            if (_selectedTipo != null)
                              TextButton(
                                onPressed: () => setState(() => _selectedTipo = null),
                                child: const Text('Quitar filtro'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: incidencias.isEmpty
                        ? const Center(child: Text('No hay incidencias para mostrar'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: incidencias.length,
                            itemBuilder: (context, idx) {
                              final i = incidencias[idx];

                              final creador = userById[i.creadorID];
                              final creadorLabel = creador == null
                                  ? (i.creadorID.isEmpty ? '(sin creador)' : i.creadorID)
                                  : (creador.nombre.trim().isEmpty ? creador.email : '${creador.nombre} • ${creador.email}');

                              final fechaStr = DateFormat('dd/MM/yyyy HH:mm').format(i.fecha);

                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.report_gmailerrorred_outlined),
                                  title: Text(
                                    i.mensaje.isEmpty ? '(Sin mensaje)' : i.mensaje,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  subtitle: Text(
                                    'fecha: $fechaStr\n'
                                    'tipo: ${i.tipo.isEmpty ? "(sin tipo)" : i.tipo}\n'
                                    'creador: $creadorLabel',
                                  ),
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
                                              builder: (_) => IncidenciaFormScreen(incidenciaToEdit: i),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => _confirmDelete(context, i),
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

class _TipoPicker extends StatelessWidget {
  const _TipoPicker({required this.tipos, required this.selected});

  final List<String> tipos;
  final String? selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          const ListTile(
            title: Text('Filtrar por tipo', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          ListTile(
            title: const Text('Todos'),
            trailing: selected == null ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop<String?>(context, null),
          ),
          for (final t in tipos)
            ListTile(
              title: Text(t),
              trailing: selected == t ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop<String?>(context, t),
            ),
        ],
      ),
    );
  }
}