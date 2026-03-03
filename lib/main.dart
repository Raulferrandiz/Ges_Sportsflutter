import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'auth/auth_gate.dart';
import 'services/user_firestore_service.dart';
import 'services/pista_firestore_service.dart';
import 'services/reserva_firestore_service.dart';
import 'services/incidencia_firestore_service.dart';
import 'providers/user_provider.dart';
import 'providers/pista_provider.dart';
import 'providers/reserva_provider.dart';
import 'providers/incidencia_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => UserFirestoreService()),
        Provider(create: (_) => PistaFirestoreService()),
        Provider(create: (_) => ReservaFirestoreService()),
        Provider(create: (_) => IncidenciaFirestoreService()),
        ChangeNotifierProvider(
          create: (ctx) => UserProvider(ctx.read<UserFirestoreService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => PistaProvider(ctx.read<PistaFirestoreService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ReservaProvider(ctx.read<ReservaFirestoreService>()),
        ),
        ChangeNotifierProvider(
          create: (ctx) => IncidenciaProvider(ctx.read<IncidenciaFirestoreService>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
      ),
    );
  }
}