import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth_screen.dart';
import 'screens/acervo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MeuAcervoApp());
}

class MeuAcervoApp extends StatelessWidget {
  const MeuAcervoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acervo Inteligente',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const AcervoScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}