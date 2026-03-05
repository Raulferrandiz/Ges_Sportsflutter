import 'package:flutter/material.dart';
import 'package:login/screens/login/login_screen_authgate.dart';

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
    return const LoginScreenAuthgate();
  }
}