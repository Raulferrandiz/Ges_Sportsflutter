import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/screens/dashboard_screen.dart';
import 'package:login/screens/home_screen.dart';
import 'package:login/screens/login_screen_authgate.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static const _validRoles = {'admin', 'jugador', 'entrenador'};

  bool _parseBool(dynamic v, {required bool defaultValue}) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes' || s == 'si') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return defaultValue;
  }

  Future<DocumentReference<Map<String, dynamic>>> _resolveUserDoc(User user) async {
    final db = FirebaseFirestore.instance;
    final uidRef = db.collection('users').doc(user.uid);

    final uidSnap = await uidRef.get();
    if (uidSnap.exists) return uidRef;

    final email = user.email;
    if (email == null || email.trim().isEmpty) return uidRef;

    final q = await db
        .collection('users')
        .where('email', isEqualTo: email.trim().toLowerCase())
        .limit(1)
        .get();

    if (q.docs.isNotEmpty) return q.docs.first.reference;

    return uidRef;
  }

  Future<_UserCtx> _resolveUserCtx(User user) async {
    final fallbackEmail = (user.email ?? '').trim().toLowerCase();

    try {
      final userRef = await _resolveUserDoc(user);
      final snap = await userRef.get();

      if (!snap.exists) {
        await userRef.set(
          {
            'email': fallbackEmail,
            'nombre': (user.displayName ?? '').toString(),
            'rol': 'jugador',
            'activo': true,
          },
          SetOptions(merge: true),
        );

        return _UserCtx(
          rol: 'jugador',
          email: fallbackEmail,
          activo: true,
          userDocId: userRef.id,
        );
      }

      final data = snap.data() ?? <String, dynamic>{};

      final rolRaw =
          (data['rol'] ?? data['role'] ?? data['tipo'])?.toString().toLowerCase().trim();
      final rol = (rolRaw != null && _validRoles.contains(rolRaw)) ? rolRaw : 'jugador';

      final emailRaw = (data['email'] ?? fallbackEmail).toString().trim().toLowerCase();

      final activo = _parseBool(data['activo'], defaultValue: true);

      return _UserCtx(
        rol: rol,
        email: emailRaw,
        activo: activo,
        userDocId: userRef.id,
      );
    } catch (_) {
      return _UserCtx(
        rol: 'jugador',
        email: fallbackEmail,
        activo: true,
        userDocId: user.uid,
      );
    }
  }

  Widget _screenFor(_UserCtx ctx) {
    switch (ctx.rol) {
      case 'admin':
        return DashboardScreen(adminEmail: ctx.email);
      case 'jugador':
      case 'entrenador':
      default:
        return HomeScreen(rol: ctx.rol, email: ctx.email, userDocId: ctx.userDocId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;

        if (user == null) return const LoginScreenAuthgate();

        return FutureBuilder<_UserCtx>(
          future: _resolveUserCtx(user),
          builder: (context, ctxSnap) {
            if (ctxSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }

            final ctx = ctxSnap.data ??
                _UserCtx(
                  rol: 'jugador',
                  email: (user.email ?? '').trim().toLowerCase(),
                  activo: true,
                  userDocId: user.uid,
                );

            if (!ctx.activo) {
              return DisabledAccountScreen(email: ctx.email);
            }

            return _screenFor(ctx);
          },
        );
      },
    );
  }
}

class _UserCtx {
  const _UserCtx({
    required this.rol,
    required this.email,
    required this.activo,
    required this.userDocId,
  });

  final String rol;
  final String email;
  final bool activo;
  final String userDocId;
}

class DisabledAccountScreen extends StatelessWidget {
  const DisabledAccountScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Acceso bloqueado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.block, size: 64),
              const SizedBox(height: 12),
              const Text(
                'Tu cuenta está desactivada.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                email.isEmpty ? '' : 'Usuario: $email',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}