import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/screens/dashboard_screen.dart';
import 'package:login/screens/home_screen.dart';
import 'package:login/screens/login_screen_authgate.dart'; 

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = authSnap.data;

        if (user == null) return const LoginScreenAuthgate();

        final authEmail = (user.email ?? '').trim();
        if (authEmail.isEmpty) {
          return const LoginScreenAuthgate();
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: authEmail)
              .limit(1)
              .snapshots(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            if (userSnap.hasError) {
              return Scaffold(
                body: Center(child: Text('Error leyendo perfil: ${userSnap.error}')),
              );
            }

            final docs = userSnap.data?.docs ?? const [];
            if (docs.isEmpty) {
              return const LoginScreenAuthgate();
            }

            final data = docs.first.data();
            final rol = (data['rol'] ?? '').toString().trim().toLowerCase();
            final email = (data['email'] ?? authEmail).toString().trim();

            if (rol.isEmpty) {
              return const LoginScreenAuthgate();
            }

            if (rol == 'admin') {
              return DashboardScreen(adminEmail: email);
            }

            return HomeScreen(rol: rol, email: email);
          },
        );
      },
    );
  }
}