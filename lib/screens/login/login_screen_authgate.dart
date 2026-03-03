import 'package:login/screens/users/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:login/services/auth_service.dart';

class LoginScreenAuthgate extends StatefulWidget {
  const LoginScreenAuthgate({super.key});

  @override
  State<LoginScreenAuthgate> createState() => _LoginScreenAuthgateState();
}

class _LoginScreenAuthgateState extends State<LoginScreenAuthgate> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;
  String? _error;

  Future<void> _login({required bool register}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      if (register) {
        await _authService.signUp(_emailCtrl.text, _passCtrl.text);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _authService.signIn(_emailCtrl.text, _passCtrl.text);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login correcto'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // AuthGate reaccionará automáticamente
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email o contraseña incorrectos'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Acceso',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 20),

              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),

              if (_loading)
                const CircularProgressIndicator()
              else ...[
                ElevatedButton(
                  onPressed: () => _login(register: false),
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () => _login(register: true),
                  child: const Text('Crear cuenta'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
