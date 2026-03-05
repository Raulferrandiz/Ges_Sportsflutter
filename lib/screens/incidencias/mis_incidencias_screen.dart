import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:login/models/incidencia.dart';
import 'package:login/providers/incidencia_provider.dart';
import 'package:login/screens/incidencias/incidencia_form_screen.dart';

class MisIncidenciasScreen extends StatelessWidget {
  const MisIncidenciasScreen({super.key});

  static const Color appOrange = Color(0xFFF59E0B);

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

    if (ok != true) return;

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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

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
                'Mis incidencias',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, color: appOrange),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: appOrange,
        onPressed: uid == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IncidenciaFormScreen()),
                );
              },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: (uid == null)
          ? const Center(child: Text('No hay sesión activa.'))
          : StreamBuilder<List<Incidencia>>(
              stream: context.watch<IncidenciaProvider>().incidenciasDeCreador(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return const Center(child: Text('Error cargando incidencias'));
                }

                final incidencias = snap.data ?? const <Incidencia>[];
                if (incidencias.isEmpty) {
                  return const Center(child: Text('Aún no has creado incidencias.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: incidencias.length,
                  itemBuilder: (context, idx) {
                    final i = incidencias[idx];
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
                          'tipo: ${i.tipo.isEmpty ? "(sin tipo)" : i.tipo}',
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
                );
              },
            ),
    );
  }
}