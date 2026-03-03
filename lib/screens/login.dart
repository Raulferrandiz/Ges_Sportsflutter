import 'package:flutter/material.dart';
import 'package:login/screens/login_screen_authgate.dart';

/// Entry point for the login UI used by AuthGate.
/// This keeps the file name the user expects: lib/screens/login.dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginWrapper();
  }
}

class _LoginWrapper extends StatelessWidget {
  const _LoginWrapper();

  @override
  Widget build(BuildContext context) {
    // Reuse your existing working login implementation.
    return LoginScreenAuthgate();
  }
}
