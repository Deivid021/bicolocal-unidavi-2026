import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/auth.dart';
import 'data/auth_firebase.dart';
import 'data/fonte_firestore.dart';
import 'data/fonte_memoria.dart';
import 'data/repositorio.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

/// `flutter run --dart-define=DEMO=true` força o modo demonstração (dados em memória).
const _forcarDemo = bool.fromEnvironment('DEMO');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Repositorio.instancia = await _criarRepositorio();
  runApp(const BicoLocalApp());
}

Future<Repositorio> _criarRepositorio() async {
  if (!_forcarDemo) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      return Repositorio(fonte: FonteFirestore(), auth: AuthFirebase());
    } catch (e) {
      debugPrint('Firebase indisponível ($e). Iniciando em modo demonstração.');
    }
  }
  return Repositorio(fonte: FonteMemoria(), auth: AuthMemoria(), modoDemonstracao: true);
}

class BicoLocalApp extends StatelessWidget {
  const BicoLocalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BicoLocal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B7F5B)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
