import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login/models/pista.dart';
import 'package:login/providers/pista_provider.dart';
import 'package:login/screens/pistas/pista_form_screen.dart';

class PistasStfulScreen extends StatefulWidget {
  const PistasStfulScreen({super.key});

  @override
  State<PistasStfulScreen> createState() => _PistasStfulScreenState();
}

class _PistasStfulScreenState extends State<PistasStfulScreen> {
  static const Color appOrange = Color(0xFFF59E0B);

  bool _onlyActive = true;
  String? _selectedTipo; 

  Future<void> _confirmDelete(BuildContext context, Pista p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar pista'),
        content: Text('¿Seguro que quieres eliminar:\n\n${p.nombre}?'),
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
        await context.read<PistaProvider>().delete(p.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pista eliminada')),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error eliminando: $e')),
        );
      }
    }
  }

  Future<void> _toggleActiva(BuildContext context, Pista p) async {
    final next = !p.activa;

    //desactivar
    if (p.activa) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Desactivar pista'),
          content: const Text('Si desactivas la pista, no aparecerá para nuevas reservas.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Desactivar'),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }

    try {
      await context.read<PistaProvider>().setActiva(p.id, next);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(next ? 'Pista activada' : 'Pista desactivada')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cambiando estado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pistasStream = context.watch<PistaProvider>().pistas;

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
                'Pistas',
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
            MaterialPageRoute(builder: (_) => const PistaFormScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: StreamBuilder<List<Pista>>(
        stream: pistasStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return const Center(child: Text('Error cargando pistas'));
          }

          final all = snap.data ?? const <Pista>[];
          final tipos = all
              .map((p) => p.tipo.trim())
              .where((t) => t.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

          if (_selectedTipo != null && !tipos.contains(_selectedTipo)) {
            _selectedTipo = null;
          }

          var pistas = all;

          if (_onlyActive) {
            pistas = pistas.where((p) => p.activa).toList();
          }
          if (_selectedTipo != null) {
            pistas = pistas.where((p) => p.tipo.trim() == _selectedTipo).toList();
          }

          pistas.sort((a, b) => a.nombre.compareTo(b.nombre));

          return Column(
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
                        const Text('Filtros', style: TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 6,
                          children: [
                            FilterChip(
                              label: const Text('Solo activas'),
                              selected: _onlyActive,
                              onSelected: (v) => setState(() => _onlyActive = v),
                            ),
                            if (tipos.isNotEmpty)
                              ChoiceChip(
                                label: Text(_selectedTipo == null ? 'Tipo: todos' : 'Tipo: $_selectedTipo'),
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
                                child: const Text('Quitar tipo'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: pistas.isEmpty
                    ? const Center(child: Text('No hay pistas para mostrar'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: pistas.length,
                        itemBuilder: (context, i) {
                          final p = pistas[i];
                          final subtitle = [
                            if (p.direccion.trim().isNotEmpty) p.direccion.trim(),
                            if (p.tipo.trim().isNotEmpty) 'tipo: ${p.tipo.trim()}',
                            'activa: ${p.activa ? "sí" : "no"}',
                          ].join(' · ');

                          return Card(
                            child: ListTile(
                              title: Text(
                                p.nombre.isEmpty ? '(Sin nombre)' : p.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              subtitle: Text(subtitle),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PistaFormScreen(pistaToEdit: p),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      p.activa ? Icons.toggle_on_outlined : Icons.toggle_off_outlined,
                                      color: p.activa ? Colors.green : Colors.grey,
                                    ),
                                    tooltip: p.activa ? 'Desactivar' : 'Activar',
                                    onPressed: () => _toggleActiva(context, p),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () => _confirmDelete(context, p),
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