import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/services/auth_service.dart';

class RegisterScreenAuthgate extends StatefulWidget {
  const RegisterScreenAuthgate({super.key});

  @override
  State<RegisterScreenAuthgate> createState() => _RegisterScreenAuthgateState();
}

class _RegisterScreenAuthgateState extends State<RegisterScreenAuthgate> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  final _authService = AuthService();

  bool _loading = false;

  static const Color accent = Color(0xFFF5A623);
  static const Color bg = Color(0xFFF7F2F5);

  Future<void> _register() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final pass2 = _pass2Ctrl.text;

    if (email.isEmpty || pass.isEmpty || pass2.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rellena todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email inválido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (pass != pass2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Las contraseñas no coinciden'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _authService.signUp(email, pass);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario creado correctamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Volver a login. AuthGate se encargará de redirigir cuando inicie sesión.
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final msg = switch (e.code) {
        'email-already-in-use' => 'El email ya está en uso',
        'invalid-email' => 'Email inválido',
        'weak-password' => 'Contraseña demasiado débil',
        _ => 'No se pudo crear el usuario (${e.code})',
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al crear el usuario'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/gesports.png',
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 22),

                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Introduce el correo:',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Introduce la contraseña:',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _pass2Ctrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Repite la contraseña:',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Crear usuario',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Text('o', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: const StadiumBorder(),
                        side: const BorderSide(color: Colors.grey),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}