import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const BicoLocalApp());
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
