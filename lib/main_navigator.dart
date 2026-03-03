import 'package:login/screens/login_screen.dart';
import 'package:login/screens/users/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/*void main() {
  runApp(const MyApp());
}
*/
void main() async {
  //Esperamos a que Firebase se resuelva
  WidgetsFlutterBinding.ensureInitialized(); //Prepara flutter para plugins, que permiten que se comunique con Android o IOS

  await Firebase.initializeApp(
    //Nos conectamos con Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {'/': (_) => UsersScreen(), '/login': (_) => LoginScreen()},
      //home: LoginScreen(),
    );
  }
}
