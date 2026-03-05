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
  String _error = '';

  Future<void> _login({required bool register}) async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      if (register) {
        await _authService.signUp(_emailCtrl.text.trim(), _passCtrl.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await _authService.signIn(_emailCtrl.text.trim(), _passCtrl.text);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login correcto'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email o contraseña incorrectos'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFF5A623);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/gesports.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 16),
                Text(
                  'Inicio de Sesión',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Introduce el correo:',
                    hintText: 'Correo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Introduce la contraseña:',
                    hintText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(),
                  )
                else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _login(register: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text('Iniciar Sesión', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _login(register: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('o', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Google Sign-In: pendiente de implementar.')),
                        );
                      },
                      style: OutlinedButton.styleFrom(shape: const StadiumBorder()),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/googlepng.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          const Text('Continuar con Google', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],

                if (_error.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
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
