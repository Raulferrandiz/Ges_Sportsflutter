import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login/models/user.dart';
import 'package:login/providers/user_provider.dart';
import 'package:login/screens/users/user_form_screen.dart';

class UsersStfulScreen extends StatelessWidget {
  const UsersStfulScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, User u) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text('¿Seguro que quieres eliminar a:\n\n${u.email}?'),
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
      context.read<UserProvider>().delete(u.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario eliminado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersStream = context.watch<UserProvider>().users;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
            appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leadingWidth: 56,
        //logo
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Center(
            child: Image.asset(
              'assets/images/gesports.png', 
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          ),
        ),
        //titulo
        title: const Text(
          'Usuarios',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFFF59E0B),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<User>>(
        stream: usersStream,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snap.data ?? const [];

          if (users.isEmpty) {
            return const Center(child: Text('No hay usuarios'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, i) {
              final u = users[i];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(u.colorfondo),
                    child: Text(
                      (u.nombre.isNotEmpty ? u.nombre[0] : '?').toUpperCase(),
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  title: Text(u.nombre.isEmpty ? '(Sin nombre)' : u.nombre),
                  subtitle: Text('${u.email}\nrol: ${u.rol} · activo: ${u.activo ? "sí" : "no"}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserFormScreen(userToEdit: u),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(context, u),
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